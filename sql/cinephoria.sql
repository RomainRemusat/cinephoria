-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : mer. 28 jan. 2026 à 19:01
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `cinephoria`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GenerateReservationNumber` (OUT `reservation_number` VARCHAR(20))   BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetChiffreAffaires` (IN `date_debut` DATE, IN `date_fin` DATE)   BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCinemaStats` (IN `cinema_id` INT)   BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFilmStats` (IN `film_id` INT)   BEGIN
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
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `avis`
--

CREATE TABLE `avis` (
  `id` int(11) NOT NULL,
  `utilisateur_id` int(11) NOT NULL,
  `film_id` int(11) NOT NULL,
  `note` int(11) NOT NULL CHECK (`note` >= 1 and `note` <= 5),
  `commentaire` text DEFAULT NULL,
  `valide` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `avis`
--

INSERT INTO `avis` (`id`, `utilisateur_id`, `film_id`, `note`, `commentaire`, `valide`, `created_at`, `updated_at`) VALUES
(1, 8, 1, 5, 'Film magnifique ! Une poésie visuelle extraordinaire.', 1, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(2, 9, 1, 4, 'Très bon film français, Audrey Tautou est formidable.', 1, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(3, 10, 2, 4, 'Visuellement époustouflant mais un peu long.', 1, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(4, 11, 2, 5, 'Avatar 2 est un chef-d\'œuvre technique !', 1, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(5, 12, 3, 4, 'Documentaire touchant sur l\'éducation.', 1, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(6, 8, 4, 5, 'Denis Villeneuve a réussi son adaptation de Dune.', 1, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(7, 9, 4, 4, 'Excellent film de science-fiction.', 1, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(8, 10, 5, 3, 'Bon divertissement mais sans plus.', 1, '2025-07-22 13:30:15', '2025-07-22 13:30:15');

--
-- Déclencheurs `avis`
--
DELIMITER $$
CREATE TRIGGER `update_film_note_moyenne` AFTER INSERT ON `avis` FOR EACH ROW BEGIN
    UPDATE films
    SET note_moyenne = (
        SELECT AVG(note)
        FROM avis
        WHERE film_id = NEW.film_id AND valide = TRUE
    )
    WHERE id = NEW.film_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_film_note_moyenne_update` AFTER UPDATE ON `avis` FOR EACH ROW BEGIN
    UPDATE films
    SET note_moyenne = (
        SELECT AVG(note)
        FROM avis
        WHERE film_id = NEW.film_id AND valide = TRUE
    )
    WHERE id = NEW.film_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `categories`
--

INSERT INTO `categories` (`id`, `nom`, `description`, `created_at`) VALUES
(1, 'Action', 'Films d\'action et d\'aventure', '2025-07-22 13:30:15'),
(2, 'Comédie', 'Films humoristiques et comiques', '2025-07-22 13:30:15'),
(3, 'Drame', 'Films dramatiques et émouvants', '2025-07-22 13:30:15'),
(4, 'Science-fiction', 'Films de science-fiction et futuristes', '2025-07-22 13:30:15'),
(5, 'Horreur', 'Films d\'horreur et de suspense', '2025-07-22 13:30:15'),
(6, 'Romance', 'Films romantiques', '2025-07-22 13:30:15'),
(7, 'Documentaire', 'Films documentaires et éducatifs', '2025-07-22 13:30:15'),
(8, 'Animation', 'Films d\'animation pour tous âges', '2025-07-22 13:30:15'),
(9, 'Thriller', 'Films de suspense et de tension', '2025-07-22 13:30:15'),
(10, 'Fantastique', 'Films fantastiques et magiques', '2025-07-22 13:30:15');

-- --------------------------------------------------------

--
-- Structure de la table `cinemas`
--

CREATE TABLE `cinemas` (
  `id` int(11) NOT NULL,
  `ville` varchar(50) NOT NULL,
  `pays` varchar(50) NOT NULL,
  `adresse` varchar(100) NOT NULL,
  `code_postal` varchar(10) DEFAULT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `actif` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `cinemas`
--

INSERT INTO `cinemas` (`id`, `ville`, `pays`, `adresse`, `code_postal`, `telephone`, `email`, `actif`, `created_at`, `updated_at`) VALUES
(1, 'Nantes', 'France', '12 Rue du Cinéma', '44000', '02 40 12 34 56', 'nantes@cinephoria.com', 1, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(2, 'Bordeaux', 'France', '34 Avenue des Stars', '33000', '05 56 12 34 56', 'bordeaux@cinephoria.com', 1, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(3, 'Paris', 'France', '56 Boulevard du Film', '75010', '01 42 12 34 56', 'paris@cinephoria.com', 1, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(4, 'Toulouse', 'France', '78 Rue des Réalisateurs', '31000', '05 61 12 34 56', 'toulouse@cinephoria.com', 1, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(5, 'Lille', 'France', '90 Rue des Acteurs', '59000', '03 20 12 34 56', 'lille@cinephoria.com', 1, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(6, 'Charleroi', 'Belgique', '23 Rue du Scénario', '6000', '+32 71 12 34 56', 'charleroi@cinephoria.com', 1, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(7, 'Liège', 'Belgique', '45 Avenue des Oscars', '4000', '+32 4 12 34 56', 'liege@cinephoria.com', 1, '2025-07-22 13:30:15', '2025-07-22 13:30:15');

-- --------------------------------------------------------

--
-- Structure de la table `films`
--

CREATE TABLE `films` (
  `id` int(11) NOT NULL,
  `titre` varchar(255) NOT NULL,
  `titre_original` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `synopsis` text DEFAULT NULL,
  `duree` int(11) NOT NULL COMMENT 'Durée en minutes',
  `date_sortie` date DEFAULT NULL,
  `realisateur` varchar(255) DEFAULT NULL,
  `acteurs` text DEFAULT NULL,
  `categorie_id` int(11) DEFAULT NULL,
  `age_minimum` int(11) DEFAULT 0,
  `note_moyenne` decimal(3,2) DEFAULT 0.00,
  `affiche` varchar(255) DEFAULT NULL,
  `bande_annonce` varchar(255) DEFAULT NULL,
  `statut` enum('a_venir','en_cours','archive') DEFAULT 'a_venir',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `films`
--

INSERT INTO `films` (`id`, `titre`, `titre_original`, `description`, `synopsis`, `duree`, `date_sortie`, `realisateur`, `acteurs`, `categorie_id`, `age_minimum`, `note_moyenne`, `affiche`, `bande_annonce`, `statut`, `created_at`, `updated_at`) VALUES
(1, 'Amélie', 'Le Fabuleux Destin d\'Amélie Poulain', 'Comédie romantique française culte', 'Amélie, une jeune serveuse dans un bar de Montmartre, passe son temps à observer les gens et à laisser son imagination divaguer.', 122, '2001-04-25', 'Jean-Pierre Jeunet', 'Audrey Tautou, Mathieu Kassovitz', 6, 0, 4.50, 'amelie.jpg', 'amelie_trailer.mp4', 'en_cours', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(2, 'Avatar: La Voie de l\'eau', 'Avatar: The Way of Water', 'Suite épique de science-fiction', 'Plus d\'une décennie après les événements du premier film, Avatar : La Voie de l\'eau raconte l\'histoire de la famille Sully.', 192, '2022-12-14', 'James Cameron', 'Sam Worthington, Zoe Saldana', 4, 10, 4.50, 'avatar2.jpg', 'avatar2_trailer.mp4', 'en_cours', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(3, 'Être et avoir', 'Être et avoir', 'Documentaire sur l\'école rurale', 'Dans une classe unique d\'une école de campagne, nous découvrons une année scolaire auprès d\'enfants âgés de 4 à 10 ans.', 104, '2002-08-28', 'Nicolas Philibert', 'Georges Lopez', 7, 0, 4.00, 'etre_avoir.jpg', 'etre_avoir_trailer.mp4', 'en_cours', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(4, 'Dune', 'Dune', 'Épopée de science-fiction', 'L\'histoire de Paul Atreides, jeune homme aussi doué que brillant, voué à connaître un destin hors du commun.', 155, '2021-10-22', 'Denis Villeneuve', 'Timothée Chalamet, Rebecca Ferguson', 4, 12, 4.50, 'dune.jpg', 'dune_trailer.mp4', 'en_cours', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(5, 'Spider-Man: No Way Home', 'Spider-Man: No Way Home', 'Super-héros multivers', 'Pour la première fois dans l\'histoire cinématographique de Spider-Man, notre héros est démasqué.', 148, '2021-12-15', 'Jon Watts', 'Tom Holland, Zendaya', 1, 10, 3.00, 'spiderman.jpg', 'spiderman_trailer.mp4', 'en_cours', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(6, 'Oppenheimer', 'Oppenheimer', 'Biopic historique', 'L\'histoire du scientifique J. Robert Oppenheimer et de son rôle dans le développement de la bombe atomique.', 180, '2023-07-21', 'Christopher Nolan', 'Cillian Murphy, Emily Blunt', 3, 12, 0.00, 'oppenheimer.jpg', 'oppenheimer_trailer.mp4', 'a_venir', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(7, 'Barbie', 'Barbie', 'Comédie fantastique', 'Barbie vit dans le monde coloré et apparemment parfait de Barbie Land.', 114, '2023-07-21', 'Greta Gerwig', 'Margot Robbie, Ryan Gosling', 2, 6, 0.00, 'barbie.jpg', 'barbie_trailer.mp4', 'a_venir', '2025-07-22 13:30:15', '2025-07-22 13:30:15');

-- --------------------------------------------------------

--
-- Structure de la table `incidents`
--

CREATE TABLE `incidents` (
  `id` int(11) NOT NULL,
  `employe_id` int(11) NOT NULL,
  `cinema_id` int(11) DEFAULT NULL,
  `salle_id` int(11) DEFAULT NULL,
  `seance_id` int(11) DEFAULT NULL,
  `type_incident` enum('technique','securite','maintenance','autre') NOT NULL,
  `titre` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `priorite` enum('basse','moyenne','haute','critique') DEFAULT 'moyenne',
  `statut` enum('ouvert','en_cours','resolu','ferme') DEFAULT 'ouvert',
  `date_incident` timestamp NOT NULL DEFAULT current_timestamp(),
  `date_resolution` timestamp NULL DEFAULT NULL,
  `resolu_par` int(11) DEFAULT NULL,
  `commentaire_resolution` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `incidents`
--

INSERT INTO `incidents` (`id`, `employe_id`, `cinema_id`, `salle_id`, `seance_id`, `type_incident`, `titre`, `description`, `priorite`, `statut`, `date_incident`, `date_resolution`, `resolu_par`, `commentaire_resolution`, `created_at`, `updated_at`) VALUES
(1, 3, 1, 1, 1, 'technique', 'Problème de son', 'Le son de la salle 1 grésille pendant la séance Amélie de 14h', 'haute', 'resolu', '2025-07-22 13:30:15', NULL, 3, 'Remplacement du système audio', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(2, 4, 2, 4, NULL, 'maintenance', 'Nettoyage écran', 'Écran de la salle A nécessite un nettoyage approfondi', 'basse', 'ouvert', '2025-07-22 13:30:15', NULL, NULL, NULL, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(3, 5, 3, 7, 4, 'technique', 'Panne projecteur', 'Le projecteur IMAX s\'est éteint pendant la séance Avatar', 'critique', 'en_cours', '2025-07-22 13:30:15', NULL, NULL, NULL, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(4, 3, 1, NULL, NULL, 'securite', 'Sortie de secours bloquée', 'Une sortie de secours du cinéma de Nantes est obstruée', 'moyenne', 'ouvert', '2025-07-22 13:30:15', NULL, NULL, NULL, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(5, 6, 6, 12, NULL, 'maintenance', 'Remplacement ampoules', 'Plusieurs ampoules de la salle VIP sont grillées', 'basse', 'ouvert', '2025-07-22 13:30:15', NULL, NULL, NULL, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(6, 4, 2, 5, 6, 'technique', 'Problème climatisation', 'La climatisation de la salle B ne fonctionne plus', 'haute', 'en_cours', '2025-07-22 13:30:15', NULL, NULL, NULL, '2025-07-22 13:30:15', '2025-07-22 13:30:15');

-- --------------------------------------------------------

--
-- Structure de la table `reservations`
--

CREATE TABLE `reservations` (
  `id` int(11) NOT NULL,
  `numero_reservation` varchar(20) NOT NULL,
  `utilisateur_id` int(11) NOT NULL,
  `seance_id` int(11) NOT NULL,
  `nb_places` int(11) NOT NULL,
  `prix_total` decimal(6,2) NOT NULL,
  `statut` enum('en_attente','confirmee','annulee','terminee') DEFAULT 'en_attente',
  `methode_paiement` enum('carte','paypal','especes') DEFAULT 'carte',
  `qr_code` varchar(255) DEFAULT NULL,
  `date_reservation` timestamp NOT NULL DEFAULT current_timestamp(),
  `date_annulation` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `reservations`
--

INSERT INTO `reservations` (`id`, `numero_reservation`, `utilisateur_id`, `seance_id`, `nb_places`, `prix_total`, `statut`, `methode_paiement`, `qr_code`, `date_reservation`, `date_annulation`, `created_at`, `updated_at`) VALUES
(1, 'RES001', 8, 1, 2, 19.00, 'confirmee', 'carte', 'QR_RES001_2025', '2025-07-22 13:30:15', NULL, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(2, 'RES002', 9, 2, 1, 9.50, 'confirmee', 'paypal', 'QR_RES002_2025', '2025-07-22 13:30:15', NULL, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(3, 'RES003', 10, 4, 3, 42.00, 'confirmee', 'carte', 'QR_RES003_2025', '2025-07-22 13:30:15', NULL, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(4, 'RES004', 11, 5, 2, 17.00, 'confirmee', 'carte', 'QR_RES004_2025', '2025-07-22 13:30:15', NULL, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(5, 'RES005', 12, 6, 1, 11.00, 'en_attente', 'carte', NULL, '2025-07-22 13:30:15', NULL, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(6, 'RES006', 8, 8, 2, 20.00, 'confirmee', 'carte', 'QR_RES006_2025', '2025-07-22 13:30:15', NULL, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(7, 'RES007', 9, 9, 1, 13.50, 'confirmee', 'paypal', 'QR_RES007_2025', '2025-07-22 13:30:15', NULL, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(8, 'RES008', 10, 11, 4, 36.00, 'confirmee', 'carte', 'QR_RES008_2025', '2025-07-22 13:30:15', NULL, '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(9, 'RES009', 11, 3, 1, 9.50, 'annulee', 'carte', NULL, '2025-07-22 13:30:15', '2025-07-24 08:30:00', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(10, 'RES010', 12, 7, 2, 25.00, 'annulee', 'paypal', NULL, '2025-07-22 13:30:15', '2025-07-24 13:45:00', '2025-07-22 13:30:15', '2025-07-22 13:30:15');

--
-- Déclencheurs `reservations`
--
DELIMITER $$
CREATE TRIGGER `update_places_vendues` AFTER INSERT ON `reservations` FOR EACH ROW BEGIN
    IF NEW.statut = 'confirmee' THEN
        UPDATE seances
        SET places_vendues = places_vendues + NEW.nb_places,
            places_disponibles = places_disponibles - NEW.nb_places
        WHERE id = NEW.seance_id;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_places_vendues_update` AFTER UPDATE ON `reservations` FOR EACH ROW BEGIN
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
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `salles`
--

CREATE TABLE `salles` (
  `id` int(11) NOT NULL,
  `cinema_id` int(11) NOT NULL,
  `nom` varchar(50) NOT NULL,
  `capacite` int(11) NOT NULL,
  `type_salle` enum('standard','premium','imax') DEFAULT 'standard',
  `equipements` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`equipements`)),
  `actif` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `salles`
--

INSERT INTO `salles` (`id`, `cinema_id`, `nom`, `capacite`, `type_salle`, `equipements`, `actif`, `created_at`) VALUES
(1, 1, 'Salle 1', 150, 'standard', '{\"son\": \"Dolby Digital\", \"ecran\": \"Standard\", \"climatisation\": true}', 1, '2025-07-22 13:30:15'),
(2, 1, 'Salle 2', 200, 'premium', '{\"son\": \"Dolby Atmos\", \"ecran\": \"4K\", \"climatisation\": true, \"sieges\": \"cuir\"}', 1, '2025-07-22 13:30:15'),
(3, 1, 'Salle IMAX', 300, 'imax', '{\"son\": \"IMAX\", \"ecran\": \"IMAX\", \"climatisation\": true, \"sieges\": \"premium\"}', 1, '2025-07-22 13:30:15'),
(4, 2, 'Salle A', 120, 'standard', '{\"son\": \"Dolby Digital\", \"ecran\": \"Standard\", \"climatisation\": true}', 1, '2025-07-22 13:30:15'),
(5, 2, 'Salle B', 180, 'premium', '{\"son\": \"Dolby Atmos\", \"ecran\": \"4K\", \"climatisation\": true, \"sieges\": \"cuir\"}', 1, '2025-07-22 13:30:15'),
(6, 3, 'Salle Alpha', 100, 'standard', '{\"son\": \"Dolby Digital\", \"ecran\": \"Standard\", \"climatisation\": true}', 1, '2025-07-22 13:30:15'),
(7, 3, 'Salle Beta', 250, 'imax', '{\"son\": \"IMAX\", \"ecran\": \"IMAX\", \"climatisation\": true, \"sieges\": \"premium\"}', 1, '2025-07-22 13:30:15'),
(8, 3, 'Salle Gamma', 140, 'premium', '{\"son\": \"Dolby Atmos\", \"ecran\": \"4K\", \"climatisation\": true, \"sieges\": \"cuir\"}', 1, '2025-07-22 13:30:15'),
(9, 4, 'Salle Rouge', 110, 'standard', '{\"son\": \"Dolby Digital\", \"ecran\": \"Standard\", \"climatisation\": true}', 1, '2025-07-22 13:30:15'),
(10, 4, 'Salle Bleue', 160, 'premium', '{\"son\": \"Dolby Atmos\", \"ecran\": \"4K\", \"climatisation\": true, \"sieges\": \"cuir\"}', 1, '2025-07-22 13:30:15'),
(11, 6, 'Salle Principale', 130, 'standard', '{\"son\": \"Dolby Digital\", \"ecran\": \"Standard\", \"climatisation\": true}', 1, '2025-07-22 13:30:15'),
(12, 6, 'Salle VIP', 80, 'premium', '{\"son\": \"Dolby Atmos\", \"ecran\": \"4K\", \"climatisation\": true, \"sieges\": \"cuir\", \"service\": \"VIP\"}', 1, '2025-07-22 13:30:15');

-- --------------------------------------------------------

--
-- Structure de la table `seances`
--

CREATE TABLE `seances` (
  `id` int(11) NOT NULL,
  `film_id` int(11) NOT NULL,
  `salle_id` int(11) NOT NULL,
  `date_seance` date NOT NULL,
  `heure_debut` time NOT NULL,
  `heure_fin` time NOT NULL,
  `prix` decimal(5,2) NOT NULL,
  `places_disponibles` int(11) NOT NULL,
  `places_vendues` int(11) DEFAULT 0,
  `statut` enum('programmee','en_cours','terminee','annulee') DEFAULT 'programmee',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `seances`
--

INSERT INTO `seances` (`id`, `film_id`, `salle_id`, `date_seance`, `heure_debut`, `heure_fin`, `prix`, `places_disponibles`, `places_vendues`, `statut`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2025-07-25', '14:00:00', '16:02:00', 9.50, 148, 2, 'programmee', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(2, 1, 1, '2025-07-25', '18:00:00', '20:02:00', 9.50, 149, 1, 'programmee', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(3, 2, 3, '2025-07-25', '14:30:00', '17:42:00', 14.00, 300, 0, 'programmee', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(4, 2, 3, '2025-07-25', '18:15:00', '21:27:00', 14.00, 297, 3, 'programmee', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(5, 3, 4, '2025-07-25', '16:00:00', '17:44:00', 8.50, 118, 2, 'programmee', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(6, 4, 5, '2025-07-25', '15:00:00', '17:35:00', 11.00, 180, 0, 'programmee', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(7, 5, 6, '2025-07-25', '17:00:00', '19:28:00', 12.00, 100, 0, 'programmee', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(8, 1, 8, '2025-07-25', '19:30:00', '21:32:00', 10.00, 138, 2, 'programmee', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(9, 2, 9, '2025-07-26', '14:00:00', '17:12:00', 13.50, 109, 1, 'programmee', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(10, 4, 10, '2025-07-26', '20:00:00', '22:35:00', 11.50, 160, 0, 'programmee', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(11, 1, 11, '2025-07-27', '14:00:00', '16:02:00', 9.00, 126, 4, 'programmee', '2025-07-22 13:30:15', '2025-07-22 13:30:15'),
(12, 2, 12, '2025-07-27', '15:30:00', '18:42:00', 13.00, 80, 0, 'programmee', '2025-07-22 13:30:15', '2025-07-22 13:30:15');

-- --------------------------------------------------------

--
-- Structure de la table `utilisateurs`
--

CREATE TABLE `utilisateurs` (
  `id` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `mot_de_passe` varchar(255) NOT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `date_naissance` date DEFAULT NULL,
  `cinema_id` int(11) DEFAULT NULL,
  `role` enum('utilisateur','employe','admin') DEFAULT 'utilisateur',
  `actif` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_login` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `utilisateurs`
--

INSERT INTO `utilisateurs` (`id`, `nom`, `prenom`, `email`, `mot_de_passe`, `telephone`, `date_naissance`, `cinema_id`, `role`, `actif`, `created_at`, `updated_at`, `last_login`) VALUES
(1, 'Dupont', 'Jean', 'admin@cinephoria.com', '$2y$10$kDAORV6KGd8AGy7BfZpEeOSN5pqKIlzb95S0lDJTkZsf/M1NRWc5O', '0123456789', '1980-05-15', NULL, 'admin', 1, '2025-07-22 13:30:15', '2025-07-22 15:28:12', '2025-07-22 17:28:12'),
(2, 'Martin', 'Sophie', 'admin2@cinephoria.com', '$2y$10$YVrWXbKbJVOp9EULdJsQBON6CL5m4O9T9VQz9.kJ5LcNYu6Py5mMe', '0123456788', '1985-03-22', NULL, 'admin', 1, '2025-07-22 13:30:15', '2025-07-22 13:42:15', '0000-00-00 00:00:00'),
(3, 'Durand', 'Pierre', 'employe1@cinephoria.com', '$2y$10$yaebm7TAsmT5mt0c4VFXK.JEZHf1uyEyabmrY5pL2lNdxxj8fL9HG', '0123456787', '1990-08-10', 1, 'employe', 1, '2025-07-22 13:30:15', '2025-07-22 13:44:53', '2025-07-22 15:32:05'),
(4, 'Moreau', 'Marie', 'employe2@cinephoria.com', '$2y$10$XGlJz6kVB7aI.SmdLpX4cuOJ2m3UJCrF8XpE1.pLM4dFV7Y3Kr9bC', '0123456786', '1992-11-03', 2, 'employe', 1, '2025-07-22 13:30:15', '2025-07-22 13:41:49', '2025-07-22 15:32:05'),
(5, 'Petit', 'Lucas', 'employe3@cinephoria.com', '$2y$10$XGlJz6kVB7aI.SmdLpX4cuOJ2m3UJCrF8XpE1.pLM4dFV7Y3Kr9bC', '0123456785', '1988-06-18', 3, 'employe', 1, '2025-07-22 13:30:15', '2025-07-22 13:41:51', '2025-07-22 15:32:05'),
(6, 'Lambert', 'Julie', 'employe4@cinephoria.com', '$2y$10$XGlJz6kVB7aI.SmdLpX4cuOJ2m3UJCrF8XpE1.pLM4dFV7Y3Kr9bC', '0123456784', '1991-04-20', 4, 'employe', 1, '2025-07-22 13:30:15', '2025-07-22 13:41:55', '2025-07-22 15:32:05'),
(7, 'Bernard', 'Antoine', 'employe5@cinephoria.com', '$2y$10$XGlJz6kVB7aI.SmdLpX4cuOJ2m3UJCrF8XpE1.pLM4dFV7Y3Kr9bC', '0123456783', '1989-09-15', 6, 'employe', 1, '2025-07-22 13:30:15', '2025-07-22 13:41:59', '2025-07-22 15:32:05'),
(8, 'Leblanc', 'Julie', 'julie.leblanc@gmail.com', '$2y$10$PDJZp06TxrxoDnT7qQTO7OBBvEmLG0q1Y1/CSQz4s4iYgnmCVA65K', '0123456782', '1995-02-14', NULL, 'utilisateur', 1, '2025-07-22 13:30:15', '2025-07-22 13:44:53', '2025-07-22 15:32:05'),
(9, 'Rousseau', 'Thomas', 'thomas.rousseau@gmail.com', '\'$2y$10$k8PfY2wN5tL1M6nGqR3ESeOA7p2xKUDzFm1E4.jK7bNXs5T9Vr8cW', '0123456781', '1987-09-07', NULL, 'utilisateur', 1, '2025-07-22 13:30:15', '2025-07-22 13:42:35', '2025-07-22 15:32:05'),
(10, 'Girard', 'Emma', 'emma.girard@gmail.com', '\'$2y$10$k8PfY2wN5tL1M6nGqR3ESeOA7p2xKUDzFm1E4.jK7bNXs5T9Vr8cW', '0123456780', '1993-12-25', NULL, 'utilisateur', 1, '2025-07-22 13:30:15', '2025-07-22 13:42:38', '2025-07-22 15:32:05'),
(11, 'Roux', 'Alexandre', 'alex.roux@gmail.com', '\'$2y$10$k8PfY2wN5tL1M6nGqR3ESeOA7p2xKUDzFm1E4.jK7bNXs5T9Vr8cW', '0123456779', '1991-04-12', NULL, 'utilisateur', 1, '2025-07-22 13:30:15', '2025-07-22 13:42:42', '2025-07-22 15:32:05'),
(12, 'Faure', 'Camille', 'camille.faure@gmail.com', '\'$2y$10$k8PfY2wN5tL1M6nGqR3ESeOA7p2xKUDzFm1E4.jK7bNXs5T9Vr8cW', '0123456778', '1996-07-30', NULL, 'utilisateur', 1, '2025-07-22 13:30:15', '2025-07-22 13:42:44', '2025-07-22 15:32:05'),
(13, 'Rémusat', 'Romain', 'rremusat@gmail.com', '$2y$10$rfr1JX8PgX3iaKYghcr0YeRB7QAhe/6YHtSKwyxb.wBeHQscQAbxe', '0698291585', '1981-12-24', NULL, 'utilisateur', 1, '2025-07-22 13:31:25', '2025-07-22 13:31:25', '2025-07-22 15:32:05');

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_reservations_details`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `v_reservations_details` (
`id` int(11)
,`numero_reservation` varchar(20)
,`nb_places` int(11)
,`prix_total` decimal(6,2)
,`statut` enum('en_attente','confirmee','annulee','terminee')
,`date_reservation` timestamp
,`qr_code` varchar(255)
,`client_nom` varchar(100)
,`client_prenom` varchar(100)
,`client_email` varchar(255)
,`film_titre` varchar(255)
,`date_seance` date
,`heure_debut` time
,`salle_nom` varchar(50)
,`cinema_ville` varchar(50)
,`cinema_adresse` varchar(100)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_seances_details`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `v_seances_details` (
`id` int(11)
,`date_seance` date
,`heure_debut` time
,`heure_fin` time
,`prix` decimal(5,2)
,`places_disponibles` int(11)
,`places_vendues` int(11)
,`statut` enum('programmee','en_cours','terminee','annulee')
,`film_titre` varchar(255)
,`film_duree` int(11)
,`film_affiche` varchar(255)
,`salle_nom` varchar(50)
,`salle_capacite` int(11)
,`cinema_ville` varchar(50)
,`cinema_pays` varchar(50)
,`cinema_adresse` varchar(100)
);

-- --------------------------------------------------------

--
-- Structure de la vue `v_reservations_details`
--
DROP TABLE IF EXISTS `v_reservations_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_reservations_details`  AS SELECT `r`.`id` AS `id`, `r`.`numero_reservation` AS `numero_reservation`, `r`.`nb_places` AS `nb_places`, `r`.`prix_total` AS `prix_total`, `r`.`statut` AS `statut`, `r`.`date_reservation` AS `date_reservation`, `r`.`qr_code` AS `qr_code`, `u`.`nom` AS `client_nom`, `u`.`prenom` AS `client_prenom`, `u`.`email` AS `client_email`, `f`.`titre` AS `film_titre`, `s`.`date_seance` AS `date_seance`, `s`.`heure_debut` AS `heure_debut`, `sal`.`nom` AS `salle_nom`, `c`.`ville` AS `cinema_ville`, `c`.`adresse` AS `cinema_adresse` FROM (((((`reservations` `r` join `utilisateurs` `u` on(`r`.`utilisateur_id` = `u`.`id`)) join `seances` `s` on(`r`.`seance_id` = `s`.`id`)) join `films` `f` on(`s`.`film_id` = `f`.`id`)) join `salles` `sal` on(`s`.`salle_id` = `sal`.`id`)) join `cinemas` `c` on(`sal`.`cinema_id` = `c`.`id`)) ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_seances_details`
--
DROP TABLE IF EXISTS `v_seances_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_seances_details`  AS SELECT `s`.`id` AS `id`, `s`.`date_seance` AS `date_seance`, `s`.`heure_debut` AS `heure_debut`, `s`.`heure_fin` AS `heure_fin`, `s`.`prix` AS `prix`, `s`.`places_disponibles` AS `places_disponibles`, `s`.`places_vendues` AS `places_vendues`, `s`.`statut` AS `statut`, `f`.`titre` AS `film_titre`, `f`.`duree` AS `film_duree`, `f`.`affiche` AS `film_affiche`, `sal`.`nom` AS `salle_nom`, `sal`.`capacite` AS `salle_capacite`, `c`.`ville` AS `cinema_ville`, `c`.`pays` AS `cinema_pays`, `c`.`adresse` AS `cinema_adresse` FROM (((`seances` `s` join `films` `f` on(`s`.`film_id` = `f`.`id`)) join `salles` `sal` on(`s`.`salle_id` = `sal`.`id`)) join `cinemas` `c` on(`sal`.`cinema_id` = `c`.`id`)) ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `avis`
--
ALTER TABLE `avis`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_avis` (`utilisateur_id`,`film_id`),
  ADD KEY `idx_utilisateur` (`utilisateur_id`),
  ADD KEY `idx_film` (`film_id`),
  ADD KEY `idx_note` (`note`),
  ADD KEY `idx_valide` (`valide`);

--
-- Index pour la table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nom` (`nom`);

--
-- Index pour la table `cinemas`
--
ALTER TABLE `cinemas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ville` (`ville`),
  ADD KEY `idx_pays` (`pays`),
  ADD KEY `idx_actif` (`actif`);

--
-- Index pour la table `films`
--
ALTER TABLE `films`
  ADD PRIMARY KEY (`id`),
  ADD KEY `categorie_id` (`categorie_id`),
  ADD KEY `idx_titre` (`titre`),
  ADD KEY `idx_statut` (`statut`),
  ADD KEY `idx_date_sortie` (`date_sortie`);

--
-- Index pour la table `incidents`
--
ALTER TABLE `incidents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `seance_id` (`seance_id`),
  ADD KEY `resolu_par` (`resolu_par`),
  ADD KEY `idx_employe` (`employe_id`),
  ADD KEY `idx_cinema` (`cinema_id`),
  ADD KEY `idx_salle` (`salle_id`),
  ADD KEY `idx_type` (`type_incident`),
  ADD KEY `idx_statut` (`statut`),
  ADD KEY `idx_priorite` (`priorite`),
  ADD KEY `idx_date_incident` (`date_incident`);

--
-- Index pour la table `reservations`
--
ALTER TABLE `reservations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `numero_reservation` (`numero_reservation`),
  ADD KEY `idx_utilisateur` (`utilisateur_id`),
  ADD KEY `idx_seance` (`seance_id`),
  ADD KEY `idx_numero` (`numero_reservation`),
  ADD KEY `idx_statut` (`statut`),
  ADD KEY `idx_date_reservation` (`date_reservation`);

--
-- Index pour la table `salles`
--
ALTER TABLE `salles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_salle_cinema` (`cinema_id`,`nom`),
  ADD KEY `idx_nom` (`nom`),
  ADD KEY `idx_cinema` (`cinema_id`);

--
-- Index pour la table `seances`
--
ALTER TABLE `seances`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_seance` (`salle_id`,`date_seance`,`heure_debut`),
  ADD KEY `idx_film` (`film_id`),
  ADD KEY `idx_salle` (`salle_id`),
  ADD KEY `idx_date_seance` (`date_seance`),
  ADD KEY `idx_statut` (`statut`);

--
-- Index pour la table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_role` (`role`),
  ADD KEY `idx_cinema` (`cinema_id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `avis`
--
ALTER TABLE `avis`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `cinemas`
--
ALTER TABLE `cinemas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT pour la table `films`
--
ALTER TABLE `films`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT pour la table `incidents`
--
ALTER TABLE `incidents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `reservations`
--
ALTER TABLE `reservations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `salles`
--
ALTER TABLE `salles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT pour la table `seances`
--
ALTER TABLE `seances`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT pour la table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `avis`
--
ALTER TABLE `avis`
  ADD CONSTRAINT `avis_ibfk_1` FOREIGN KEY (`utilisateur_id`) REFERENCES `utilisateurs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `avis_ibfk_2` FOREIGN KEY (`film_id`) REFERENCES `films` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `films`
--
ALTER TABLE `films`
  ADD CONSTRAINT `films_ibfk_1` FOREIGN KEY (`categorie_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `incidents`
--
ALTER TABLE `incidents`
  ADD CONSTRAINT `incidents_ibfk_1` FOREIGN KEY (`employe_id`) REFERENCES `utilisateurs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `incidents_ibfk_2` FOREIGN KEY (`cinema_id`) REFERENCES `cinemas` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `incidents_ibfk_3` FOREIGN KEY (`salle_id`) REFERENCES `salles` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `incidents_ibfk_4` FOREIGN KEY (`seance_id`) REFERENCES `seances` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `incidents_ibfk_5` FOREIGN KEY (`resolu_par`) REFERENCES `utilisateurs` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `reservations`
--
ALTER TABLE `reservations`
  ADD CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`utilisateur_id`) REFERENCES `utilisateurs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reservations_ibfk_2` FOREIGN KEY (`seance_id`) REFERENCES `seances` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `salles`
--
ALTER TABLE `salles`
  ADD CONSTRAINT `salles_ibfk_1` FOREIGN KEY (`cinema_id`) REFERENCES `cinemas` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `seances`
--
ALTER TABLE `seances`
  ADD CONSTRAINT `seances_ibfk_1` FOREIGN KEY (`film_id`) REFERENCES `films` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `seances_ibfk_2` FOREIGN KEY (`salle_id`) REFERENCES `salles` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  ADD CONSTRAINT `utilisateurs_ibfk_1` FOREIGN KEY (`cinema_id`) REFERENCES `cinemas` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
