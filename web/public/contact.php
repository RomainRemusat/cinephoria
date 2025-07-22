<?php
/**
 * Page d'accueil - Cinéphoria
 * Version finale avec slideshow
 */

// Démarrer la session
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Charger les dépendances
require_once '../src/helpers/helpers.php';
Database::getInstance();

$pageTitle = 'Contact - Cinéphoria | Cinéma. Émotions. Engagement.';

?>

<?php include '../src/templates/header.php'; ?>
<?php include '../src/templates/footer.php'; ?>
