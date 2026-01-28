<?php
/**
 * Database.php - Version compatible XAMPP (Local) ET Fly.io (Prod)
 */

class Database {

    private static $instance = null;
    private $pdo;

    private function __construct() {
        // On essaie de charger la config, mais sans planter si le fichier n'est pas là
        $this->loadConfig();
        $this->connect();
    }

    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    /**
     * Charger la config de manière souple
     */
    private function loadConfig() {
        // Chemin vers le fichier .env (pour le local)
        $envPath = __DIR__ . '/.env'; // Ou '/../../config/.env' selon votre structure

        // Si le fichier existe (LOCAL), on le lit
        if (file_exists($envPath)) {
            $lines = file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
            foreach ($lines as $line) {
                if (strpos($line, '#') === 0) continue;
                if (strpos($line, '=') !== false) {
                    list($key, $value) = explode('=', $line, 2);
                    $key = trim($key);
                    $value = trim($value);

                    // On remplit $_ENV et on rend dispo via getenv()
                    $_ENV[$key] = $value;
                    putenv("$key=$value");
                }
            }
        }
        // Si le fichier n'existe pas (FLY.IO), on ne fait rien et on continue !
        // On fera confiance aux variables d'environnement natives.
    }

    private function connect() {
        // C'EST ICI LA CLÉ :
        // On cherche d'abord dans les variables système (Fly.io) via getenv()
        // Sinon dans $_ENV (Local)
        // Sinon on prend une valeur par défaut

        $host = getenv('DB_HOST') ?: ($_ENV['DB_HOST'] ?? 'localhost');
        $dbname = getenv('DB_NAME') ?: ($_ENV['DB_NAME'] ?? 'cinephoria');
        $user = getenv('DB_USER') ?: ($_ENV['DB_USER'] ?? 'root');
        $pass = getenv('DB_PASS') ?: ($_ENV['DB_PASS'] ?? '');

        // Correction pour le port (parfois nécessaire)
        // Si l'hôte contient un port (ex: hostname:3306), PDO gère mal parfois
        // Mais Fly.io utilise le port standard 3306 par défaut.

        $dsn = "mysql:host={$host};dbname={$dbname};charset=utf8mb4";

        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
            // Option importante pour éviter les timeout de connexion sur le cloud
            PDO::ATTR_TIMEOUT => 5
        ];

        try {
            $this->pdo = new PDO($dsn, $user, $pass, $options);
            // On commente l'echo pour éviter de casser le JSON ou l'affichage HTML en prod
            // echo "\n";
        } catch (PDOException $e) {
            // En prod, il vaut mieux ne pas afficher le mot de passe dans l'erreur
            // On affiche juste le message générique + l'erreur technique
            throw new Exception('Erreur connexion BDD (' . $host . ') : ' . $e->getMessage());
        }
    }

    public function query($sql) {
        return $this->pdo->query($sql);
    }

    public function getPdo() {
        return $this->pdo;
    }

    private function __clone() {}
    public function __wakeup() {
        throw new Exception("Singleton cannot be unserialized");
    }
}
?>