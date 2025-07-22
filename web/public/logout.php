<?php
/**
 * Page de déconnexion - Cinéphoria
 * Feature: Auth
 */

// Démarrer la session
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Charger les dépendances
require_once '../src/helpers/helpers.php';

// Vérifier si l'utilisateur est connecté
if (isLoggedIn()) {
    $userName = getCurrentUser()['prenom'] ?? 'Utilisateur';

    // Déconnexion via la classe User
    $userModel = user();
    $userModel->logout();

    // Message de confirmation
    setFlash('success', 'Vous avez été déconnecté avec succès. À bientôt ' . clean($userName) . ' !');
} else {
    // Utilisateur déjà déconnecté
    setFlash('info', 'Vous étiez déjà déconnecté.');
}

// Redirection vers l'accueil
redirect('index.php');
?>