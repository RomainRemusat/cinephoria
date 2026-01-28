<?php
/**
 * API Endpoint - Récupération des films par Cinéma
 * * Ce script est appelé de manière asynchrone par le JavaScript (Fetch)
 * pour mettre à jour la grille des films sans recharger la page.
 *
 * @author romain@remusat.info / Cinéphoria
 * @version 1.0
 */

// On charge l'environnement (Autoloader, Session, Helpers)
require_once '../../src/helpers/helpers.php';

/**
 * Configuration du header pour le format JSON.
 * Indispensable pour que le JavaScript interprète la réponse comme un objet.
 */
header('Content-Type: application/json');

// Récupération de l'identifiant du cinéma passé en paramètre GET
$cinemaId = isset($_GET['cinema_id']) ? (int)$_GET['cinema_id'] : null;

// Validation de base de la requête
if (!$cinemaId) {
    http_response_code(400); // Bad Request
    echo json_encode(['error' => 'Identifiant du cinéma requis pour le filtrage.']);
    exit;
}

try {
    /**
     * Utilisation du modèle Cinema via le helper cinema().
     * On appelle la méthode métier getFilmsActifsByCinema() que nous avons ajoutée.
     */
    $films = cinema()->getFilmsActifsByCinema($cinemaId);

    /**
     * Retourne la liste des films encodée en JSON.
     * Note : Renvoie un tableau vide [] si aucun film n'est trouvé.
     */
    echo json_encode($films);

} catch (Exception $e) {
    /**
     * En cas d'erreur serveur, on journalise l'erreur et on informe le client.
     */
    logError("API Films Cinema Error: " . $e->getMessage());

    http_response_code(500); // Internal Server Error
    echo json_encode([
        'error' => 'Une erreur est survenue lors de la récupération des films.',
        'details' => $e->getMessage() // Optionnel : à masquer en production
    ]);
}