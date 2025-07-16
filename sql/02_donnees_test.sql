-- ============================================
-- CINEPHORIA - Données de test
-- Projet CDA - Échéance : 22 juillet 2025
-- ============================================

-- Désactiver les vérifications de clés étrangères temporairement
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- DONNÉES : categories
-- ============================================
INSERT INTO categories (nom, description) VALUES
('Action', 'Films d''action et d''aventure'),
('Comédie', 'Films humoristiques et comiques'),
('Drame', 'Films dramatiques et émouvants'),
('Science-fiction', 'Films de science-fiction et futuristes'),
('Horreur', 'Films d''horreur et de suspense'),
('Romance', 'Films romantiques'),
('Documentaire', 'Films documentaires et éducatifs'),
('Animation', 'Films d''animation pour tous âges'),
('Thriller', 'Films de suspense et de tension'),
('Fantastique', 'Films fantastiques et magiques');

-- ============================================
-- DONNÉES : utilisateurs
-- ============================================
INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe, telephone, date_naissance, role, actif) VALUES
-- Administrateurs
('Dupont', 'Jean', 'admin@cinephoria.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0123456789', '1980-05-15', 'admin', TRUE),
('Martin', 'Sophie', 'admin2@cinephoria.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0123456788', '1985-03-22', 'admin', TRUE),

-- Employés
('Durand', 'Pierre', 'employe1@cinephoria.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0123456787', '1990-08-10', 'employe', TRUE),
('Moreau', 'Marie', 'employe2@cinephoria.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0123456786', '1992-11-03', 'employe', TRUE),
('Petit', 'Lucas', 'employe3@cinephoria.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0123456785', '1988-06-18', 'employe', TRUE),

-- Clients
('Leblanc', 'Julie', 'julie.leblanc@gmail.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0123456784', '1995-02-14', 'utilisateur', TRUE),
('Rousseau', 'Thomas', 'thomas.rousseau@gmail.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0123456783', '1987-09-07', 'utilisateur', TRUE),
('Girard', 'Emma', 'emma.girard@gmail.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0123456782', '1993-12-25', 'utilisateur', TRUE),
('Roux', 'Alexandre', 'alex.roux@gmail.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0123456781', '1991-04-12', 'utilisateur', TRUE),
('Faure', 'Camille', 'camille.faure@gmail.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0123456780', '1996-07-30', 'utilisateur', TRUE);

-- ============================================
-- DONNÉES : salles
-- ============================================
INSERT INTO salles (nom, capacite, type_salle, equipements) VALUES
('Salle 1', 150, 'standard', '{"son": "Dolby Digital", "ecran": "Standard", "climatisation": true}'),
('Salle 2', 200, 'premium', '{"son": "Dolby Atmos", "ecran": "4K", "climatisation": true, "sieges": "cuir"}'),
('Salle 3', 100, 'standard', '{"son": "Dolby Digital", "ecran": "Standard", "climatisation": true}'),
('Salle IMAX', 300, 'imax', '{"son": "IMAX", "ecran": "IMAX", "climatisation": true, "sieges": "premium"}'),
('Salle 5', 80, 'standard', '{"son": "Dolby Digital", "ecran": "Standard", "climatisation": true}'),
('Salle Premium', 120, 'premium', '{"son": "Dolby Atmos", "ecran": "4K", "climatisation": true, "sieges": "cuir", "service": "VIP"}');

-- ============================================
-- DONNÉES : films
-- ============================================
INSERT INTO films (titre, titre_original, description, synopsis, duree, date_sortie, realisateur, acteurs, categorie_id, age_minimum, affiche, bande_annonce, statut) VALUES
-- Films en cours
('Amélie', 'Le Fabuleux Destin d''Amélie Poulain', 'Comédie romantique française culte', 'Amélie, une jeune serveuse dans un bar de Montmartre, passe son temps à observer les gens et à laisser son imagination divaguer. Elle s''est fixé un but : faire le bien de ceux qui l''entourent.', 122, '2001-04-25', 'Jean-Pierre Jeunet', 'Audrey Tautou, Mathieu Kassovitz', 6, 0, 'amelie.jpg', 'amelie_trailer.mp4', 'en_cours'),

('Avatar: La Voie de l''eau', 'Avatar: The Way of Water', 'Suite épique de science-fiction', 'Plus d''une décennie après les événements du premier film, Avatar : La Voie de l''eau raconte l''histoire de la famille Sully, les dangers qui les poursuivent...', 192, '2022-12-14', 'James Cameron', 'Sam Worthington, Zoe Saldana', 4, 10, 'avatar2.jpg', 'avatar2_trailer.mp4', 'en_cours'),

('Être et avoir', 'Être et avoir', 'Documentaire sur l''école rurale', 'Dans une classe unique d''une école de campagne, nous découvrons une année scolaire auprès d''enfants âgés de 4 à 10 ans...', 104, '2002-08-28', 'Nicolas Philibert', 'Georges Lopez', 7, 0, 'etre_avoir.jpg', 'etre_avoir_trailer.mp4', 'en_cours'),

('Dune', 'Dune', 'Épopée de science-fiction', 'L''histoire de Paul Atreides, jeune homme aussi doué que brillant, voué à connaître un destin hors du commun...', 155, '2021-10-22', 'Denis Villeneuve', 'Timothée Chalamet, Rebecca Ferguson', 4, 12, 'dune.jpg', 'dune_trailer.mp4', 'en_cours'),

('Spider-Man: No Way Home', 'Spider-Man: No Way Home', 'Super-héros multivers', 'Pour la première fois dans l''histoire cinématographique de Spider-Man, notre héros est démasqué...', 148, '2021-12-15', 'Jon Watts', 'Tom Holland, Zendaya', 1, 10, 'spiderman.jpg', 'spiderman_trailer.mp4', 'en_cours'),

-- Films à venir
('Oppenheimer', 'Oppenheimer', 'Biopic historique', 'L''histoire du scientifique J. Robert Oppenheimer et de son rôle dans le développement de la bombe atomique.', 180, '2023-07-21', 'Christopher Nolan', 'Cillian Murphy, Emily Blunt', 3, 12, 'oppenheimer.jpg', 'oppenheimer_trailer.mp4', 'a_venir'),

('Barbie', 'Barbie', 'Comédie fantastique', 'Barbie vit dans le monde coloré et apparemment parfait de Barbie Land...', 114, '2023-07-21', 'Greta Gerwig', 'Margot Robbie, Ryan Gosling', 2, 6, 'barbie.jpg', 'barbie_trailer.mp4', 'a_venir'),

('Indiana Jones 5', 'Indiana Jones and the Dial of Destiny', 'Aventure archéologique', 'Le légendaire héros revient pour une dernière aventure...', 142, '2023-06-30', 'James Mangold', 'Harrison Ford, Phoebe Waller-Bridge', 1, 10, 'indiana5.jpg', 'indiana5_trailer.mp4', 'a_venir');

-- ============================================
-- DONNÉES : seances
-- ============================================
INSERT INTO seances (film_id, salle_id, date_seance, heure_debut, heure_fin, prix, places_disponibles) VALUES
-- Séances pour aujourd'hui et demain
(1, 1, '2025-07-25', '14:00:00', '16:02:00', 9.50, 150),
(1, 1, '2025-07-25', '18:00:00', '20:02:00', 9.50, 150),
(1, 1, '2025-07-25', '20:30:00', '22:32:00', 9.50, 150),

(2, 4, '2025-07-25', '14:30:00', '17:42:00', 14.00, 300),
(2, 4, '2025-07-25', '18:15:00', '21:27:00', 14.00, 300),
(2, 4, '2025-07-25', '21:45:00', '00:57:00', 14.00, 300),

(3, 3, '2025-07-25', '16:00:00', '17:44:00', 8.50, 100),
(3, 3, '2025-07-25', '19:00:00', '20:44:00', 8.50, 100),

(4, 2, '2025-07-25', '15:00:00', '17:35:00', 11.00, 200),
(4, 2, '2025-07-25', '19:30:00', '22:05:00', 11.00, 200),

(5, 6, '2025-07-25', '17:00:00', '19:28:00', 12.00, 120),
(5, 6, '2025-07-25', '20:00:00', '22:28:00', 12.00, 120),

-- Séances pour demain
(1, 5, '2025-07-26', '14:00:00', '16:02:00', 9.50, 80),
(1, 5, '2025-07-26', '18:00:00', '20:02:00', 9.50, 80),

(2, 4, '2025-07-26', '15:00:00', '18:12:00', 14.00, 300),
(2, 4, '2025-07-26', '19:00:00', '22:12:00', 14.00, 300),

(4, 1, '2025-07-26', '16:30:00', '19:05:00', 11.00, 150),
(4, 1, '2025-07-26', '20:15:00', '22:50:00', 11.00, 150),

-- Séances weekend
(1, 2, '2025-07-27', '14:00:00', '16:02:00', 9.50, 200),
(2, 4, '2025-07-27', '15:30:00', '18:42:00', 14.00, 300),
(3, 3, '2025-07-27', '17:00:00', '18:44:00', 8.50, 100),
(4, 6, '2025-07-27', '19:00:00', '21:35:00', 11.00, 120),
(5, 1, '2025-07-27', '21:00:00', '23:28:00', 12.00, 150);

-- ============================================
-- DONNÉES : reservations
-- ============================================
INSERT INTO reservations (numero_reservation, utilisateur_id, seance_id, nb_places, prix_total, statut, methode_paiement, qr_code) VALUES
('RES001', 6, 1, 2, 19.00, 'confirmee', 'carte', 'QR_RES001_2025'),
('RES002', 7, 2, 1, 9.50, 'confirmee', 'paypal', 'QR_RES002_2025'),
('RES003', 8, 4, 3, 42.00, 'confirmee', 'carte', 'QR_RES003_2025'),
('RES004', 9, 7, 2, 17.00, 'confirmee', 'carte', 'QR_RES004_2025'),
('RES005', 10, 9, 1, 11.00, 'en_attente', 'carte', NULL),
('RES006', 6, 11, 2, 24.00, 'confirmee', 'carte', 'QR_RES006_2025'),
('RES007', 7, 13, 1, 9.50, 'confirmee', 'paypal', 'QR_RES007_2025'),
('RES008', 8, 15, 4, 56.00, 'confirmee', 'carte', 'QR_RES008_2025');

-- ============================================
-- DONNÉES : avis
-- ============================================
INSERT INTO avis (utilisateur_id, film_id, note, commentaire, valide) VALUES
(6, 1, 5, 'Film magnifique ! Une poésie visuelle extraordinaire.', TRUE),
(7, 1, 4, 'Très bon film français, Audrey Tautou est formidable.', TRUE),
(8, 2, 4, 'Visuellement époustouflant mais un peu long.', TRUE),
(9, 2, 5, 'Avatar 2 est un chef-d''œuvre technique !', TRUE),
(10, 3, 4, 'Documentaire touchant sur l''éducation.', TRUE),
(6, 4, 5, 'Denis Villeneuve a réussi son adaptation de Dune.', TRUE),
(7, 4, 4, 'Excellent film de science-fiction.', TRUE),
(8, 5, 3, 'Bon divertissement mais sans plus.', TRUE);

-- ============================================
-- DONNÉES : incidents
-- ============================================
INSERT INTO incidents (employe_id, salle_id, seance_id, type_incident, titre, description, priorite, statut) VALUES
(3, 1, 1, 'technique', 'Problème de son', 'Le son de la salle 1 grésille pendant la séance Amélie de 14h', 'haute', 'resolu'),
(4, 2, NULL, 'maintenance', 'Nettoyage écran', 'Écran de la salle 2 nécessite un nettoyage approfondi', 'basse', 'ouvert'),
(5, 4, 4, 'technique', 'Panne projecteur', 'Le projecteur IMAX s''est éteint pendant la séance Avatar', 'critique', 'en_cours'),
(3, 3, NULL, 'securite', 'Sortie de secours bloquée', 'Une sortie de secours de la salle 3 est obstruée', 'moyenne', 'ouvert'),
(4, 6, NULL, 'maintenance', 'Remplacement ampoules', 'Plusieurs ampoules de la salle Premium sont grillées', 'basse', 'ouvert'),
(5, 2, 10, 'technique', 'Problème climatisation', 'La climatisation de la salle 2 ne fonctionne plus', 'haute', 'en_cours');

-- ============================================
-- MISE À JOUR DES COMPTEURS
-- ============================================

-- Mettre à jour les places vendues pour les réservations confirmées
UPDATE seances s
SET places_vendues = (
    SELECT COALESCE(SUM(r.nb_places), 0)
    FROM reservations r
    WHERE r.seance_id = s.id AND r.statut = 'confirmee'
),
    places_disponibles = (
        SELECT sal.capacite - COALESCE(SUM(r.nb_places), 0)
        FROM salles sal
                 LEFT JOIN reservations r ON r.seance_id = s.id AND r.statut = 'confirmee'
        WHERE sal.id = s.salle_id
    )
WHERE EXISTS (
    SELECT 1 FROM reservations r
    WHERE r.seance_id = s.id AND r.statut = 'confirmee'
);

-- Correction pour utiliser la capacité de la salle
UPDATE seances s
    JOIN salles sal ON s.salle_id = sal.id
SET s.places_disponibles = sal.capacite - s.places_vendues
WHERE s.places_disponibles != (sal.capacite - s.places_vendues);

-- Mettre à jour les notes moyennes des films
UPDATE films f
SET note_moyenne = (
    SELECT AVG(a.note)
    FROM avis a
    WHERE a.film_id = f.id AND a.valide = TRUE
)
WHERE EXISTS (
    SELECT 1 FROM avis a
    WHERE a.film_id = f.id AND a.valide = TRUE
);

-- ============================================
-- DONNÉES SUPPLÉMENTAIRES POUR LES TESTS
-- ============================================

-- Quelques réservations annulées pour tester
INSERT INTO reservations (numero_reservation, utilisateur_id, seance_id, nb_places, prix_total, statut, methode_paiement, date_annulation) VALUES
('RES009', 9, 3, 1, 9.50, 'annulee', 'carte', '2025-07-24 10:30:00'),
('RES010', 10, 6, 2, 28.00, 'annulee', 'paypal', '2025-07-24 15:45:00');

-- ============================================
-- PROCÉDURES STOCKÉES UTILES
-- ============================================

-- Supprimer les procédures existantes avant recréation
DROP PROCEDURE IF EXISTS GenerateReservationNumber;
DROP PROCEDURE IF EXISTS GetChiffreAffaires;
DROP PROCEDURE IF EXISTS GetFilmStats;

DELIMITER //

-- Procédure pour générer un numéro de réservation unique
CREATE PROCEDURE GenerateReservationNumber(OUT reservation_number VARCHAR(20))
BEGIN
    DECLARE current_year INT;
    DECLARE current_month INT;
    DECLARE counter INT;

    SET current_year = YEAR(NOW());
    SET current_month = MONTH(NOW());

    SELECT COALESCE(MAX(CAST(SUBSTRING(numero_reservation, 8) AS UNSIGNED)), 0) + 1
    INTO counter
    FROM reservations
    WHERE YEAR(created_at) = current_year AND MONTH(created_at) = current_month;

    SET reservation_number = CONCAT('RES', current_year, LPAD(current_month, 2, '0'), LPAD(counter, 3, '0'));
END//

-- Procédure pour calculer le chiffre d'affaires par période
CREATE PROCEDURE GetChiffreAffaires(IN date_debut DATE, IN date_fin DATE)
BEGIN
    SELECT
        DATE(s.date_seance) as date_seance,
        COUNT(r.id) as nb_reservations,
        SUM(r.prix_total) as chiffre_affaires,
        AVG(r.prix_total) as panier_moyen
    FROM reservations r
             JOIN seances s ON r.seance_id = s.id
    WHERE s.date_seance BETWEEN date_debut AND date_fin
      AND r.statut = 'confirmee'
    GROUP BY DATE(s.date_seance)
    ORDER BY date_seance;
END//

-- Procédure pour obtenir les statistiques d'un film
CREATE PROCEDURE GetFilmStats(IN film_id INT)
BEGIN
    SELECT
        f.titre,
        f.note_moyenne,
        COUNT(DISTINCT s.id) as nb_seances,
        COUNT(DISTINCT r.id) as nb_reservations,
        SUM(r.nb_places) as total_places_vendues,
        SUM(r.prix_total) as recette_totale,
        COUNT(DISTINCT a.id) as nb_avis
    FROM films f
             LEFT JOIN seances s ON f.id = s.film_id
             LEFT JOIN reservations r ON s.id = r.seance_id AND r.statut = 'confirmee'
             LEFT JOIN avis a ON f.id = a.film_id AND a.valide = TRUE
    WHERE f.id = film_id
    GROUP BY f.id;
END//

DELIMITER ;

-- ============================================
-- DONNÉES POUR MONGODB (statistiques)
-- ============================================

-- Note: Ces données seront insérées via l'application PHP
-- Exemple de structure pour MongoDB :
/*
{
    "_id": ObjectId("..."),
    "date": ISODate("2025-07-25"),
    "reservations": {
        "total": 8,
        "confirmees": 6,
        "annulees": 2,
        "en_attente": 1
    },
    "chiffre_affaires": {
        "total": 198.50,
        "par_salle": {
            "Salle 1": 48.00,
            "Salle 2": 22.00,
            "Salle IMAX": 84.00,
            "Salle Premium": 44.50
        }
    },
    "frequentation": {
        "total_places_vendues": 15,
        "taux_occupation": 0.68
    },
    "films_populaires": [
        {"film_id": 2, "titre": "Avatar 2", "reservations": 3},
        {"film_id": 1, "titre": "Amélie", "reservations": 2}
    ]
}
*/

-- ============================================
-- CONFIGURATION FINALE
-- ============================================

-- Réactiver les vérifications de clés étrangères
SET FOREIGN_KEY_CHECKS = 1;

-- Optimiser les tables
OPTIMIZE TABLE utilisateurs, films, seances, reservations, avis, incidents, salles, categories;

-- Analyser les tables pour les statistiques
ANALYZE TABLE utilisateurs, films, seances, reservations, avis, incidents, salles, categories;

-- Message de confirmation
SELECT 'Données de test Cinephoria insérées avec succès !' as message;
SELECT 'Utilisateurs créés : cinephoria_app et cinephoria_readonly' as info;

-- ============================================
-- STATISTIQUES FINALES
-- ============================================

SELECT
    'Résumé des données insérées :' as titre,
    (SELECT COUNT(*) FROM utilisateurs) as nb_utilisateurs,
    (SELECT COUNT(*) FROM films) as nb_films,
    (SELECT COUNT(*) FROM seances) as nb_seances,
    (SELECT COUNT(*) FROM reservations) as nb_reservations,
    (SELECT COUNT(*) FROM avis) as nb_avis,
    (SELECT COUNT(*) FROM incidents) as nb_incidents,
    (SELECT COUNT(*) FROM salles) as nb_salles,
    (SELECT COUNT(*) FROM categories) as nb_categories;