<?php

class Cinema
{
    private $db;

    //    A ne pas oublier !!!
    //    getPdo()	Retourne l’objet PDO pour faire des requêtes venant de Database.php
    //    $this->db	Contient l’objet Database (ton Singleton)
    //    prepare()	Fonction native de PDO pour préparer une requête SQL
    /* Le constructeur */

    public function __construct() {
        // Appel à l'objet database et création de l'instance
        $this->db = Database::getInstance();
    }

    /**
     * Vérifie si un cinéma existe et est actif
     *
     * @param int $id ID du cinéma
     * @return bool True si le cinéma existe et est actif
     */
    public function exists($id) {
        try {
            $req = "SELECT COUNT(*) as count FROM cinemas WHERE id = ? AND actif = 1";
            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute([$id]);
            $result = $stmt->fetch();
            return (int)$result['count'] > 0;
        } catch (Exception $e) {
            return false;
        }
    }

    /**
     * Compte le nombre total de cinémas actifs
     *
     * @return int Nombre de cinémas
     */
    public function count() {
        return $this->db->count('cinemas WHERE actif = 1');
    }

    /**
     * Récupère la liste des pays disponibles
     *
     * @return array Liste des pays uniques
     * @throws Exception En cas d'erreur de requête
     */
    public function getPaysDisponibles() {
        try {
            $req = "SELECT DISTINCT pays FROM cinemas WHERE actif = 1 ORDER BY pays";
            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute();
            return $stmt->fetchAll(PDO::FETCH_COLUMN);
        } catch (Exception $e) {
            throw new Exception('Erreur récupération pays : ' . $e->getMessage());
        }
    }

    /**
     * Récupère les villes d'un pays donné
     *
     * @param string $pays Nom du pays
     * @return array Liste des villes du pays
     * @throws Exception En cas d'erreur de requête
     */
    public function getVillesByPays($pays) {
        try {
            $req = "SELECT ville, id FROM cinemas WHERE pays = ? AND actif = 1 ORDER BY ville";
            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute([$pays]);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            throw new Exception('Erreur récupération villes : ' . $e->getMessage());
        }
    }

    /**
     * Recherche de cinémas par terme (ville, pays, adresse)
     *
     * @param string $terme Terme de recherche
     * @return array Liste des cinémas correspondants
     * @throws Exception En cas d'erreur de requête
     */
    public function search($terme) {
        try {
            $terme = '%' . trim($terme) . '%';

            $req = "SELECT id, ville, pays, adresse, code_postal, telephone, email,
                           created_at, updated_at,
                           MATCH(ville, pays, adresse) AGAINST(? IN BOOLEAN MODE) as relevance
                    FROM cinemas 
                    WHERE actif = 1 
                      AND (ville LIKE ? OR pays LIKE ? OR adresse LIKE ?)
                    ORDER BY relevance DESC, ville";

            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute([str_replace('%', '', $terme), $terme, $terme, $terme]);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            throw new Exception('Erreur recherche cinémas : ' . $e->getMessage());
        }
    }

    public function getCinemasByFilm($filmId, $dateDebut = null, $dateFin = null) {
        try {
            $dateDebut = $dateDebut ?: date('Y-m-d');
            $dateFin = $dateFin ?: date('Y-m-d', strtotime('+30 days'));

            $req = "SELECT DISTINCT c.id, c.ville, c.pays, c.adresse, c.telephone,
                           COUNT(se.id) as nb_seances,
                           MIN(se.prix) as prix_min,
                           MAX(se.prix) as prix_max,
                           MIN(se.date_seance) as premiere_seance
                    FROM cinemas c
                    JOIN salles s ON c.id = s.cinema_id
                    JOIN seances se ON s.id = se.salle_id
                    WHERE se.film_id = ?
                      AND se.date_seance BETWEEN ? AND ?
                      AND se.statut = 'programmee'
                      AND c.actif = 1
                    GROUP BY c.id
                    ORDER BY c.pays, c.ville";

            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute([$filmId, $dateDebut, $dateFin]);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            throw new Exception('Erreur récupération cinémas par film : ' . $e->getMessage());
        }
    }

    /**
     * Récupère les employés d'un cinéma
     *
     * @param int $cinemaId ID du cinéma
     * @return array Liste des employés
     * @throws Exception En cas d'erreur de requête
     */
    public function getEmployes($cinemaId) {
        try {
            $req = "SELECT u.id, u.nom, u.prenom, u.email, u.telephone, u.role,
                           u.created_at
                    FROM utilisateurs u
                    WHERE u.cinema_id = ? 
                      AND u.role IN ('employe', 'admin')
                      AND u.actif = 1
                    ORDER BY u.nom, u.prenom";

            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute([$cinemaId]);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            throw new Exception('Erreur récupération employés : ' . $e->getMessage());
        }
    }

    /**
     * Récupère les incidents d'un cinéma
     *
     * @param int $cinemaId ID du cinéma
     * @param string $statut Filtre par statut (optionnel)
     * @return array Liste des incidents
     * @throws Exception En cas d'erreur de requête
     */
    public function getIncidents($cinemaId, $statut = null) {
        try {
            $req = "SELECT i.id, i.type_incident, i.titre, i.description, i.priorite, 
                           i.statut, i.date_incident, i.date_resolution,
                           u1.nom as employe_nom, u1.prenom as employe_prenom,
                           u2.nom as resolveur_nom, u2.prenom as resolveur_prenom,
                           s.nom as salle_nom
                    FROM incidents i
                    JOIN utilisateurs u1 ON i.employe_id = u1.id
                    LEFT JOIN utilisateurs u2 ON i.resolu_par = u2.id
                    LEFT JOIN salles s ON i.salle_id = s.id
                    WHERE i.cinema_id = ?";

            $params = [$cinemaId];

            if ($statut) {
                $req .= " AND i.statut = ?";
                $params[] = $statut;
            }

            $req .= " ORDER BY i.date_incident DESC";

            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute($params);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            throw new Exception('Erreur récupération incidents : ' . $e->getMessage());
        }
    }

    /**
     * Récupérer les infos des cinémas
     * @return array|false
     */

    public function getInfos() {
        try {
            $req = "SELECT id, ville, pays, adresse,adresse, actif, created_at, updated_at FROM cinemas ORDER BY pays ASC ,ville ASC";
            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute();
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            throw new Exception('Erreur recherche cinema : ' . $e->getMessage());
        }
    }

    /**
     * Récupérer un cinéma par ID tjs utile
     * @param int $id
     * @return array|false
     */

    public function getById($id) {
        try {
            $req = "SELECT id, ville, pays, adresse, code_postal, telephone, email, 
                           actif, created_at, updated_at 
                    FROM cinemas 
                    WHERE id = ? AND actif = 1";

            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute([$id]);
            return $stmt->fetch(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            throw new Exception('Erreur récupération cinéma : ' . $e->getMessage());
        }
    }

    public function getByPays($pays) {
        try {
            $req = "SELECT id, ville, pays, adresse, code_postal, telephone, email, 
                           actif, created_at, updated_at 
                    FROM cinemas 
                    WHERE pays = ? AND actif = 1 
                    ORDER BY ville";

            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute([$pays]);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            throw new Exception('Erreur récupération cinémas par pays : ' . $e->getMessage());
        }
    }
    /**
     * Récupère un cinéma avec toutes ses salles
     *
     * @param int $cinemaId ID du cinéma
     * @return array|false Données du cinéma avec ses salles
     * @throws Exception En cas d'erreur de requête
     */
    public function getWithSalles($cinemaId) {
        try {
            // Récupérer le cinéma
            $cinema = $this->getById($cinemaId);
            if (!$cinema) {
                return false;
            }

            // Récupérer les salles du cinéma
            $req = "SELECT id, nom, capacite, type_salle, equipements, actif 
                    FROM salles 
                    WHERE cinema_id = ? AND actif = 1 
                    ORDER BY nom";

            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute([$cinemaId]);
            $cinema['salles'] = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Décoder les équipements JSON
            foreach ($cinema['salles'] as &$salle) {
                $salle['equipements'] = json_decode($salle['equipements'], true);
            }

            return $cinema;
        } catch (Exception $e) {
            throw new Exception('Erreur récupération cinéma avec salles : ' . $e->getMessage());
        }
    }

    /**
     * Récupère les cinémas avec le nombre de salles et la capacité totale
     *
     * @return array Liste des cinémas avec statistiques
     * @throws Exception En cas d'erreur de requête
     */
    public function getAllWithStats() {
        try {
            $req = "SELECT c.id, c.ville, c.pays, c.adresse, c.code_postal, 
                           c.telephone, c.email, c.actif,
                           COUNT(s.id) as nb_salles,
                           COALESCE(SUM(s.capacite), 0) as capacite_totale,
                           c.created_at, c.updated_at
                    FROM cinemas c
                    LEFT JOIN salles s ON c.id = s.cinema_id AND s.actif = 1
                    WHERE c.actif = 1
                    GROUP BY c.id
                    ORDER BY c.pays, c.ville";

            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute();
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            throw new Exception('Erreur récupération cinémas avec stats : ' . $e->getMessage());
        }
    }

    /**
     * Récupère les séances d'un cinéma pour une période donnée
     *
     * @param int $cinemaId ID du cinéma
     * @param string $dateDebut Date de début (Y-m-d)
     * @param string $dateFin Date de fin (Y-m-d)
     * @return array Liste des séances
     * @throws Exception En cas d'erreur de requête
     */
    public function getSeances($cinemaId, $dateDebut = null, $dateFin = null) {
        try {
            $dateDebut = $dateDebut ?: date('Y-m-d');
            $dateFin = $dateFin ?: date('Y-m-d', strtotime('+7 days'));

            $req = "SELECT se.id, se.date_seance, se.heure_debut, se.heure_fin, 
                           se.prix, se.places_disponibles, se.places_vendues, se.statut,
                           f.titre as film_titre, f.duree as film_duree, f.affiche,
                           s.nom as salle_nom, s.capacite as salle_capacite, s.type_salle
                    FROM seances se
                    JOIN films f ON se.film_id = f.id
                    JOIN salles s ON se.salle_id = s.id
                    WHERE s.cinema_id = ? 
                      AND se.date_seance BETWEEN ? AND ?
                      AND se.statut = 'programmee'
                    ORDER BY se.date_seance, se.heure_debut";

            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute([$cinemaId, $dateDebut, $dateFin]);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            throw new Exception('Erreur récupération séances cinéma : ' . $e->getMessage());
        }
    }

    /**
     * Récupère les films uniques à l'affiche pour un cinéma donné
     * Idéal pour le filtrage dynamique par Selectbox
     */
    public function getFilmsActifsByCinema($cinemaId) {
        try {
            $req = "SELECT f.id, f.titre, f.description, f.duree, f.affiche, f.note_moyenne,
                       c.nom as categorie_nom,
                       COUNT(se.id) as nb_seances,
                       MIN(se.prix) as prix_min
                FROM films f
                LEFT JOIN categories c ON f.categorie_id = c.id
                JOIN seances se ON f.id = se.film_id
                JOIN salles s ON se.salle_id = s.id
                WHERE s.cinema_id = ? 
                  AND (f.statut = 'en_cours' OR f.statut = 'a_venir')
                  AND se.date_seance >= CURDATE()
                GROUP BY f.id, c.nom
                ORDER BY f.note_moyenne DESC";

            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute([$cinemaId]);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            throw new Exception('Erreur films par cinéma : ' . $e->getMessage());
        }
    }

    /**
     * Crée un nouveau cinéma
     *
     * @param array $data Données du cinéma
     * @return int ID du cinéma créé
     * @throws Exception En cas d'erreur de validation ou d'insertion
     */
    public function create($data) {
        // Validation des champs requis
        $required = ['ville', 'pays', 'adresse'];
        foreach ($required as $field) {
            if (empty($data[$field])) {
                throw new Exception("Le champ {$field} est requis");
            }
        }

        try {
            $req = "INSERT INTO cinemas (ville, pays, adresse, code_postal, telephone, email, actif) 
                    VALUES (:ville, :pays, :adresse, :code_postal, :telephone, :email, :actif)";

            $stmt = $this->db->getPdo()->prepare($req);

            $result = $stmt->execute([
                'ville' => trim($data['ville']),
                'pays' => trim($data['pays']),
                'adresse' => trim($data['adresse']),
                'code_postal' => $data['code_postal'] ?? null,
                'telephone' => $data['telephone'] ?? null,
                'email' => filter_var($data['email'] ?? '', FILTER_VALIDATE_EMAIL) ?: null,
                'actif' => $data['actif'] ?? 1
            ]);

            if ($result) {
                return $this->db->getPdo()->lastInsertId();
            } else {
                throw new Exception('Erreur lors de la création du cinéma');
            }
        } catch (Exception $e) {
            throw new Exception('Erreur création cinéma : ' . $e->getMessage());
        }
    }
    /**
     * Met à jour un cinéma existant
     *
     * @param int $id ID du cinéma
     * @param array $data Nouvelles données
     * @return bool Succès de la mise à jour
     * @throws Exception En cas d'erreur
     */
    public function update($id, $data) {
        try {
            $req = "UPDATE cinemas 
                    SET ville = :ville, pays = :pays, adresse = :adresse, 
                        code_postal = :code_postal, telephone = :telephone, 
                        email = :email, actif = :actif, updated_at = NOW()
                    WHERE id = :id";

            $stmt = $this->db->getPdo()->prepare($req);

            return $stmt->execute([
                'id' => $id,
                'ville' => trim($data['ville']),
                'pays' => trim($data['pays']),
                'adresse' => trim($data['adresse']),
                'code_postal' => $data['code_postal'] ?? null,
                'telephone' => $data['telephone'] ?? null,
                'email' => filter_var($data['email'] ?? '', FILTER_VALIDATE_EMAIL) ?: null,
                'actif' => $data['actif'] ?? 1
            ]);
        } catch (Exception $e) {
            throw new Exception('Erreur mise à jour cinéma : ' . $e->getMessage());
        }
    }

    /**
     * Désactive un cinéma (soft delete)
     *
     * @param int $id ID du cinéma
     * @return bool Succès de la désactivation
     * @throws Exception En cas d'erreur
     */
    public function delete($id) {
        try {
            $req = "UPDATE cinemas SET actif = 0, updated_at = NOW() WHERE id = ?";
            $stmt = $this->db->getPdo()->prepare($req);
            return $stmt->execute([$id]);
        } catch (Exception $e) {
            throw new Exception('Erreur désactivation cinéma : ' . $e->getMessage());
        }
    }

}
?>