<?php
/**
 * Database.php - Version simple
 * Étape 1.1 : Juste l'essentiel pour valider la connexion
 */

class Database {

    private static $instance = null;
    private $pdo;

    /**
     * Constructeur privé (Singleton)
     */
    private function __construct() {
        $this->loadConfig();
        $this->connect();
    }

    /**
     * Obtenir l'instance unique
     */
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    /**
     * Charger la config depuis .env
     */
    private function loadConfig() {
//        $envPath = __DIR__ . '/../../config/.env';
        $envPath = __DIR__ . '/.env';  // Chemin corrigé

        if (!file_exists($envPath)) {
            throw new Exception('Fichier .env introuvable : ' . $envPath);
        }

        // Lire le fichier ligne par ligne
        $lines = file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

        foreach ($lines as $line) {
            // Ignorer les commentaires
            if (strpos($line, '#') === 0) {
                continue;
            }

            // Séparer clé=valeur
            if (strpos($line, '=') !== false) {
                list($key, $value) = explode('=', $line, 2);
                $_ENV[trim($key)] = trim($value);
            }
        }
    }

    /**
     * Établir la connexion PDO
     */
    private function connect() {
        $host = $_ENV['DB_HOST'] ?? 'localhost';
        $dbname = $_ENV['DB_NAME'] ?? 'cinephoria';
        $username = $_ENV['DB_USER'] ?? 'root';
        $password = $_ENV['DB_PASS'] ?? '';

        $dsn = "mysql:host={$host};dbname={$dbname};charset=utf8mb4";

        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ];

        try {
            $this->pdo = new PDO($dsn, $username, $password, $options);
            echo "<!-- Connexion PDO réussie -->\n";
        } catch (PDOException $e) {
            throw new Exception('Erreur connexion BDD : ' . $e->getMessage());
        }
    }

    // ===========================================
    // MÉTHODES POUR TESTER
    // ===========================================

    /**
     * Exécuter une requête simple
     */
    public function query($sql) {
        try {
            return $this->pdo->query($sql);
        } catch (PDOException $e) {
            throw new Exception('Erreur requête : ' . $e->getMessage());
        }
    }

    /**
     * Compter des enregistrements
     */
    public function count($table) {
        $stmt = $this->query("SELECT COUNT(*) as total FROM {$table}");
        $result = $stmt->fetch();
        return (int)$result['total'];
    }

    /**
     * Récupérer un utilisateur par email
     */
    public function getUserByEmail($email) {
        $stmt = $this->pdo->prepare("SELECT * FROM utilisateurs WHERE email = ?");
        $stmt->execute([$email]);
        return $stmt->fetch();
    }

    /**
     * Obtenir l'objet PDO (pour les classes métier)
     */
    public function getPdo() {
        return $this->pdo;
    }

    /**
     * Test de connexion simple
     */
    public function testConnection() {
        try {
            $stmt = $this->pdo->query('SELECT 1 as test');
            $result = $stmt->fetch();
            return $result['test'] === 1;
        } catch (Exception $e) {
            return false;
        }
    }

    /**
     * Empêche la duplication de l'instance (important pour le Singleton)
     *
     * - __clone() est privé pour empêcher qu'on duplique l'objet avec "clone"
     *   Exemple interdit : $copie = clone $db;
     *
     * - __wakeup() déclenche une erreur si on essaie de "réveiller" (unserialize)
     *   Exemple interdit : $db2 = unserialize(serialize($db));
     *
     * Cela garantit qu'on a toujours une seule instance de la classe Database
     */

    private function __clone() {}
    public function __wakeup() {
        throw new Exception("Singleton cannot be unserialized");
    }
}

?>