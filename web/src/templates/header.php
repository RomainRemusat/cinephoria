<?php
// Démarrer la session si pas déjà fait
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Charger les helpers si pas déjà fait
if (!function_exists('isLoggedIn')) {
    require_once __DIR__ . '/../helpers/helpers.php';
}

include_once __DIR__ . '/../helpers/functions.php';

?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Cinéphoria - Cinéma moderne et responsable">
    <meta name="author" content="Cinéphoria">

    <title><?= $pageTitle ?? 'Cinéphoria - Cinéma. Émotions. Engagement.' ?></title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <!-- Google Fonts - Barlow -->
    <link href="https://fonts.googleapis.com/css2?family=Barlow:ital,wght@0,300;0,400;0,600;0,700;0,900;1,300;1,400;1,700;1,900&display=swap" rel="stylesheet">

    <!-- CSS personnalisé Cinéphoria -->
    <link href="assets/css/style.css" rel="stylesheet">

    <!-- Favicon -->
    <link rel="icon" type="image/x-icon" href="assets/images/favicon/favicon.ico">
</head>
<body>


<!-- Messages flash -->
<?php if ($flashes = getAllFlashes()): ?>
    <div class="position-relative">
        <?php foreach ($flashes as $type => $message): ?>
            <div class="alert alert-<?= $type === 'error' ? 'danger' : $type ?> alert-dismissible fade show m-0" role="alert">
                <i class="bi bi-<?= $type === 'success' ? 'check-circle' : ($type === 'error' ? 'exclamation-triangle' : 'info-circle') ?> me-2"></i>
                <?= clean($message) ?>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <?php endforeach; ?>
    </div>
<?php endif; ?>

<!-- Contenu principal -->

<!-- Navigation principale -->
<nav class="navbar navbar-expand-lg navbar-dark bg-primary-cinephoria">
    <div class="container">
        <!-- Logo -->
        <a class="navbar-brand fw-bold fs-3" href="index.php">
<!--            <i class="bi bi-film text-accent-cinephoria me-2"></i>-->
<!--            <span class="text-accent-cinephoria">CINÉ</span>PHORIA-->
            <img src="assets/images/logo/logo-cinephoria-simple.svg" alt="logo de la société cinéphoria" width="180" height="60">

        </a>

        <!-- Bouton mobile -->
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>

        <!-- Menu de navigation -->
        <div class="collapse navbar-collapse" id="navbarNav">
            <!-- Menu gauche -->
            <ul class="navbar-nav me-auto ">
                <li class="nav-item">
                    <a class="nav-link" href="index.php">
                        <i class="bi bi-house-door me-1"></i>Accueil
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="films.php">
                        <i class="bi bi-camera-reels me-1"></i>Films
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="reservation.php">
                        <i class="bi bi-ticket-perforated me-1"></i>Réservation
                    </a>
                </li>
                <li class="nav-item ">
                    <a class="nav-link" href="contact.php">
                        <i class="bi bi-envelope me-1"></i>Contact
                    </a>
                </li>
            </ul>

            <!-- Menu droite - Utilisateur -->
            <ul class="navbar-nav align-items-center">
                <?php if (isLoggedIn()): ?>
                    <?php $user = getCurrentUser(); ?>

                    <!-- Menu utilisateur connecté -->
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown">
                            <i class="bi bi-person-circle me-2"></i>
                            <?= clean($user['prenom'] . ' ' . $user['nom']) ?>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li>
                                <a class="dropdown-item" href="profile.php">
                                    <i class="bi bi-person me-2"></i>Mon profil
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item" href="mes-reservations.php">
                                    <i class="bi bi-ticket me-2"></i>Mes réservations
                                </a>
                            </li>

                            <?php if (isEmployee()): ?>
                                <li><hr class="dropdown-divider"></li>
                                <li>
                                    <a class="dropdown-item" href="intranet.php">
                                        <i class="bi bi-building me-2"></i>Intranet
                                    </a>
                                </li>
                            <?php endif; ?>

                            <?php if (isAdmin()): ?>
                                <li>
                                    <a class="dropdown-item" href="admin.php">
                                        <i class="bi bi-gear me-2"></i>Administration
                                    </a>
                                </li>
                            <?php endif; ?>

                            <li><hr class="dropdown-divider"></li>
                            <li>
                                <a class="dropdown-item text-danger" href="logout.php">
                                    <i class="bi bi-box-arrow-right me-2"></i>Déconnexion
                                </a>
                            </li>
                        </ul>
                    </li>

                <?php else: ?>
                    <!-- Menu utilisateur non connecté -->
                    <li class="nav-item">
                        <a class="nav-link" href="login.php">
                            <i class="bi bi-box-arrow-in-right me-1"></i>Connexion
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="btn btn-accent-cinephoria btn-sm ms-2" href="register.php">
                            <i class="bi bi-person-plus me-1"></i>S'inscrire
                        </a>
                    </li>
                <?php endif; ?>
            </ul>
        </div>
    </div>
</nav>


<main>