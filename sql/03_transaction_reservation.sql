-- ============================================
-- CINEPHORIA - Transaction de réservation
-- Projet CDA - Échéance : 22 juillet 2025
-- ============================================

-- BUT DE CETTE TRANSACTION :
-- Gérer de manière atomique la création d'une réservation
-- avec mise à jour des places disponibles et génération du QR code
-- Si une étape échoue, tout est annulé (principe ACID)

-- ============================================
-- TRANSACTION : Créer une réservation complète
-- ============================================

DELIMITER //

DROP PROCEDURE IF EXISTS CreerReservation//

CREATE PROCEDURE CreerReservation(
    IN p_utilisateur_id INT,
    IN p_seance_id INT,
    IN p_nb_places INT,
    IN p_methode_paiement ENUM('carte', 'paypal', 'especes'),
    OUT p_numero_reservation VARCHAR(20),
    OUT p_qr_code VARCHAR(255),
    OUT p_resultat VARCHAR(100)
)
BEGIN
    -- Variables pour la transaction
    DECLARE v_prix_unitaire DECIMAL(5,2);
    DECLARE v_prix_total DECIMAL(6,2);
    DECLARE v_places_disponibles INT;
    DECLARE v_film_titre VARCHAR(255);
    DECLARE v_date_seance DATE;
    DECLARE v_heure_debut TIME;
    DECLARE v_reservation_id INT;
    DECLARE v_counter INT;
    DECLARE v_current_year INT;
    DECLARE v_current_month INT;

    -- Gestionnaire d'erreur
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            -- En cas d'erreur, annuler toute la transaction
            ROLLBACK;
            SET p_resultat = 'ERREUR: Transaction annulée';
            SET p_numero_reservation = NULL;
            SET p_qr_code = NULL;
        END;

    -- DÉMARRER LA TRANSACTION
    START TRANSACTION;

    -- ============================================
    -- ÉTAPE 1 : Vérifications préalables
    -- ============================================

    -- Vérifier que l'utilisateur existe
    IF NOT EXISTS (SELECT 1 FROM utilisateurs WHERE id = p_utilisateur_id AND actif = TRUE) THEN
        SET p_resultat = 'ERREUR: Utilisateur inexistant ou inactif';
        ROLLBACK;
        LEAVE;
    END IF;

    -- Récupérer les informations de la séance avec VERROUILLAGE
    SELECT
        s.prix,
        s.places_disponibles,
        f.titre,
        s.date_seance,
        s.heure_debut
    INTO
        v_prix_unitaire,
        v_places_disponibles,
        v_film_titre,
        v_date_seance,
        v_heure_debut
    FROM seances s
             JOIN films f ON s.film_id = f.id
    WHERE s.id = p_seance_id
      AND s.statut = 'programmee'
      AND s.date_seance >= CURDATE()
        FOR UPDATE; -- VERROUILLAGE pour éviter les réservations simultanées

    -- Vérifier que la séance existe
    IF v_prix_unitaire IS NULL THEN
        SET p_resultat = 'ERREUR: Séance inexistante ou passée';
        ROLLBACK;
        LEAVE;
    END IF;

    -- Vérifier la disponibilité des places
    IF v_places_disponibles < p_nb_places THEN
        SET p_resultat = CONCAT('ERREUR: Seulement ', v_places_disponibles, ' places disponibles');
        ROLLBACK;
        LEAVE;
    END IF;

    -- Vérifier le nombre de places demandées
    IF p_nb_places <= 0 OR p_nb_places > 10 THEN
        SET p_resultat = 'ERREUR: Nombre de places invalide (1-10)';
        ROLLBACK;
        LEAVE;
    END IF;

    -- ============================================
    -- ÉTAPE 2 : Générer le numéro de réservation unique
    -- ============================================

    SET v_current_year = YEAR(NOW());
    SET v_current_month = MONTH(NOW());

    -- Obtenir le prochain numéro de réservation
    SELECT COALESCE(MAX(CAST(SUBSTRING(numero_reservation, 8) AS UNSIGNED)), 0) + 1
    INTO v_counter
    FROM reservations
    WHERE YEAR(created_at) = v_current_year
      AND MONTH(created_at) = v_current_month;

    -- Générer le numéro de réservation
    SET p_numero_reservation = CONCAT('RES', v_current_year, LPAD(v_current_month, 2, '0'), LPAD(v_counter, 3, '0'));

    -- ============================================
    -- ÉTAPE 3 : Calculer le prix total
    -- ============================================

    SET v_prix_total = v_prix_unitaire * p_nb_places;

    -- ============================================
    -- ÉTAPE 4 : Générer le QR code
    -- ============================================

    SET p_qr_code = CONCAT('QR_', p_numero_reservation, '_', v_current_year);

    -- ============================================
    -- ÉTAPE 5 : Insérer la réservation
    -- ============================================

    INSERT INTO reservations (
        numero_reservation,
        utilisateur_id,
        seance_id,
        nb_places,
        prix_total,
        statut,
        methode_paiement,
        qr_code,
        date_reservation
    ) VALUES (
                 p_numero_reservation,
                 p_utilisateur_id,
                 p_seance_id,
                 p_nb_places,
                 v_prix_total,
                 'confirmee',
                 p_methode_paiement,
                 p_qr_code,
                 NOW()
             );

    -- Récupérer l'ID de la réservation créée
    SET v_reservation_id = LAST_INSERT_ID();

    -- ============================================
    -- ÉTAPE 6 : Mettre à jour les places disponibles
    -- ============================================

    UPDATE seances
    SET
        places_disponibles = places_disponibles - p_nb_places,
        places_vendues = places_vendues + p_nb_places,
        updated_at = NOW()
    WHERE id = p_seance_id;

    -- Vérifier que la mise à jour s'est bien passée
    IF ROW_COUNT() = 0 THEN
        SET p_resultat = 'ERREUR: Impossible de mettre à jour les places';
        ROLLBACK;
        LEAVE;
    END IF;

    -- ============================================
    -- ÉTAPE 7 : Enregistrer dans les statistiques (optionnel)
    -- ============================================

    -- Insérer ou mettre à jour les statistiques quotidiennes
    INSERT INTO statistiques_reservations (
        date_stat,
        nb_reservations,
        nb_places_vendues,
        chiffre_affaires,
        created_at
    ) VALUES (
                 CURDATE(),
                 1,
                 p_nb_places,
                 v_prix_total,
                 NOW()
             ) ON DUPLICATE KEY UPDATE
                                    nb_reservations = nb_reservations + 1,
                                    nb_places_vendues = nb_places_vendues + p_nb_places,
                                    chiffre_affaires = chiffre_affaires + v_prix_total,
                                    updated_at = NOW();

    -- ============================================
    -- ÉTAPE 8 : Enregistrer un log de la transaction
    -- ============================================

    INSERT INTO logs_transactions (
        type_transaction,
        utilisateur_id,
        seance_id,
        reservation_id,
        montant,
        details,
        created_at
    ) VALUES (
                 'RESERVATION',
                 p_utilisateur_id,
                 p_seance_id,
                 v_reservation_id,
                 v_prix_total,
                 CONCAT('Réservation ', p_nb_places, ' places pour "', v_film_titre, '" le ', v_date_seance, ' à ', v_heure_debut),
                 NOW()
             );

    -- ============================================
    -- VALIDATION FINALE
    -- ============================================

    -- Si tout s'est bien passé, valider la transaction
    COMMIT;

    -- Message de succès
    SET p_resultat = CONCAT('SUCCESS: Réservation créée avec succès - ', p_numero_reservation);

END//

DELIMITER ;

-- ============================================
-- TABLES SUPPORT pour la transaction
-- ============================================

-- Table pour les statistiques quotidiennes
CREATE TABLE IF NOT EXISTS statistiques_reservations (
                                                         id INT AUTO_INCREMENT PRIMARY KEY,
                                                         date_stat DATE UNIQUE NOT NULL,
                                                         nb_reservations INT DEFAULT 0,
                                                         nb_places_vendues INT DEFAULT 0,
                                                         chiffre_affaires DECIMAL(10,2) DEFAULT 0.00,
                                                         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                                         updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table pour les logs de transactions
CREATE TABLE IF NOT EXISTS logs_transactions (
                                                 id INT AUTO_INCREMENT PRIMARY KEY,
                                                 type_transaction ENUM('RESERVATION', 'ANNULATION', 'MODIFICATION') NOT NULL,
                                                 utilisateur_id INT NOT NULL,
                                                 seance_id INT,
                                                 reservation_id INT,
                                                 montant DECIMAL(10,2),
                                                 details TEXT,
                                                 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

                                                 FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id),
                                                 FOREIGN KEY (seance_id) REFERENCES seances(id),
                                                 FOREIGN KEY (reservation_id) REFERENCES reservations(id),

                                                 INDEX idx_type (type_transaction),
                                                 INDEX idx_utilisateur (utilisateur_id),
                                                 INDEX idx_date (created_at)
);

-- ============================================
-- EXEMPLE D'UTILISATION DE LA TRANSACTION
-- ============================================

-- Variables pour recevoir les résultats
-- CALL CreerReservation(6, 1, 2, 'carte', @numero, @qr, @resultat);
-- SELECT @numero as numero_reservation, @qr as qr_code, @resultat as resultat;

-- ============================================
-- TRANSACTION INVERSE : Annuler une réservation
-- ============================================

DELIMITER //

DROP PROCEDURE IF EXISTS AnnulerReservation//

CREATE PROCEDURE AnnulerReservation(
    IN p_numero_reservation VARCHAR(20),
    IN p_utilisateur_id INT,
    OUT p_resultat VARCHAR(100)
)
BEGIN
    DECLARE v_reservation_id INT;
    DECLARE v_seance_id INT;
    DECLARE v_nb_places INT;
    DECLARE v_prix_total DECIMAL(6,2);
    DECLARE v_statut VARCHAR(20);

    -- Gestionnaire d'erreur
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SET p_resultat = 'ERREUR: Transaction d\'annulation échouée';
        END;

    START TRANSACTION;

    -- Récupérer les informations de la réservation
    SELECT id, seance_id, nb_places, prix_total, statut
    INTO v_reservation_id, v_seance_id, v_nb_places, v_prix_total, v_statut
    FROM reservations
    WHERE numero_reservation = p_numero_reservation
      AND utilisateur_id = p_utilisateur_id
        FOR UPDATE;

    -- Vérifications
    IF v_reservation_id IS NULL THEN
        SET p_resultat = 'ERREUR: Réservation introuvable';
        ROLLBACK;
        LEAVE;
    END IF;

    IF v_statut != 'confirmee' THEN
        SET p_resultat = 'ERREUR: Réservation déjà annulée';
        ROLLBACK;
        LEAVE;
    END IF;

    -- Vérifier que la séance n'a pas encore eu lieu
    IF EXISTS (SELECT 1 FROM seances WHERE id = v_seance_id AND date_seance < CURDATE()) THEN
        SET p_resultat = 'ERREUR: Impossible d\'annuler, séance passée';
        ROLLBACK;
        LEAVE;
    END IF;

    -- Annuler la réservation
    UPDATE reservations
    SET statut = 'annulee',
        date_annulation = NOW(),
        updated_at = NOW()
    WHERE id = v_reservation_id;

    -- Remettre les places disponibles
    UPDATE seances
    SET places_disponibles = places_disponibles + v_nb_places,
        places_vendues = places_vendues - v_nb_places,
        updated_at = NOW()
    WHERE id = v_seance_id;

    -- Mettre à jour les statistiques
    UPDATE statistiques_reservations
    SET nb_reservations = nb_reservations - 1,
        nb_places_vendues = nb_places_vendues - v_nb_places,
        chiffre_affaires = chiffre_affaires - v_prix_total,
        updated_at = NOW()
    WHERE date_stat = CURDATE();

    -- Log de l'annulation
    INSERT INTO logs_transactions (
        type_transaction,
        utilisateur_id,
        seance_id,
        reservation_id,
        montant,
        details,
        created_at
    ) VALUES (
                 'ANNULATION',
                 p_utilisateur_id,
                 v_seance_id,
                 v_reservation_id,
                 -v_prix_total,
                 CONCAT('Annulation réservation ', p_numero_reservation),
                 NOW()
             );

    COMMIT;
    SET p_resultat = 'SUCCESS: Réservation annulée avec succès';

END//

DELIMITER ;

-- ============================================
-- COMMENTAIRES SUR LA TRANSACTION
-- ============================================

/*
ANALYSE DE LA TRANSACTION :

1. ATOMICITÉ :
   - Toutes les opérations réussissent ou échouent ensemble
   - Utilisation de START TRANSACTION / COMMIT / ROLLBACK

2. COHÉRENCE :
   - Vérifications des contraintes métier avant modification
   - Mise à jour cohérente des places disponibles

3. ISOLATION :
   - Utilisation de FOR UPDATE pour verrouiller les lignes
   - Évite les réservations simultanées sur la même séance

4. DURABILITÉ :
   - Les données sont persistées après COMMIT
   - Logs pour traçabilité

AVANTAGES :
- Évite les surventes (overbooking)
- Garantit l'intégrité des données
- Traçabilité complète des opérations
- Gestion des erreurs centralisée

UTILISATION :
Cette transaction est appelée depuis l'application PHP
lors de la validation d'une réservation utilisateur.
*/