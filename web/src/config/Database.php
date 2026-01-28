<?php
class Database {

    private static $instance = null;
    private $pdo;

    private function __construct() {
        $this->connect();
    }

    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    private function connect() {
        // =================================================================
        // CONFIGURATION HYBRIDE (XAMPP + FLY.IO)
        // =================================================================

        // 1. Détection : Est-ce qu'on est sur Fly.io ?
        // Fly crée toujours cette variable automatiquement.
        if (getenv('FLY_APP_NAME')) {
            // --- CONFIGURATION PRODUCTION (FLY.IO) ---
            // On force les valeurs ici, on ne laisse pas le choix au code.
            $host = 'cinephoria-db-romain.internal'; // BUG pk ?
//            $host = '[fdaa:22:90bc:a7b:44f:7e1:2064:2]';
            $dbname = 'cinephoria';
            $user = 'root';
            $pass = 'root24Romain_12!'; // Votre mot de passe
        }
        else {
            // --- CONFIGURATION LOCAL (XAMPP) ---
            // On essaie de charger le .env s'il existe
            $this->loadEnv();
            $host = $_ENV['DB_HOST'] ?? 'localhost';
            $dbname = $_ENV['DB_NAME'] ?? 'cinephoria';
            $user = $_ENV['DB_USER'] ?? 'root';
            $pass = $_ENV['DB_PASS'] ?? '';
        }

        // =================================================================

        $dsn = "mysql:host={$host};dbname={$dbname};charset=utf8mb4";

        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
            PDO::ATTR_TIMEOUT => 5
        ];

        try {
            $this->pdo = new PDO($dsn, $user, $pass, $options);
        } catch (PDOException $e) {
            // On affiche l'hôte ($host) dans l'erreur pour savoir si on tape sur localhost ou Fly
            throw new Exception('Erreur connexion BDD (' . $host . ') : ' . $e->getMessage());
        }
    }

    /**
     * Petite fonction pour lire le .env en local seulement
     */
    private function loadEnv() {
        $envPath = __DIR__ . '/../../.env'; // Ajustez si besoin selon votre structure
        if (file_exists($envPath)) {
            $lines = file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
            foreach ($lines as $line) {
                if (strpos($line, '#') === 0) continue;
                if (strpos($line, '=') !== false) {
                    list($key, $value) = explode('=', $line, 2);
                    $_ENV[trim($key)] = trim($value);
                }
            }
        }
    }

    public function query($sql) {
        return $this->pdo->query($sql);
    }

    public function prepare($sql) {
        return $this->pdo->prepare($sql);
    }

    public function getPdo() {
        return $this->pdo;
    }
}
?>