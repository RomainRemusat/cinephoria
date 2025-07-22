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

$pageTitle = 'Accueil - Cinéphoria | Cinéma. Émotions. Engagement.';

// Récupérer les données pour l'accueil
try {
    $db = db();

    // Les 3 DERNIERS films pour le slideshow hero
    $stmt = $db->getPdo()->prepare("
        SELECT f.*, c.nom as categorie_nom,
               COUNT(DISTINCT s.id) as nb_seances,
               MIN(s.prix) as prix_min,
               MIN(s.date_seance) as prochaine_seance
        FROM films f
        LEFT JOIN categories c ON f.categorie_id = c.id
        LEFT JOIN seances s ON f.id = s.film_id AND s.date_seance >= CURDATE()
        WHERE f.statut = 'en_cours'
        GROUP BY f.id
        HAVING nb_seances > 0
        ORDER BY f.id DESC
        LIMIT 3
    ");
    $stmt->execute();
    $filmsVedettes = $stmt->fetchAll();

    // Les autres films pour la section "À l'affiche"
    $stmt = $db->getPdo()->prepare("
        SELECT f.*, c.nom as categorie_nom, 
               COUNT(DISTINCT s.id) as nb_seances,
               MIN(s.prix) as prix_min,
               MIN(s.date_seance) as prochaine_seance
        FROM films f
        LEFT JOIN categories c ON f.categorie_id = c.id
        LEFT JOIN seances s ON f.id = s.film_id AND s.date_seance >= CURDATE()
        WHERE f.statut = 'en_cours'
        GROUP BY f.id
        HAVING nb_seances > 0
        ORDER BY f.note_moyenne DESC, f.created_at DESC
        LIMIT 6
    ");
    $stmt->execute();
    $filmsAffiche = $stmt->fetchAll();

    // Statistiques générales
    $stmt = $db->getPdo()->query("
        SELECT 
            (SELECT COUNT(*) FROM films WHERE statut = 'en_cours') as films_actifs,
            (SELECT COUNT(*) FROM seances WHERE date_seance >= CURDATE()) as seances_disponibles,
            (SELECT COUNT(*) FROM utilisateurs WHERE role = 'utilisateur') as membres,
            (SELECT COUNT(*) FROM salles WHERE actif = TRUE) as salles
    ");
    $stats = $stmt->fetch();

} catch (Exception $e) {
    logError('Erreur chargement accueil', ['error' => $e->getMessage()]);
    $filmsVedettes = [];
    $filmsAffiche = [];
    $stats = ['films_actifs' => 0, 'seances_disponibles' => 0, 'membres' => 0, 'salles' => 0];
}
?>

<?php include '../src/templates/header.php'; ?>

    <!-- CSS personnalisé Cinéphoria -->
    <link href="assets/css/hero.css" rel="stylesheet">

    <!-- Hero Section avec slideshow -->
    <section class="hero-slideshow">
        <?php if (!empty($filmsVedettes)): ?>
            <!-- Carousel Bootstrap -->
            <div id="filmCarousel" class="carousel slide" data-bs-ride="carousel" data-bs-interval="5000" style="max-height: 45vh; overflow: hidden;">

                <!-- Slides des 3 derniers films -->
                <div class="carousel-inner">
                    <?php foreach ($filmsVedettes as $index => $film): ?>
                        <div class="carousel-item <?= $index === 0 ? 'active' : '' ?>">
                            <!-- Background avec image du film -->
                            <div class="hero-slide" style="background-image: linear-gradient(rgba(30, 58, 95, 0.2), rgba(30, 58, 95, 0.4)), url('assets/images/backgrounds/<?= clean($film['affiche']) ?>'); ">
                                <div class="container">
                                    <div class="row align-items-center" style="min-height: 45vh;">

                                        <!-- Contenu texte -->
                                        <div class="col-lg-7 col-md-8">
                                            <div class="text-white">
                                                <!-- Badge nouveau film -->
                                                <div class="mb-3">
                                                    <?php if ($film['note_moyenne'] > 0): ?>
                                                        <span class="badge rounded-pill text-bg-dark px-2 py-2 ">
                                                            <i class="bi bi-star-fill text-warning"></i>
                                                            <?= number_format($film['note_moyenne'], 1) ?>
                                                    </span>


                                                    <?php endif; ?>
                                                </div>

                                                <!-- Titre -->
                                                <h1 class="display-3 fw-bold mb-3 hero-title text-white">
                                                    <?= clean($film['titre']) ?>
                                                </h1>

                                                <!-- Infos film -->
                                                <div class="mb-4 fs-5">
                                                    <?php if ($film['categorie_nom']): ?>
                                                        <span class="me-4">
                                                        <i class="bi bi-tag-fill me-2 text-warning"></i>
                                                        <?= clean($film['categorie_nom']) ?>
                                                    </span>
                                                    <?php endif; ?>
                                                    <span class="me-4">
                                                    <i class="bi bi-clock-fill me-2 text-warning"></i>
                                                    <?= $film['duree'] ?> minutes
                                                </span>
                                                </div>

                                                <!-- Description -->
                                                <?php if ($film['description']): ?>
                                                    <p class="lead mb-4 hero-description" style="max-width: 500px;">
                                                        <?= clean(substr($film['description'], 0, 120)) ?>...
                                                    </p>
                                                <?php endif; ?>

                                                <!-- Infos pratiques -->
                                                <div class="row g-3 mb-4">
                                                    <div class="col-auto">
                                                        <div class="stat-box">
                                                            <div class="h4 text-warning mb-1"><?= $film['nb_seances'] ?></div>
                                                            <small>Séances</small>
                                                        </div>
                                                    </div>
                                                    <div class="col-auto">
                                                        <div class="stat-box">
                                                            <div class="h4 text-warning mb-1">€<?= number_format($film['prix_min'], 2) ?></div>
                                                            <small>Dès</small>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Boutons -->
                                                <div class="d-flex flex-wrap gap-3">
                                                    <?php if (isLoggedIn()): ?>
                                                        <a href="reservation.php?film_id=<?= $film['id'] ?>" class="btn btn-warning btn-lg">
                                                            <i class="bi bi-ticket-perforated me-2"></i>
                                                            Réserver
                                                        </a>
                                                    <?php else: ?>
                                                        <a href="login.php" class="btn btn-warning btn-lg">
                                                            <i class="bi bi-box-arrow-in-right me-2"></i>
                                                            Se connecter
                                                        </a>
                                                    <?php endif; ?>
                                                    <a href="films.php?id=<?= $film['id'] ?>" class="btn btn-outline-light btn-lg">
                                                        <i class="bi bi-info-circle me-2"></i>
                                                        Découvrir
                                                    </a>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Affiche du film -->
                                        <div class="col-lg-5 col-md-4 text-center d-none d-lg-block">
                                            <?php if ($film['affiche']): ?>
                                                <img src="assets/images/affiches/<?= clean($film['affiche']) ?>"
                                                     class="poster-image shadow-lg"
                                                     alt="<?= clean($film['titre']) ?>">
                                            <?php else: ?>
                                                <div class="poster-placeholder">
                                                    <i class="bi bi-camera-reels text-white opacity-50" style="font-size: 4rem;"></i>
                                                </div>
                                            <?php endif; ?>
                                        </div>

                                    </div>
                                </div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>

                <!-- Contrôles -->
                <button class="carousel-control-prev" type="button" data-bs-target="#filmCarousel" data-bs-slide="prev">
                    <span class="carousel-control-prev-icon"></span>
                    <span class="visually-hidden">Précédent</span>
                </button>
                <button class="carousel-control-next" type="button" data-bs-target="#filmCarousel" data-bs-slide="next">
                    <span class="carousel-control-next-icon"></span>
                    <span class="visually-hidden">Suivant</span>
                </button>

                <!-- Indicateurs -->
                <div class="carousel-indicators">
                    <?php foreach ($filmsVedettes as $index => $film): ?>
                        <button type="button" data-bs-target="#filmCarousel" data-bs-slide-to="<?= $index ?>"
                                class="<?= $index === 0 ? 'active' : '' ?>"></button>
                    <?php endforeach; ?>
                </div>

            </div>

        <?php else: ?>
            <!-- Fallback -->
            <div class="hero-fallback">
                <div class="container text-center text-white py-5" style="min-height: 60vh; display: flex; align-items: center; justify-content: center;">
                    <div>
                        <h1 class="display-2 mb-4">🎬 Cinéphoria</h1>
                        <p class="lead mb-4">Découvrez notre programmation cinéma</p>
                        <?php if (!isLoggedIn()): ?>
                            <a href="register.php" class="btn btn-warning btn-lg">Créer un compte</a>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
        <?php endif; ?>
    </section>
    <!-- Section choix cinéma -->
    <section class=" py-5">
        <div class="bg-light border border-light-subtle container bg-white p-4 rounded shadow-sm">
            <h5>Les séances dans mon cinéma</h5>
            <form>
                <?php
                $cinemaModel = Cinema();
                $ListCinema = $cinemaModel->getInfos();
                ?>

                <div class="form-group mt-3">
                    <label for="cinemaSelect" class="form-label visually-hidden">Choisir un cinéma</label>
                    <select class="form-select" id="cinemaSelect" aria-label="Choisir un cinéma">

                        <?php $valeurPrecedente = ""; ?>
                        <?php foreach ($ListCinema as $key => $value) { ?>
                        <?php if ($value['pays'] != $valeurPrecedente) : ?>
                        <?php if ($valeurPrecedente !== "") : ?>
                            </optgroup>
                        <?php endif; ?>
                            <optgroup label="<?= $value['pays'] ?>">
                                <?php endif; ?>
                                <option value="<?= $value['id'] ?>"><?= $value['ville'] ?></option>
                                <?php $valeurPrecedente = $value['pays']; ?>
                                <?php } ?>
                                <?php if ($valeurPrecedente !== "") : ?>
                            </optgroup>
                        <?php endif; ?>


                    </select>
                </div>
            </form>
        </div>
    </section>

    <!-- Section Films à l'affiche -->
    <?php if (!empty($filmsAffiche)): ?>
        <section class="py-5 ">
            <div class="container">
                <!-- Header section -->
                <div class="row mb-5">
                    <div class="col-12 text-center">
                        <h2 class="display-6 text-primary mb-3 fw-bolder fst-italic">
                            <i class="bi bi-camera-reels text-warning me-2"></i>
                            Tous nos films à l'affiche
                        </h2>
                        <p class="lead text-muted">
                            <?= count($filmsAffiche) ?> films avec séances disponibles
                        </p>
                    </div>
                </div>

                <!-- Films grid -->
                <div class="row g-4">
                    <?php foreach ($filmsAffiche as $film): ?>
                        <div class="col-lg-4 col-md-6">
                            <div class="card h-100 shadow-sm film-card">
                                <!-- Image -->
                                <div class="card-img-top-wrapper">
                                    <?php if ($film['affiche']): ?>
                                        <img src="assets/images/affiches/<?= clean($film['affiche']) ?>"
                                             class="card-img-top"
                                             alt="<?= clean($film['titre']) ?>"
                                             style="height: 250px; object-fit: cover;">
                                    <?php else: ?>
                                        <div class="bg-light d-flex align-items-center justify-content-center" style="height: 250px;">
                                            <i class="bi bi-camera-reels text-muted" style="font-size: 3rem;"></i>
                                        </div>
                                    <?php endif; ?>

                                    <!-- Note -->
                                    <?php if ($film['note_moyenne'] > 0): ?>
                                        <div class="film-rating">
                                            <i class="bi bi-star-fill text-warning"></i>
                                            <?= number_format($film['note_moyenne'], 1) ?>
                                        </div>
                                    <?php endif; ?>
                                </div>

                                <!-- Contenu -->
                                <div class="card-body">
                                    <h5 class="card-title"><?= clean($film['titre']) ?></h5>

                                    <?php if ($film['categorie_nom']): ?>
                                        <span class="badge bg-secondary mb-2"><?= clean($film['categorie_nom']) ?></span>
                                    <?php endif; ?>

                                    <p class="card-text small text-muted">
                                        <i class="bi bi-clock me-1"></i><?= $film['duree'] ?> min
                                        • <?= $film['nb_seances'] ?> séance(s)
                                        • Dès <?= number_format($film['prix_min'], 2) ?>€
                                    </p>

                                    <?php if ($film['description']): ?>
                                        <p class="card-text small">
                                            <?= clean(substr($film['description'], 0, 80)) ?>...
                                        </p>
                                    <?php endif; ?>
                                </div>

                                <!-- Footer -->
                                <div class="card-footer bg-transparent">
                                    <div class="d-grid gap-2">
                                        <?php if (isLoggedIn()): ?>
                                            <a href="reservation.php?film_id=<?= $film['id'] ?>" class="btn btn-warning">
                                                <i class="bi bi-ticket me-2"></i>Réserver
                                            </a>
                                        <?php else: ?>
                                            <a href="login.php" class="btn btn-outline-primary">
                                                Se connecter pour réserver
                                            </a>
                                        <?php endif; ?>
                                    </div>
                                </div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>
        </section>
    <?php endif; ?>

    <!-- Section engagement -->
    <section class="py-5 bg-success bg-opacity-10">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-8">
                    <h3 class="h2 text-primary mb-3">
                        <i class="bi bi-leaf-fill text-success me-2"></i>
                        Notre engagement éco-responsable
                    </h3>
                    <p class="lead mb-3">
                        Chez Cinéphoria, nous croyons qu'on peut allier passion du cinéma et respect de l'environnement.
                    </p>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <div class="d-flex align-items-center">
                                <i class="bi bi-check-circle-fill text-success me-3"></i>
                                <span>20% de nos revenus soutiennent l'écologie</span>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="d-flex align-items-center">
                                <i class="bi bi-check-circle-fill text-success me-3"></i>
                                <span>Salles éco-énergétiques certifiées</span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 text-center">
                    <i class="bi bi-globe-central-south-asia text-success opacity-75" style="font-size: 5rem;"></i>
                </div>
            </div>
        </div>
    </section>



<?php include '../src/templates/footer.php'; ?>