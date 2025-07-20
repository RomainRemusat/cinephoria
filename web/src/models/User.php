<?php

class User {
    private $db;

    // Ne pas oublier !!!
    //    getPdo()	Retourne l’objet PDO pour faire des requêtes venant de Database.php
    //    $this->db	Contient l’objet Database (ton Singleton)
    //    prepare()	Fonction native de PDO pour préparer une requête SQL


    /* Le constructeur */
    public function __construct() {
        // Appel à l'objet database et création de l'instance
        $this->db = Database::getInstance();
    }

    // ===========================================
    // MÉTHODES DE BASE POUR L'AUTHENTIFICATION
    // ===========================================

    /**
     * Récupérer un utilisateur par email
     * @param string $email
     * @return array|false
     */

    public function getByEmail($email) {
        try {
            $req = "SELECT * FROM utilisateurs WHERE email = :email AND actif = 1";
            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute(['email' => $email]);
            return $stmt->fetch();
        } catch (Exception $e) {
            throw new Exception('Erreur recherche utilisateur : ' . $e->getMessage());
        }
    }


    /**
     * Récupérer un utilisateur par ID tjs utile
     * @param int $id
     * @return array|false
     */

    public function getById($id) {
        try{
            $req = "SELECT * FROM utilisateurs WHERE id = ? AND actif = 1";
            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute([$id]);
            return $stmt->fetch();
         }
        catch(Exception $e){
            throw new Exception('Erreur recherche utilisateur : ' . $e->getMessage());
        }
    }


    /**
     * Vérifier les identifiants (login) la sécu quoi !
     * @param string $email
     * @param string $password
     * @return array|false Données utilisateur ou false
     */

    public function login($email, $password) {
        try {
            if (empty($email) || empty($password)) {
                return false;
            }
            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                return false;
            }

            // On récupère facilement l'email
            $user = $this->getByEmail($email);

            // Maintenant on test !! On vérifie si le MDP est bon
            if ($user && password_verify($password, $user['password'])) {
                return $user;
            }

            //  Sinon ça dégage
            return false;
        }
        catch(Exception $e){
            throw new Exception('Erreur login : ' . $e->getMessage());
        }
    }

    /**
     * * Vérifie si un email existe dans la base, on compte c'est simple
     * @param string $email
     * @return bool
     */

    public function emailExists($email) {
        try {
            $stmt = $this->db->getPdo()->prepare(
                "SELECT COUNT(*) as total FROM utilisateurs WHERE email = ?"
            );
            $stmt->execute([$email]);
            $result = $stmt->fetch();
            return (int)$result['total'] > 0;
        } catch (Exception $e) {
            throw new Exception('Erreur vérification email : ' . $e->getMessage());
        }
    }


    /**
     * Créer un nouvel utilisateur | plus dur là ! Mais ça va le faire
     * @param array $userData
     * @return int ID du nouvel utilisateur
     */

    public function create($userData) {
        // Vérif de base
        $required = ['nom', 'prenom', 'email', 'password'];
        // On test si un ou plusieurs sont manquant (uniquement les requis, on peut ajouter d'autres entrées non obligatoire)
        foreach ($required as $field) {
            if (empty($userData[$field])) {
                throw new Exception("Champs {$field} requis : " . $field);
            }
        }

        // -------------------------------------------------------------------------------------- //
        // On va vérifier si les champs sont ok et si le contenu est en accord avec les attendus !!
        // -------------------------------------------------------------------------------------- //

        // ------------
        // 01 - Le mail

        if (!filter_var($userData['email'], FILTER_VALIDATE_EMAIL)) {
            throw new Exception('Email invalide : ' . $userData['email']);
        }

        if ($this->emailExists($userData['email'])) {
            throw new Exception('Cet email est déjà utilisé');
        }

        // ------------
        // 02 - Le mot de passe

        // On à défini un valeur mini de 8
        if (strlen($userData['password']) > 8) {
            throw new Exception('Le mot de passe doit contenir au moins 8 caractères');
        }

        // On Vérifie qu'il y a au moins un caractère spécial
        if (!preg_match('/[\W_]/', $userData['password'])) {
            throw new Exception('Le mot de passe doit contenir au moins un caractère spécial');
        }


        // ------------
        // 03 - On fait l'insertion

        try {

            $reqInsert ="
                            INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe, role, actif) 
                            VALUES (:nom, :prenom, :email, :password, :role,now())";

            $stmt = $this->db->getPdo()->prepare($reqInsert);
            $stmt->bindParam(':nom', trim($userData['nom']));
            $stmt->bindParam(':prenom', trim($userData['prenom']));
            $stmt->bindParam(':email', trim($userData['email']));
            $stmt->bindParam(':password', password_hash($userData['password'], PASSWORD_DEFAULT));
            $stmt->bindParam(':role', $userData['role'] ?? 'utilisateur');
            $result = $stmt->execute();
            if ($result) {
                return $this->db->getPdo()->lastInsertId();
            } else {
                throw new Exception('Erreur lors de la création');
            }
        }
        catch (Exception $e) {
            throw new Exception('Erreur base de données : ' . $e->getMessage());
        }


    }

    /**
     * Mettre à jour la dernière connexion
     * @param int $userId
     * @return bool
     */
    public function updateLastLogin($userId) {
        try {
            $reqUpdate = "UPDATE utilisateurs SET last_login = NOW() WHERE id = ?";
            $stmt = $this->db->getPdo()->prepare($reqUpdate);
            return $stmt->execute([$userId]);
        } catch (Exception $e) {
            throw new Exception('Erreur mise à jour connexion : ' . $e->getMessage());
        }
    }


    // ===========================================
    // MÉTHODES Pour les SESSIONS
    // ===========================================

    /**
     * Créer la session après connexion réussie
     * @param array $user
     */
    public function createSession($user) {
        // Sécurité : régénérer l'ID de session
        session_regenerate_id(true);

        // Stocker les données utilisateur
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['user_email'] = $user['email'];
        $_SESSION['user_nom'] = $user['nom'];
        $_SESSION['user_prenom'] = $user['prenom'];
        $_SESSION['user_role'] = $user['role'];
        $_SESSION['login_time'] = time();

        // Mettre à jour la dernière connexion en BDD
        $this->updateLastLogin($user['id']);
    }

    /**
     * Vérifier si utilisateur connecté
     * @return bool
     */
    public function isLoggedIn() {
        return isset($_SESSION['user_id']);
    }

    /**
     * Vérifier le rôle de l'utilisateur connecté
     * @param string $role
     * @return bool
     */
    public function hasRole($role) {
        return $this->isLoggedIn() && $_SESSION['user_role'] === $role;
    }

    /**
     * Obtenir l'utilisateur connecté
     * @return array|null
     */
    public function getCurrentUser() {

        if (!$this->isLoggedIn()) {
            return null;
        }

        return [
            'id' => $_SESSION['user_id'],
            'email' => $_SESSION['user_email'],
            'nom' => $_SESSION['user_nom'],
            'prenom' => $_SESSION['user_prenom'],
            'role' => $_SESSION['user_role']
        ];
    }


    /**
     * Déconnexion complète
     */
    public function logout() {
        // Vider toutes les variables de session
        $_SESSION = [];

        // Supprimer le cookie de session si il existe
        if (ini_get("session.use_cookies")) {
            $params = session_get_cookie_params();
            setcookie(session_name(), '', time() - 42000,
                $params["path"], $params["domain"],
                $params["secure"], $params["httponly"]
            );
        }

        // Détruire la session
        session_destroy();
    }

    /**
     * Valider un rôle
     * @param string $role
     * @return bool
     */

    public function isValideRole($role) {
        return  in_array($role, ['admin', 'utilisateur', 'employe']);
    }

    // ===========================================
    // MÉTHODES TRUCS UTILES
    // ===========================================

    /**
     * Compter le nombre d'utilisateurs
     * @return int
     */
    public function count() {
        return $this->db->count('utilisateurs');
    }

    /**
     * Lister tous les utilisateurs (pour admin)
     * @param int $limit
     * @return array
     */
    public function getAll($limit = 50) {
        try {
            $stmt = $this->db->getPdo()->prepare("
                SELECT id, nom, prenom, email, role, actif, created_at, updated_at
                FROM utilisateurs 
                ORDER BY created_at DESC 
                LIMIT ?
            ");
            $stmt->execute([$limit]);
            return $stmt->fetchAll();
        } catch (Exception $e) {
            throw new Exception('Erreur récupération utilisateurs : ' . $e->getMessage());
        }
    }


}