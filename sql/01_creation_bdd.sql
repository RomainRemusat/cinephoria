-- ============================================
-- CINEPHORIA - Structure de base de données
-- Projet CDA - Échéance : 22 juillet 2025
-- ============================================

-- Suppression des tables existantes (ordre inversé pour les contraintes)
DROP TABLE IF EXISTS incidents;
DROP TABLE IF EXISTS avis;
DROP TABLE IF EXISTS reservations;
DROP TABLE IF EXISTS seances;
DROP TABLE IF EXISTS films;
DROP TABLE IF EXISTS salles;
DROP TABLE IF EXISTS utilisateurs;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS cinemas;

-- ============================================
-- TABLE : cinemas (NOUVELLE TABLE)
-- ============================================
CREATE TABLE cinemas (
 id INT AUTO_INCREMENT PRIMARY KEY,
 ville VARCHAR(50) NOT NULL,
 pays VARCHAR(50) NOT NULL,
 adresse VARCHAR(100) NOT NULL,
 code_postal VARCHAR(10),
 telephone VARCHAR(20),
 email VARCHAR(100),
 actif BOOLEAN DEFAULT TRUE,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

 INDEX idx_ville (ville),
 INDEX idx_pays (pays),
 INDEX idx_actif (actif)
);

-- ============================================
-- TABLE : categories
-- ============================================
CREATE TABLE categories (
id INT AUTO_INCREMENT PRIMARY KEY,
nom VARCHAR(100) NOT NULL UNIQUE,
description TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE : utilisateurs
-- ============================================
CREATE TABLE utilisateurs (
id INT AUTO_INCREMENT PRIMARY KEY,
nom VARCHAR(100) NOT NULL,
prenom VARCHAR(100) NOT NULL,
email VARCHAR(255) UNIQUE NOT NULL,
mot_de_passe VARCHAR(255) NOT NULL,
telephone VARCHAR(20),
date_naissance DATE,
cinema_id INT NULL,
role ENUM('utilisateur', 'employe', 'admin') DEFAULT 'utilisateur',
actif BOOLEAN DEFAULT TRUE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
last_login TIMESTAMP NULL,

FOREIGN KEY (cinema_id) REFERENCES cinemas(id) ON DELETE SET NULL,
INDEX idx_email (email),
INDEX idx_role (role),
INDEX idx_cinema (cinema_id),
INDEX idx_last_login (last_login)
);

-- ============================================
-- TABLE : salles
-- ============================================
CREATE TABLE salles (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        cinema_id INT NOT NULL,
                        nom VARCHAR(50) NOT NULL,
                        capacite INT NOT NULL,
                        type_salle ENUM('standard', 'premium', 'imax') DEFAULT 'standard',
                        equipements JSON,
                        actif BOOLEAN DEFAULT TRUE,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

                        FOREIGN KEY (cinema_id) REFERENCES cinemas(id) ON DELETE CASCADE,
                        INDEX idx_nom (nom),
                        INDEX idx_cinema (cinema_id),
                        UNIQUE KEY unique_salle_cinema (cinema_id, nom)
);

-- ============================================
-- TABLE : films
-- ============================================
CREATE TABLE films (
                       id INT AUTO_INCREMENT PRIMARY KEY,
                       titre VARCHAR(255) NOT NULL,
                       titre_original VARCHAR(255),
                       description TEXT,
                       synopsis TEXT,
                       duree INT NOT NULL COMMENT 'Durée en minutes',
                       date_sortie DATE,
                       realisateur VARCHAR(255),
                       acteurs TEXT,
                       categorie_id INT,
                       age_minimum INT DEFAULT 0,
                       note_moyenne DECIMAL(3,2) DEFAULT 0.00,
                       affiche VARCHAR(255),
                       bande_annonce VARCHAR(255),
                       statut ENUM('a_venir', 'en_cours', 'archive') DEFAULT 'a_venir',
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                       FOREIGN KEY (categorie_id) REFERENCES categories(id) ON DELETE SET NULL,
                       INDEX idx_titre (titre),
                       INDEX idx_statut (statut),
                       INDEX idx_date_sortie (date_sortie)
);

-- ============================================
-- TABLE : seances
-- ============================================
CREATE TABLE seances (
                         id INT AUTO_INCREMENT PRIMARY KEY,
                         film_id INT NOT NULL,
                         salle_id INT NOT NULL,
                         date_seance DATE NOT NULL,
                         heure_debut TIME NOT NULL,
                         heure_fin TIME NOT NULL,
                         prix DECIMAL(5,2) NOT NULL,
                         places_disponibles INT NOT NULL,
                         places_vendues INT DEFAULT 0,
                         statut ENUM('programmee', 'en_cours', 'terminee', 'annulee') DEFAULT 'programmee',
                         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                         updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                         FOREIGN KEY (film_id) REFERENCES films(id) ON DELETE CASCADE,
                         FOREIGN KEY (salle_id) REFERENCES salles(id) ON DELETE CASCADE,
                         INDEX idx_film (film_id),
                         INDEX idx_salle (salle_id),
                         INDEX idx_date_seance (date_seance),
                         INDEX idx_statut (statut),
                         UNIQUE KEY unique_seance (salle_id, date_seance, heure_debut)
);

-- ============================================
-- TABLE : reservations
-- ============================================
CREATE TABLE reservations (
                              id INT AUTO_INCREMENT PRIMARY KEY,
                              numero_reservation VARCHAR(20) UNIQUE NOT NULL,
                              utilisateur_id INT NOT NULL,
                              seance_id INT NOT NULL,
                              nb_places INT NOT NULL,
                              prix_total DECIMAL(6,2) NOT NULL,
                              statut ENUM('en_attente', 'confirmee', 'annulee', 'terminee') DEFAULT 'en_attente',
                              methode_paiement ENUM('carte', 'paypal', 'especes') DEFAULT 'carte',
                              qr_code VARCHAR(255),
                              date_reservation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                              date_annulation TIMESTAMP NULL,
                              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                              updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                              FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
                              FOREIGN KEY (seance_id) REFERENCES seances(id) ON DELETE CASCADE,
                              INDEX idx_utilisateur (utilisateur_id),
                              INDEX idx_seance (seance_id),
                              INDEX idx_numero (numero_reservation),
                              INDEX idx_statut (statut),
                              INDEX idx_date_reservation (date_reservation)
);

-- ============================================
-- TABLE : avis
-- ============================================
CREATE TABLE avis (
                      id INT AUTO_INCREMENT PRIMARY KEY,
                      utilisateur_id INT NOT NULL,
                      film_id INT NOT NULL,
                      note INT NOT NULL CHECK (note >= 1 AND note <= 5),
                      commentaire TEXT,
                      valide BOOLEAN DEFAULT FALSE,
                      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                      FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
                      FOREIGN KEY (film_id) REFERENCES films(id) ON DELETE CASCADE,
                      INDEX idx_utilisateur (utilisateur_id),
                      INDEX idx_film (film_id),
                      INDEX idx_note (note),
                      INDEX idx_valide (valide),
                      UNIQUE KEY unique_avis (utilisateur_id, film_id)
);

-- ============================================
-- TABLE : incidents (pour l'app bureautique)
-- ============================================
CREATE TABLE incidents (
                           id INT AUTO_INCREMENT PRIMARY KEY,
                           employe_id INT NOT NULL,
                           cinema_id INT,
                           salle_id INT,
                           seance_id INT,
                           type_incident ENUM('technique', 'securite', 'maintenance', 'autre') NOT NULL,
                           titre VARCHAR(255) NOT NULL,
                           description TEXT NOT NULL,
                           priorite ENUM('basse', 'moyenne', 'haute', 'critique') DEFAULT 'moyenne',
                           statut ENUM('ouvert', 'en_cours', 'resolu', 'ferme') DEFAULT 'ouvert',
                           date_incident TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                           date_resolution TIMESTAMP NULL,
                           resolu_par INT NULL,
                           commentaire_resolution TEXT,
                           created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                           updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                           FOREIGN KEY (employe_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
                           FOREIGN KEY (cinema_id) REFERENCES cinemas(id) ON DELETE SET NULL,
                           FOREIGN KEY (salle_id) REFERENCES salles(id) ON DELETE SET NULL,
                           FOREIGN KEY (seance_id) REFERENCES seances(id) ON DELETE SET NULL,
                           FOREIGN KEY (resolu_par) REFERENCES utilisateurs(id) ON DELETE SET NULL,
                           INDEX idx_employe (employe_id),
                           INDEX idx_cinema (cinema_id),
                           INDEX idx_salle (salle_id),
                           INDEX idx_type (type_incident),
                           INDEX idx_statut (statut),
                           INDEX idx_priorite (priorite),
                           INDEX idx_date_incident (date_incident)
);

-- ============================================
-- VUES utiles pour l'application (MISES À JOUR)
-- ============================================

-- Vue pour les séances avec détails incluant le cinéma
CREATE VIEW v_seances_details AS
SELECT
    s.id,
    s.date_seance,
    s.heure_debut,
    s.heure_fin,
    s.prix,
    s.places_disponibles,
    s.places_vendues,
    s.statut,
    f.titre as film_titre,
    f.duree as film_duree,
    f.affiche as film_affiche,
    sal.nom as salle_nom,
    sal.capacite as salle_capacite,
    c.ville as cinema_ville,
    c.pays as cinema_pays,
    c.adresse as cinema_adresse
FROM seances s
         JOIN films f ON s.film_id = f.id
         JOIN salles sal ON s.salle_id = sal.id
         JOIN cinemas c ON sal.cinema_id = c.id;

-- Vue pour les réservations avec détails incluant le cinéma
CREATE VIEW v_reservations_details AS
SELECT
    r.id,
    r.numero_reservation,
    r.nb_places,
    r.prix_total,
    r.statut,
    r.date_reservation,
    r.qr_code,
    u.nom as client_nom,
    u.prenom as client_prenom,
    u.email as client_email,
    f.titre as film_titre,
    s.date_seance,
    s.heure_debut,
    sal.nom as salle_nom,
    c.ville as cinema_ville,
    c.adresse as cinema_adresse
FROM reservations r
         JOIN utilisateurs u ON r.utilisateur_id = u.id
         JOIN seances s ON r.seance_id = s.id
         JOIN films f ON s.film_id = f.id
         JOIN salles sal ON s.salle_id = sal.id
         JOIN cinemas c ON sal.cinema_id = c.id;

-- ============================================
-- TRIGGERS pour mettre à jour les moyennes (IDENTIQUES)
-- ============================================

DELIMITER //

CREATE TRIGGER update_film_note_moyenne
    AFTER INSERT ON avis
    FOR EACH ROW
BEGIN
    UPDATE films
    SET note_moyenne = (
        SELECT AVG(note)
        FROM avis
        WHERE film_id = NEW.film_id AND valide = TRUE
    )
    WHERE id = NEW.film_id;
END//

CREATE TRIGGER update_film_note_moyenne_update
    AFTER UPDATE ON avis
    FOR EACH ROW
BEGIN
    UPDATE films
    SET note_moyenne = (
        SELECT AVG(note)
        FROM avis
        WHERE film_id = NEW.film_id AND valide = TRUE
    )
    WHERE id = NEW.film_id;
END//

-- Trigger pour mettre à jour les places vendues
CREATE TRIGGER update_places_vendues
    AFTER INSERT ON reservations
    FOR EACH ROW
BEGIN
    IF NEW.statut = 'confirmee' THEN
        UPDATE seances
        SET places_vendues = places_vendues + NEW.nb_places,
            places_disponibles = places_disponibles - NEW.nb_places
        WHERE id = NEW.seance_id;
    END IF;
END//

CREATE TRIGGER update_places_vendues_update
    AFTER UPDATE ON reservations
    FOR EACH ROW
BEGIN
    IF OLD.statut != NEW.statut THEN
        IF NEW.statut = 'confirmee' AND OLD.statut != 'confirmee' THEN
            UPDATE seances
            SET places_vendues = places_vendues + NEW.nb_places,
                places_disponibles = places_disponibles - NEW.nb_places
            WHERE id = NEW.seance_id;
        ELSEIF OLD.statut = 'confirmee' AND NEW.statut != 'confirmee' THEN
            UPDATE seances
            SET places_vendues = places_vendues - NEW.nb_places,
                places_disponibles = places_disponibles + NEW.nb_places
            WHERE id = NEW.seance_id;
        END IF;
    END IF;
END//

DELIMITER ;

-- ============================================
-- CONFIGURATION FINALE
-- ============================================

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'Base de données Cinephoria avec gestion multi-cinémas créée avec succès !' as message;