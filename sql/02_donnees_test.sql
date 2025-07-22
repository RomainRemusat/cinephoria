-- ============================================
-- CINEPHORIA - Données de test
-- Projet CDA - Échéance : 22 juillet 2025
-- ============================================

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- DONNÉES : cinemas (NOUVEAU)
-- ============================================
INSERT INTO cinemas (ville, pays, adresse, code_postal, telephone, email, actif) VALUES
('Nantes', 'France', '12 Rue du Cinéma', '44000', '02 40 12 34 56', 'nantes@cinephoria.com', TRUE),
('Bordeaux', 'France', '34 Avenue des Stars', '33000', '05 56 12 34 56', 'bordeaux@cinephoria.com', TRUE),
('Paris', 'France', '56 Boulevard du Film', '75010', '01 42 12 34 56', 'paris@cinephoria.com', TRUE),
('Toulouse', 'France', '78 Rue des Réalisateurs', '31000', '05 61 12 34 56', 'toulouse@cinephoria.com', TRUE),
('Lille', 'France', '90 Rue des Acteurs', '59000', '03 20 12 34 56', 'lille@cinephoria.com', TRUE),
('Charleroi', 'Belgique', '23 Rue du Scénario', '6000', '+32 71 12 34 56', 'charleroi@cinephoria.com', TRUE),
('Liège', 'Belgique', '45 Avenue des Oscars', '4000', '+32 4 12 34 56', 'liege@cinephoria.com', TRUE);

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
-- DONNÉES : utilisateurs (MISE À JOUR)
-- ============================================
INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe, telephone, date_naissance, cinema_id, role, actif) VALUES
-- Administrateurs
(1, 'Dupont', 'Jean', 'admin@cinephoria.com', '$2y$10$kDAORV6KGd8AGy7BfZpEeOSN5pqKIlzb95S0lDJTkZsf/M1NRWc5O', '0123456789', '1980-05-15', 'admin', TRUE, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(2, 'Martin', 'Sophie', 'admin2@cinephoria.com', '$2y$10$zZswk.XMs0WLhteUi6CDyeuUN5qVxzTj9ZnvAsPleZ4IcGJOSBj72', '0123456788', '1985-03-22', 'admin', TRUE, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),

-- Employés
(3, 'Durand', 'Pierre', 'employe1@cinephoria.com', '$2y$10$yaebm7TAsmT5mt0c4VFXK.JEZHf1uyEyabmrY5pL2lNdxxj8fL9HG', '0123456787', '1990-08-10', 'employe', TRUE, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(4, 'Moreau', 'Marie', 'employe2@cinephoria.com', '$2y$10$ddS8qLgh.mKMuW7jzYItd.hfV223EtnZQcYljkdgS2ZaQn4WrFqfe', '0123456786', '1992-11-03', 'employe', TRUE, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(5, 'Petit', 'Lucas', 'employe3@cinephoria.com', '$2y$10$1EU0UEs/e5hPXgwHxA1BoOvyRTcfxmGwpCZNJO3VjkGkpkqfRxs6S', '0123456785', '1988-06-18', 'employe', TRUE, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),

-- Clients
(6, 'Leblanc', 'Julie', 'julie.leblanc@gmail.com', '$2y$10$PDJZp06TxrxoDnT7qQTO7OBBvEmLG0q1Y1/CSQz4s4iYgnmCVA65K', '0123456784', '1995-02-14', 'utilisateur', TRUE, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(7, 'Rousseau', 'Thomas', 'thomas.rousseau@gmail.com', '$2y$10$VaQAjCufms1RPvghoExbGukstLQRfIUmszpcHvkxUcl5LhcmOr5Sy', '0123456783', '1987-09-07', 'utilisateur', TRUE, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(8, 'Girard', 'Emma', 'emma.girard@gmail.com', '$2y$10$CgTxmCvYhkWj9u8f0SZEmuGbu6ShhePo.q1Pqn2i9oFH80THExEfK', '0123456782', '1993-12-25', 'utilisateur', TRUE, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(9, 'Roux', 'Alexandre', 'alex.roux@gmail.com', '$2y$10$0uOAZvkvYlTE6xWpehdT.O0dpfFWvq1lgo3tSkgSSU8rhWZ1r/CWm', '0123456781', '1991-04-12', 'utilisateur', TRUE, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(10, 'Faure', 'Camille', 'camille.faure@gmail.com', '$2y$10$BHbCvViGTLTjR1xHz0mceeMsGvtyYFNRgBi8ptOMymYSzrUjKtzti', '0123456780', '1996-07-30', 'utilisateur', TRUE, '2025-07-22 13:30:15', '2025-07-22 13:30:15');

-- ============================================
-- DONNÉES : salles (MISE À JOUR avec rattachement)
-- ============================================
-- Cinéma Nantes (id=1)
INSERT INTO salles (cinema_id, nom, capacite, type_salle, equipements) VALUES
(1, 'Salle 1', 150, 'standard', '{"son": "Dolby Digital", "ecran": "Standard", "climatisation": true}'),
(1, 'Salle 2', 200, 'premium', '{"son": "Dolby Atmos", "ecran": "4K", "climatisation": true, "sieges": "cuir"}'),
(1, 'Salle IMAX', 300, 'imax', '{"son": "IMAX", "ecran": "IMAX", "climatisation": true, "sieges": "premium"}'),

-- Cinéma Bordeaux (id=2)
(2, 'Salle A', 120, 'standard', '{"son": "Dolby Digital", "ecran": "Standard", "climatisation": true}'),
(2, 'Salle B', 180, 'premium', '{"son": "Dolby Atmos", "ecran": "4K", "climatisation": true, "sieges": "cuir"}'),

-- Cinéma Paris (id=3)
(3, 'Salle Alpha', 100, 'standard', '{"son": "Dolby Digital", "ecran": "Standard", "climatisation": true}'),
(3, 'Salle Beta', 250, 'imax', '{"son": "IMAX", "ecran": "IMAX", "climatisation": true, "sieges": "premium"}'),
(3, 'Salle Gamma', 140, 'premium', '{"son": "Dolby Atmos", "ecran": "4K", "climatisation": true, "sieges": "cuir"}'),

-- Cinéma Toulouse (id=4)
(4, 'Salle Rouge', 110, 'standard', '{"son": "Dolby Digital", "ecran": "Standard", "climatisation": true}'),
(4, 'Salle Bleue', 160, 'premium', '{"son": "Dolby Atmos", "ecran": "4K", "climatisation": true, "sieges": "cuir"}'),

-- Cinéma Charleroi (id=6)
(6, 'Salle Principale', 130, 'standard', '{"son": "Dolby Digital", "ecran": "Standard", "climatisation": true}'),
(6, 'Salle VIP', 80, 'premium', '{"son": "Dolby Atmos", "ecran": "4K", "climatisation": true, "sieges": "cuir", "service": "VIP"}');

-- ============================================
-- DONNÉES : films (IDENTIQUES)
-- ============================================
INSERT INTO films (titre, titre_original, description, synopsis, duree, date_sortie, realisateur, acteurs, categorie_id, age_minimum, affiche, bande_annonce, statut) VALUES
-- Films en cours
('Amélie', 'Le Fabuleux Destin d''Amélie Poulain', 'Comédie romantique française culte', 'Amélie, une jeune serveuse dans un bar de Montmartre, passe son temps à observer les gens et à laisser son imagination divaguer.', 122, '2001-04-25', 'Jean-Pierre Jeunet', 'Audrey Tautou, Mathieu Kassovitz', 6, 0, 'amelie.jpg', 'amelie_trailer.mp4', 'en_cours'),

('Avatar: La Voie de l''eau', 'Avatar: The Way of Water', 'Suite épique de science-fiction', 'Plus d''une décennie après les événements du premier film, Avatar : La Voie de l''eau raconte l''histoire de la famille Sully.', 192, '2022-12-14', 'James Cameron', 'Sam Worthington, Zoe Saldana', 4, 10, 'avatar2.jpg', 'avatar2_trailer.mp4', 'en_cours'),

('Être et avoir', 'Être et avoir', 'Documentaire sur l''école rurale', 'Dans une classe unique d''une école de campagne, nous découvrons une année scolaire auprès d''enfants âgés de 4 à 10 ans.', 104, '2002-08-28', 'Nicolas Philibert', 'Georges Lopez', 7, 0, 'etre_avoir.jpg', 'etre_avoir_trailer.mp4', 'en_cours'),

('Dune', 'Dune', 'Épopée de science-fiction', 'L''histoire de Paul Atreides, jeune homme aussi doué que brillant, voué à connaître un destin hors du commun.', 155, '2021-10-22', 'Denis Villeneuve', 'Timothée Chalamet, Rebecca Ferguson', 4, 12, 'dune.jpg', 'dune_trailer.mp4', 'en_cours'),

('Spider-Man: No Way Home', 'Spider-Man: No Way Home', 'Super-héros multivers', 'Pour la première fois dans l''histoire cinématographique de Spider-Man, notre héros est démasqué.', 148, '2021-12-15', 'Jon Watts', 'Tom Holland, Zendaya', 1, 10, 'spiderman.jpg', 'spiderman_trailer.mp4', 'en_cours'),

-- Films à venir
('Oppenheimer', 'Oppenheimer', 'Biopic historique', 'L''histoire du scientifique J. Robert Oppenheimer et de son rôle dans le développement de la bombe atomique.', 180, '2023-07-21', 'Christopher Nolan', 'Cillian Murphy, Emily Blunt', 3, 12, 'oppenheimer.jpg', 'oppenheimer_trailer.mp4', 'a_venir'),

('Barbie', 'Barbie', 'Comédie fantastique', 'Barbie vit dans le monde coloré et apparemment parfait de Barbie Land.', 114, '2023-07-21', 'Greta Gerwig', 'Margot Robbie, Ryan Gosling', 2, 6, 'barbie.jpg', 'barbie_trailer.mp4', 'a_venir');

-- ============================================
-- DONNÉES : seances (DISTRIBUTION MULTI-CINÉMAS)
-- ============================================
-- Séances Nantes (salles 1, 2, 3)
INSERT INTO seances (film_id, salle_id, date_seance, heure_debut, heure_fin, prix, places_disponibles) VALUES
(1, 1, '2025-07-25', '14:00:00', '16:02:00', 9.50, 150), -- Amélie Nantes
(1, 1, '2025-07-25', '18:00:00', '20:02:00', 9.50, 150),
(2, 3, '2025-07-25', '14:30:00', '17:42:00', 14.00, 300), -- Avatar Nantes IMAX
(2, 3, '2025-07-25', '18:15:00', '21:27:00', 14.00, 300),

-- Séances Bordeaux (salles 4, 5)
(3, 4, '2025-07-25', '16:00:00', '17:44:00', 8.50, 120), -- Être et avoir Bordeaux
(4, 5, '2025-07-25', '15:00:00', '17:35:00', 11.00, 180), -- Dune Bordeaux Premium

-- Séances Paris (salles 6, 7, 8)
(5, 6, '2025-07-25', '17:00:00', '19:28:00', 12.00, 100), -- Spider-Man Paris
(1, 8, '2025-07-25', '19:30:00', '21:32:00', 10.00, 140), -- Amélie Paris Premium

-- Séances Toulouse (salles 9, 10)
(2, 9, '2025-07-26', '14:00:00', '17:12:00', 13.50, 110), -- Avatar Toulouse
(4, 10, '2025-07-26', '20:00:00', '22:35:00', 11.50, 160), -- Dune Toulouse Premium

-- Séances weekend multi-cinémas
(1, 11, '2025-07-27', '14:00:00', '16:02:00', 9.00, 130), -- Amélie Charleroi
(2, 12, '2025-07-27', '15:30:00', '18:42:00', 13.00, 80); -- Avatar Charleroi VIP

-- ============================================
-- DONNÉES : reservations (MISE À JOUR)
-- ============================================
INSERT INTO reservations (numero_reservation, utilisateur_id, seance_id, nb_places, prix_total, statut, methode_paiement, qr_code) VALUES
('RES001', 8, 1, 2, 19.00, 'confirmee', 'carte', 'QR_RES001_2025'), -- Julie Nantes
('RES002', 9, 2, 1, 9.50, 'confirmee', 'paypal', 'QR_RES002_2025'), -- Thomas Nantes
('RES003', 10, 4, 3, 42.00, 'confirmee', 'carte', 'QR_RES003_2025'), -- Emma Nantes
('RES004', 11, 5, 2, 17.00, 'confirmee', 'carte', 'QR_RES004_2025'), -- Alexandre Bordeaux
('RES005', 12, 6, 1, 11.00, 'en_attente', 'carte', NULL), -- Camille Bordeaux
('RES006', 8, 8, 2, 20.00, 'confirmee', 'carte', 'QR_RES006_2025'), -- Julie Paris
('RES007', 9, 9, 1, 13.50, 'confirmee', 'paypal', 'QR_RES007_2025'), -- Thomas Toulouse
('RES008', 10, 11, 4, 36.00, 'confirmee', 'carte', 'QR_RES008_2025'); -- Emma Charleroi

-- ============================================
-- DONNÉES : avis (IDENTIQUES)
-- ============================================
INSERT INTO avis (utilisateur_id, film_id, note, commentaire, valide) VALUES
(8, 1, 5, 'Film magnifique ! Une poésie visuelle extraordinaire.', TRUE),
(9, 1, 4, 'Très bon film français, Audrey Tautou est formidable.', TRUE),
(10, 2, 4, 'Visuellement époustouflant mais un peu long.', TRUE),
(11, 2, 5, 'Avatar 2 est un chef-d''œuvre technique !', TRUE),
(12, 3, 4, 'Documentaire touchant sur l''éducation.', TRUE),
(8, 4, 5, 'Denis Villeneuve a réussi son adaptation de Dune.', TRUE),
(9, 4, 4, 'Excellent film de science-fiction.', TRUE),
(10, 5, 3, 'Bon divertissement mais sans plus.', TRUE);

-- ============================================
-- DONNÉES : incidents (MISE À JOUR avec cinémas)
-- ============================================
INSERT INTO incidents (employe_id, cinema_id, salle_id, seance_id, type_incident, titre, description, priorite, statut, resolu_par, commentaire_resolution) VALUES
(3, 1, 1, 1, 'technique', 'Problème de son', 'Le son de la salle 1 grésille pendant la séance Amélie de 14h', 'haute', 'resolu', 3, 'Remplacement du système audio'),
(4, 2, 4, NULL, 'maintenance', 'Nettoyage écran', 'Écran de la salle A nécessite un nettoyage approfondi', 'basse', 'ouvert', NULL, NULL),
(5, 3, 7, 4, 'technique', 'Panne projecteur', 'Le projecteur IMAX s''est éteint pendant la séance Avatar', 'critique', 'en_cours', NULL, NULL),
(3, 1, NULL, NULL, 'securite', 'Sortie de secours bloquée', 'Une sortie de secours du cinéma de Nantes est obstruée', 'moyenne', 'ouvert', NULL, NULL),
(6, 6, 12, NULL, 'maintenance', 'Remplacement ampoules', 'Plusieurs ampoules de la salle VIP sont grillées', 'basse', 'ouvert', NULL, NULL),
(4, 2, 5, 6, 'technique', 'Problème climatisation', 'La climatisation de la salle B ne fonctionne plus', 'haute', 'en_cours', NULL, NULL);

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
('RES009', 11, 3, 1, 9.50, 'annulee', 'carte', '2025-07-24 10:30:00'),
('RES010', 12, 7, 2, 25.00, 'annulee', 'paypal', '2025-07-24 15:45:00');

-- ============================================
-- PROCÉDURES STOCKÉES UTILES (IDENTIQUES)
-- ============================================

DROP PROCEDURE IF EXISTS GenerateReservationNumber;
DROP PROCEDURE IF EXISTS GetChiffreAffaires;
DROP PROCEDURE IF EXISTS GetFilmStats;
DROP PROCEDURE IF EXISTS GetCinemaStats;

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
        c.ville as cinema_ville,
        DATE(s.date_seance) as date_seance,
        COUNT(r.id) as nb_reservations,
        SUM(r.prix_total) as chiffre_affaires,
        AVG(r.prix_total) as panier_moyen
    FROM reservations r
             JOIN seances s ON r.seance_id = s.id
             JOIN salles sal ON s.salle_id = sal.id
             JOIN cinemas c ON sal.cinema_id = c.id
    WHERE s.date_seance BETWEEN date_debut AND date_fin
      AND r.statut = 'confirmee'
    GROUP BY c.id, DATE(s.date_seance)
    ORDER BY c.ville, date_seance;
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
        COUNT(DISTINCT a.id) as nb_avis,
        COUNT(DISTINCT c.id) as nb_cinemas_diffusion
    FROM films f
             LEFT JOIN seances s ON f.id = s.film_id
             LEFT JOIN reservations r ON s.id = r.seance_id AND r.statut = 'confirmee'
             LEFT JOIN avis a ON f.id = a.film_id AND a.valide = TRUE
             LEFT JOIN salles sal ON s.salle_id = sal.id
             LEFT JOIN cinemas c ON sal.cinema_id = c.id
    WHERE f.id = film_id
    GROUP BY f.id;
END//

CREATE PROCEDURE GetCinemaStats(IN cinema_id INT)
BEGIN
    SELECT
        c.ville as cinema_ville,
        c.pays as cinema_pays,
        COUNT(DISTINCT sal.id) as nb_salles,
        SUM(sal.capacite) as capacite_totale,
        COUNT(DISTINCT s.id) as nb_seances_programmees,
        COUNT(DISTINCT r.id) as nb_reservations,
        SUM(r.nb_places) as total_places_vendues,
        SUM(r.prix_total) as chiffre_affaires_total,
        COUNT(DISTINCT i.id) as nb_incidents_ouverts
    FROM cinemas c
             LEFT JOIN salles sal ON c.id = sal.cinema_id
             LEFT JOIN seances s ON sal.id = s.salle_id
             LEFT JOIN reservations r ON s.id = r.seance_id AND r.statut = 'confirmee'
             LEFT JOIN incidents i ON c.id = i.cinema_id AND i.statut IN ('ouvert', 'en_cours')
    WHERE c.id = cinema_id
    GROUP BY c.id;
END//

DELIMITER ;

-- ============================================
-- CONFIGURATION FINALE
-- ============================================

SET FOREIGN_KEY_CHECKS = 1;

OPTIMIZE TABLE cinemas, utilisateurs, films, seances, reservations, avis, incidents, salles, categories;
ANALYZE TABLE cinemas, utilisateurs, films, seances, reservations, avis, incidents, salles, categories;

SELECT 'Données de test Cinephoria multi-cinémas insérées avec succès !' as message;

-- ============================================
-- STATISTIQUES FINALES
-- ============================================

SELECT
    'Résumé des données insérées :' as titre,
    (SELECT COUNT(*) FROM cinemas) as nb_cinemas,
    (SELECT COUNT(*) FROM utilisateurs) as nb_utilisateurs,
    (SELECT COUNT(*) FROM films) as nb_films,
    (SELECT COUNT(*) FROM salles) as nb_salles,
    (SELECT COUNT(*) FROM seances) as nb_seances,
    (SELECT COUNT(*) FROM reservations) as nb_reservations,
    (SELECT COUNT(*) FROM avis) as nb_avis,
    (SELECT COUNT(*) FROM incidents) as nb_incidents,
    (SELECT COUNT(*) FROM categories) as nb_categories;