<?php
/**
 * Page de connexion - Cinéphoria
 * Feature: Auth
 */

// Démarrer la session
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Charger les dépendances
require_once '../src/helpers/helpers.php';
Database::getInstance();

// Rediriger si déjà connecté
if (isLoggedIn()) {
    redirect('index.php');
}

// Traitement du formulaire
$errors = [];
$formData = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Récupérer les données
        $email = trim($_POST['email'] ?? '');
        $password = $_POST['password'] ?? '';
        $remember = isset($_POST['remember']);

        // Stocker pour réaffichage
        $formData['email'] = $email;
        $formData['remember'] = $remember;

        // Validation de base
        if (empty($email)) {
            $errors['email'] = 'L\'email est requis';
        } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $errors['email'] = 'Format d\'email invalide';
        }

        if (empty($password)) {
            $errors['password'] = 'Le mot de passe est requis';
        }

        // Si pas d'erreurs, tenter la connexion
        if (empty($errors)) {
            $userModel = user();
            $loginResult = $userModel->login($email, $password);

//            echo"<pre>";
//            print_r($loginResult);
//            echo"</pre>";


            if ($loginResult) {
                // Connexion réussie
                $userModel->createSession($loginResult);

                // Gestion "Se souvenir de moi" (optionnel)
                if ($remember) {
                    // Créer un cookie sécurisé pour 30 jours
                    $rememberToken = bin2hex(random_bytes(32));
                    setcookie('remember_token', $rememberToken, time() + (30 * 24 * 60 * 60), '/', '', true, true);
                    // TODO: Stocker le token en BDD associé à l'utilisateur
                }

                setFlash('success', 'Connexion réussie ! Bienvenue ' . clean($loginResult['prenom']));

                // Redirection vers la page demandée ou accueil
                $redirectTo = $_GET['redirect'] ?? 'index.php';
                redirect($redirectTo);

            } else {
                // Connexion échouée
                $errors['login'] = 'Email ou mot de passe incorrect';
                logError('Tentative de connexion échouée', ['email' => $email, 'ip' => $_SERVER['REMOTE_ADDR']]);
            }
        }

    } catch (Exception $e) {
        $errors['general'] = 'Une erreur est survenue. Veuillez réessayer.';
        logError('Erreur lors de la connexion', ['error' => $e->getMessage(), 'email' => $email ?? '']);
    }
}

// Configuration de la page
$pageTitle = 'Connexion - Cinéphoria';
?>

<?php include '../src/templates/header.php'; ?>

    <div class="container full-height d-flex align-items-center">
        <div class="row justify-content-center w-100">
            <div class="col-lg-5 col-md-7 col-sm-9">

                <!-- Header de la page -->
                <div class="text-center mb-4">
                    <h1 class="text-primary-cinephoria mb-2">
                        <i class="bi bi-box-arrow-in-right text-accent-cinephoria me-2"></i>
                        Connexion
                    </h1>
                    <p class="text-muted">
                        Connectez-vous pour accéder à votre espace personnel
                    </p>
                </div>

                <!-- Formulaire de connexion -->
                <form method="POST" class="auth-form fade-in" novalidate>

                    <!-- Message d'erreur général -->
                    <?php if (isset($errors['general'])): ?>
                        <div class="alert alert-danger" role="alert">
                            <i class="bi bi-exclamation-triangle me-2"></i>
                            <?= clean($errors['general']) ?>
                        </div>
                    <?php endif; ?>

                    <?php if (isset($errors['login'])): ?>
                        <div class="alert alert-danger" role="alert">
                            <i class="bi bi-shield-exclamation me-2"></i>
                            <?= clean($errors['login']) ?>
                        </div>
                    <?php endif; ?>

                    <!-- Champ Email -->
                    <div class="mb-3">
                        <label for="email" class="form-label">
                            <i class="bi bi-envelope me-1"></i>
                            Adresse email
                        </label>
                        <input
                            type="email"
                            class="form-control <?= isset($errors['email']) ? 'is-invalid' : '' ?>"
                            id="email"
                            name="email"
                            value="<?= clean($formData['email'] ?? '') ?>"
                            placeholder="votre@email.com"
                            required
                            autocomplete="email"
                            autofocus
                        >
                        <?php if (isset($errors['email'])): ?>
                            <div class="invalid-feedback">
                                <?= clean($errors['email']) ?>
                            </div>
                        <?php endif; ?>
                    </div>

                    <!-- Champ Mot de passe -->
                    <div class="mb-3">
                        <label for="password" class="form-label">
                            <i class="bi bi-lock me-1"></i>
                            Mot de passe
                        </label>
                        <div class="input-group">
                            <input
                                type="password"
                                class="form-control <?= isset($errors['password']) ? 'is-invalid' : '' ?>"
                                id="password"
                                name="password"
                                placeholder="Votre mot de passe"
                                required
                                autocomplete="current-password"
                            >
                            <button
                                class="btn btn-outline-secondary"
                                type="button"
                                id="togglePassword"
                                title="Afficher/masquer le mot de passe"
                            >
                                <i class="bi bi-eye" id="eyeIcon"></i>
                            </button>
                            <?php if (isset($errors['password'])): ?>
                                <div class="invalid-feedback">
                                    <?= clean($errors['password']) ?>
                                </div>
                            <?php endif; ?>
                        </div>
                    </div>

                    <!-- Options -->
                    <div class="row mb-4">
                        <div class="col">
                            <!-- Case "Se souvenir de moi" -->
                            <div class="form-check">
                                <input
                                    class="form-check-input"
                                    type="checkbox"
                                    id="remember"
                                    name="remember"
                                    <?= ($formData['remember'] ?? false) ? 'checked' : '' ?>
                                >
                                <label class="form-check-label" for="remember">
                                    Se souvenir de moi
                                </label>
                            </div>
                        </div>
                        <div class="col text-end">
                            <!-- Lien mot de passe oublié -->
                            <a href="forgot-password.php" class="text-accent-cinephoria text-decoration-none">
                                <small>Mot de passe oublié ?</small>
                            </a>
                        </div>
                    </div>

                    <!-- Bouton de connexion -->
                    <div class="d-grid mb-4">
                        <button type="submit" class="btn btn-accent-cinephoria btn-lg">
                            <i class="bi bi-box-arrow-in-right me-2"></i>
                            Se connecter
                        </button>
                    </div>

                    <!-- Liens vers inscription -->
                    <div class="text-center">
                        <p class="mb-0">
                            Pas encore de compte ?
                            <a href="register.php" class="text-accent-cinephoria fw-bold text-decoration-none">
                                Créez votre compte
                            </a>
                        </p>
                    </div>
                </form>

                <!-- Comptes de test (à supprimer en production) -->
                <?php if ($_ENV['APP_ENV'] !== 'production'): ?>
                    <div class="mt-4">
                        <details class="text-center">
                            <summary class="text-muted small" style="cursor: pointer;">
                                <i class="bi bi-info-circle me-1"></i>
                                Comptes de test disponibles
                            </summary>
                            <div class="mt-2 small">
                                <div class="alert alert-info py-2">
                                    <strong>Admin :</strong> admin@cinephoria.com / Admin123!<br>
                                    <strong>Employé :</strong> employe1@cinephoria.com / Employe123!<br>
                                    <strong>Client :</strong> julie.leblanc@gmail.com / Client123!
                                </div>
                            </div>
                        </details>
                    </div>
                <?php endif; ?>

            </div>
        </div>
    </div>

<?php
// JavaScript spécifique à cette page
$pageScript = 'login.js';
include '../src/templates/footer.php';
?>