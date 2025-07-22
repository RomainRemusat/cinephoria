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
        try{
            $req = "SELECT * FROM cinemas WHERE id = ? AND actif = 1";
            $stmt = $this->db->getPdo()->prepare($req);
            $stmt->execute([$id]);
            return $stmt->fetch();
        }
        catch(Exception $e){
            throw new Exception('Erreur recherche utilisateur : ' . $e->getMessage());
        }
    }


}
?>