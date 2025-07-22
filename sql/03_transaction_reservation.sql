-- ============================================
-- TRANSACTION : Création d'une commande simple
-- ============================================

DELIMITER //

DROP PROCEDURE IF EXISTS PasserCommande//

CREATE PROCEDURE PasserCommande(
    IN p_utilisateur_id INT,
    IN p_produit_id INT,
    IN p_quantite INT,
    OUT p_resultat VARCHAR(100)
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_prix_unitaire DECIMAL(6,2);
    DECLARE v_total DECIMAL(10,2);

    -- Gestion des erreurs
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SET p_resultat = 'ERREUR: La commande a échoué';
        END;

    START TRANSACTION;

    -- Vérifier le stock du produit
    SELECT stock, prix INTO v_stock, v_prix_unitaire
    FROM produits
    WHERE id = p_produit_id
        FOR UPDATE;

    IF v_stock < p_quantite THEN
        SET p_resultat = 'ERREUR: Stock insuffisant';
        ROLLBACK;
        LEAVE;
    END IF;

    -- Calcul du total
    SET v_total = v_prix_unitaire * p_quantite;

    -- Insérer la commande
    INSERT INTO commandes(utilisateur_id, produit_id, quantite, total, date_commande)
    VALUES(p_utilisateur_id, p_produit_id, p_quantite, v_total, NOW());

    -- Mettre à jour le stock
    UPDATE produits
    SET stock = stock - p_quantite
    WHERE id = p_produit_id;

    -- Log de la commande
    INSERT INTO logs_commandes(utilisateur_id, produit_id, quantite, total, date_log)
    VALUES(p_utilisateur_id, p_produit_id, p_quantite, v_total, NOW());

    COMMIT;
    SET p_resultat = 'SUCCESS: Commande passée avec succès';
END//

DELIMITER ;
