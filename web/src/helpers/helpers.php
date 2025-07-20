<?php
/**
 * Helpers !!
 * Fichier pour charger les classe en autolad,
 * gèrer la connexion,
 * les messages flash
 * et autres fonctions pratiques genre les rediurection, sécu
 */

// ===========================================
// AUTOLOADER
// ===========================================

/**
 * Ce bout de code permet de charger automatiquement une classe PHP
 * sans avoir à faire "require_once" à chaque fois
 */
spl_autoload_register(function ($className) {
    $baseDir = realpath(__DIR__ . '/../'); // ← Va dans web/src

    $paths = [
        $baseDir . '/models/' . $className . '.php',
        $baseDir . '/config/' . $className . '.php',
    ];

    foreach ($paths as $path) {
        if (file_exists($path)) {
            require_once $path;
            return;
        }
    }

    throw new Exception("Classe $className introuvable");
});


// ===========================================
// RACCOURCIS POUR BASE DE DONNÉES ET USER
// ===========================================

/**
 * Raccourci pour obtenir l'objet Database (connexion PDO)
 */
function db() {
    return Database::getInstance();
}

/**
 * Raccourci pour créer un nouvel objet User
 */
function user() {
    return new User();
}

// ===========================================
// GESTION DE LA SESSION (connexion utilisateur)
// ===========================================

/**
 * Vérifie si un utilisateur est connecté
 */
function isLoggedIn() {
    return isset($_SESSION['user_id']);
}

/**
 * Vérifie si l'utilisateur a un rôle spécifique (ex : admin, employe)
 */
function hasRole($role) {
    return isLoggedIn() && $_SESSION['user_role'] === $role;
}

/**
 * Vérifie si l'utilisateur est un administrateur
 */
function isAdmin() {
    return hasRole('admin');
}

/**
 * Vérifie si l'utilisateur est un employé ou un admin
 */
function isEmployee() {
    return hasRole('employe') || hasRole('admin');
}

/**
 * Récupère les informations de l'utilisateur connecté
 */
function getCurrentUser() {
    if (!isLoggedIn()) {
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
 * Redirige vers la page de login si l'utilisateur n'est pas connecté
 */
function requireLogin($redirectTo = 'login.php') {
    if (!isLoggedIn()) {
        header('Location: ' . $redirectTo);
        exit();
    }
}

/**
 * Redirige si l'utilisateur n’a pas le bon rôle
 */
function requireRole($role, $redirectTo = 'index.php') {
    requireLogin();

    if (!hasRole($role)) {
        header('Location: ' . $redirectTo);
        exit();
    }
}

// ===========================================
// MESSAGES FLASH (affichés une seule fois)
// ===========================================

/**
 * Enregistre un message flash dans la session
 * Exemple : setFlash('success', 'Utilisateur créé')
 */
function setFlash($type, $message) {
    $_SESSION['flash'][$type] = $message;
}

/**
 * Récupère un message flash et le supprime (affichage unique)
 */
function getFlash($type) {
    if (isset($_SESSION['flash'][$type])) {
        $message = $_SESSION['flash'][$type];
        unset($_SESSION['flash'][$type]); // On le supprime après
        return $message;
    }
    return null;
}

/**
 * Récupère tous les messages flash d'un coup
 */
function getAllFlashes() {
    $flashes = $_SESSION['flash'] ?? [];
    unset($_SESSION['flash']);
    return $flashes;
}

// ===========================================
// FONCTIONS UTILES
// ===========================================

/**
 * Nettoie les données pour éviter les failles XSS
 */
function clean($data) {
    if (is_array($data)) {
        return array_map('clean', $data);
    }
    return htmlspecialchars(trim($data), ENT_QUOTES, 'UTF-8');
}

/**
 * Debug rapide (affiche une variable et arrête le script)
 */
function dd($data) {
    echo '<pre>';
    var_dump($data);
    echo '</pre>';
    die();
}

/**
 * Enregistre une erreur dans le fichier de log PHP
 */
function logError($message, $context = []) {
    $logMessage = date('Y-m-d H:i:s') . ' - ' . $message;
    if (!empty($context)) {
        $logMessage .= ' - Context: ' . json_encode($context);
    }
    error_log($logMessage);
}

/**
 * Redirection vers une autre page
 */
function redirect($url) {
    header('Location: ' . $url);
    exit();
}

