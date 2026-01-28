<?php
/**
 * Page d'accueil - Cinéphoria
 * * Cette page gère l'affichage du Hero Slideshow (films vedettes) en SSR (Server Side Rendering)
 * et initialise le conteneur pour le chargement dynamique des films par cinéma via AJAX.
 * * @author romain@remusat.info
 * @version 2.0 - Migration vers architecture Hybride (PHP/JS Fetch)
 */

// Initialisation de la session pour la gestion des préférences et authentification
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Chargement du noyau de l'application (Autoloading des classes et fonctions helpers)
require_once '../src/helpers/helpers.php';

// Initialisation de la connexion Singleton
Database::getInstance();

$pageTitle = 'Accueil - Cinéphoria | Cinéma. Émotions. Engagement.';

try {
    /** @var Cinema $cinemaModel Instance du modèle Cinema via helper */
    $cinemaModel = cinema();
    $db = db();

    /** * 1. RÉCUPÉRATION DES FILMS VEDETTES (Slideshow)
     * On conserve ce rendu en PHP pour garantir un affichage immédiat et optimiser le SEO.
     */
    $stmt = $db->getPdo()->prepare("
        SELECT f.*, c.nom as categorie_nom,
               COUNT(DISTINCT s.id) as nb_seances,
               MIN(s.prix) as prix_min,
               MIN(s.date_seance) as prochaine_seance
        FROM films f
        LEFT JOIN categories c ON f.categorie_id = c.id
        LEFT JOIN seances s ON f.id = s.film_id AND s.date_seance >= CURDATE()
        WHERE f.statut = 'a_venir' OR f.statut = 'en_cours'
        GROUP BY f.id
        ORDER BY f.id DESC
        LIMIT 3
    ");
    $stmt->execute();
    $filmsVedettes = $stmt->fetchAll();

    /** * 2. RÉCUPÉRATION DES CINÉMAS
     * Utilisé pour construire la selectbox de filtrage dynamique.
     */
    $ListCinema = $cinemaModel->getInfos();

    /** * 3. STATISTIQUES GLOBALES
     * Données de réassurance pour le footer ou les sections d'engagement.
     */
    $stats = $cinemaModel->getAllWithStats();

} catch (Exception $e) {
    // Log de l'erreur et initialisation de fallbacks pour éviter le plantage de l'interface
    logError('Erreur chargement accueil', ['error' => $e->getMessage()]);
    $filmsVedettes = [];
    $ListCinema = [];
    $stats = [];
}
?>

<?php include '../src/templates/header.php'; ?>

    <link href="assets/css/hero.css" rel="stylesheet">

    <section class="hero-slideshow">
        <?php if (!empty($filmsVedettes)): ?>
            <div id="filmCarousel" class="carousel slide" data-bs-ride="carousel" data-bs-interval="5000" style="max-height: 45vh; overflow: hidden;">
                <div class="carousel-inner">
                    <?php foreach ($filmsVedettes as $index => $film): ?>
                        <div class="carousel-item <?= $index === 0 ? 'active' : '' ?>">
                            <div class="hero-slide" style="background-image: linear-gradient(rgba(30, 58, 95, 0.2), rgba(30, 58, 95, 0.4)), url('assets/images/backgrounds/<?= clean($film['affiche']) ?>'); ">
                                <div class="container">
                                    <div class="row align-items-center" style="min-height: 45vh;">
                                        <div class="col-lg-7">
                                            <div class="text-white">
                                                <div class="mb-3">
                                                    <?php if ($film['note_moyenne'] > 0): ?>
                                                        <span class="badge rounded-pill text-bg-dark px-2 py-2 ">
                                                            <i class="bi bi-star-fill text-warning"></i>
                                                            <?= number_format($film['note_moyenne'], 1) ?>
                                                        </span>
                                                    <?php endif; ?>
                                                </div>
                                                <h1 class="display-3 fw-bold mb-3 hero-title text-white"><?= clean($film['titre']) ?></h1>
                                                <div class="mb-4 fs-5">
                                                    <span class="me-4"><i class="bi bi-clock-fill me-2 text-warning"></i><?= $film['duree'] ?> min</span>
                                                </div>
                                                <div class="d-flex flex-wrap gap-3">
                                                    <a href="films.php?id=<?= $film['id'] ?>" class="btn btn-warning btn-lg">Découvrir</a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>
        <?php endif; ?>
    </section>

    <section class="py-5">
        <div class="bg-light border border-light-subtle container bg-white p-4 rounded shadow-sm">
            <h5 class="fw-bold">Les séances dans mon cinéma</h5>
            <form>
                <div class="form-group mt-3">
                    <label for="cinemaSelect" class="form-label visually-hidden">Choisir un cinéma</label>
                    <select class="form-select" id="cinemaSelect">
                        <?php $valeurPrecedente = ""; ?>
                        <?php foreach ($ListCinema as $value) : ?>
                        <?php if ($value['pays'] != $valeurPrecedente) : ?>
                        <?php if ($valeurPrecedente !== "") echo '</optgroup>'; ?>
                        <optgroup label="<?= clean($value['pays']) ?>">
                            <?php endif; ?>
                            <option value="<?= $value['id'] ?>"><?= clean($value['ville']) ?></option>
                            <?php $valeurPrecedente = $value['pays']; ?>
                            <?php endforeach; ?>
                        </optgroup>
                    </select>
                </div>
            </form>
        </div>
    </section>

    <section class="py-5">
        <div class="container">
            <div class="row mb-5 text-center">
                <h2 class="display-6 text-primary fw-bolder">À l'affiche dans votre cinéma</h2>
                <p class="lead text-muted">Programmation mise à jour en temps réel</p>
            </div>

            <div id="filmsContainer" class="row g-4">
                <div class="col-12 text-center py-5">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Chargement...</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="py-5 bg-success bg-opacity-10">
    </section>

    <script src="assets/js/home.js"></script>

<?php include '../src/templates/footer.php'; ?>