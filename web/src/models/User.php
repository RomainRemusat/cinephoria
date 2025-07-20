<?php

class User {
    private $db;

    // Ne pas oublier !!!
    //    getPdo()	Retourne l’objet PDO pour faire des requêtes venant de database.php
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


}