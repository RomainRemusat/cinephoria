<?php
/**
 * Page d'inscription - Cinéphoria
 * Feature: Auth
 */

// Démarrer la session si pas déjà, démarré
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Charger les dépendances
require_once '../src/helpers/helpers.php';
Database::getInstance();

// On redirige si déjà connecté
if (isLoggedIn()) {
    redirect('index.php');
}

// Traitement du formulaire
$errors = [];
$formData = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Récupérer les données
        $nom = trim($_POST['nom'] ?? '');
        $prenom = trim($_POST['prenom'] ?? '');
        $email = trim($_POST['email'] ?? '');
        $password = $_POST['password'] ?? '';
        $confirmPassword = $_POST['confirm_password'] ?? '';
        $telephone = trim($_POST['telephone'] ?? '');
        $dateNaissance = $_POST['date_naissance'] ?? '';

        // Stocker pour réaffichage
        $formData = [
            'nom' => $nom,
            'prenom' => $prenom,
            'email' => $email,
            'telephone' => $telephone,
            'date_naissance' => $dateNaissance
        ];

        // Validations de base
        if (empty($nom)) {
            $errors['nom'] = 'Le nom est requis';
        }

        if (empty($prenom)) {
            $errors['prenom'] = 'Le prénom est requis';
        }

        if (empty($email)) {
            $errors['email'] = 'L\'email est requis';
        } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $errors['email'] = 'Format d\'email invalide';
        }

        if (empty($password)) {
            $errors['password'] = 'Le mot de passe est requis';
        } elseif (strlen($password) < 8) {
            $errors['password'] = 'Le mot de passe doit contenir au moins 8 caractères';
        } elseif (!preg_match('/[A-Z]/', $password)) {
            $errors['password'] = 'Le mot de passe doit contenir au moins une majuscule';
        } elseif (!preg_match('/[a-z]/', $password)) {
            $errors['password'] = 'Le mot de passe doit contenir au moins une minuscule';
        } elseif (!preg_match('/[0-9]/', $password)) {
            $errors['password'] = 'Le mot de passe doit contenir au moins un chiffre';
        } elseif (!preg_match('/[\W_]/', $password)) {
            $errors['password'] = 'Le mot de passe doit contenir au moins un caractère spécial';
        }

        if (empty($confirmPassword)) {
            $errors['confirm_password'] = 'Veuillez confirmer le mot de passe';
        } elseif ($password !== $confirmPassword) {
            $errors['confirm_password'] = 'Les mots de passe ne correspondent pas';
        }

        // Si pas d'erreurs, créer le compte
        if (empty($errors)) {
            $userModel = user();

            // Vérifier si email existe déjà
            if ($userModel->emailExists($email)) {
                $errors['email'] = 'Cet email est déjà utilisé';
            }
            else {
                // Préparer les données utilisateur
                $userData = [
                    'nom' => $nom,
                    'prenom' => $prenom,
                    'email' => $email,
                    'password' => $password,
                    'telephone' => !empty($telephone) ? $telephone : null,
                    'date_naissance' => !empty($dateNaissance) ? $dateNaissance : null,
                    'role' => 'utilisateur'
                ];

                try {
                    $userId = $userModel->create($userData);

                    if ($userId) {
                        // Récupérer l'utilisateur créé pour créer la session
                        $newUser = $userModel->getById($userId);
                        if ($newUser) {
                            $userModel->createSession($newUser);
                            setFlash('success', 'Compte créé avec succès ! Bienvenue ' . clean($prenom) . ' !');
                            redirect('index.php');
                        }
                    }

                } catch (Exception $e) {
                    $errors['general'] = 'Erreur : ' . $e->getMessage();
                    echo '<pre>' . print_r($e, true) . '</pre>';
                    exit;
                }
            }
        }

    } catch (Exception $e) {
        $errors['general'] = 'Une erreur est survenue. Veuillez réessayer.';
        logError('Erreur lors de l\'inscription', ['error' => $e->getMessage(), 'email' => $email ?? '']);
    }
}

// Configuration de la page
$pageTitle = 'Inscription - Cinéphoria';
?>

<?php include '../src/templates/header.php'; ?>

    <div class="container full-height d-flex align-items-center">
        <div class="row justify-content-center w-100">
            <div class="col-lg-6 col-md-8 col-sm-10">

                <!-- Header de la page -->
                <div class="text-center mb-4">
                    <h1 class="text-primary-cinephoria mb-2">
                        <i class="bi bi-person-plus-fill text-accent-cinephoria me-2"></i>
                        Créer un compte
                    </h1>
                    <p class="text-muted">
                        Rejoignez Cinéphoria pour réserver vos séances préférées
                    </p>
                </div>

                <!-- Formulaire d'inscription -->
                <form method="POST" class="auth-form fade-in" novalidate>

                    <!-- Message d'erreur général -->
                    <?php if (isset($errors['general'])): ?>
                        <div class="alert alert-danger" role="alert">
                            <i class="bi bi-exclamation-triangle me-2"></i>
                            <?= clean($errors['general']) ?>
                        </div>
                    <?php endif; ?>

                    <div class="row">
                        <!-- Prénom -->
                        <div class="col-md-6 mb-3">
                            <label for="prenom" class="form-label">
                                <i class="bi bi-person me-1"></i>
                                Prénom <span class="text-danger">*</span>
                            </label>
                            <input
                                type="text"
                                class="form-control <?= isset($errors['prenom']) ? 'is-invalid' : '' ?>"
                                id="prenom"
                                name="prenom"
                                value="<?= clean($formData['prenom'] ?? '') ?>"
                                placeholder="Votre prénom"
                                required
                                autofocus
                            >
                            <?php if (isset($errors['prenom'])): ?>
                                <div class="invalid-feedback">
                                    <?= clean($errors['prenom']) ?>
                                </div>
                            <?php endif; ?>
                        </div>

                        <!-- Nom -->
                        <div class="col-md-6 mb-3">
                            <label for="nom" class="form-label">
                                <i class="bi bi-person me-1"></i>
                                Nom <span class="text-danger">*</span>
                            </label>
                            <input
                                type="text"
                                class="form-control <?= isset($errors['nom']) ? 'is-invalid' : '' ?>"
                                id="nom"
                                name="nom"
                                value="<?= clean($formData['nom'] ?? '') ?>"
                                placeholder="Votre nom"
                                required
                            >
                            <?php if (isset($errors['nom'])): ?>
                                <div class="invalid-feedback">
                                    <?= clean($errors['nom']) ?>
                                </div>
                            <?php endif; ?>
                        </div>
                    </div>

                    <!-- Email -->
                    <div class="mb-3">
                        <label for="email" class="form-label">
                            <i class="bi bi-envelope me-1"></i>
                            Adresse email <span class="text-danger">*</span>
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
                        >
                        <?php if (isset($errors['email'])): ?>
                            <div class="invalid-feedback">
                                <?= clean($errors['email']) ?>
                            </div>
                        <?php endif; ?>
                    </div>

                    <div class="row">
                        <!-- Mot de passe -->
                        <div class="col-md-6 mb-3">
                            <label for="password" class="form-label">
                                <i class="bi bi-lock me-1"></i>
                                Mot de passe <span class="text-danger">*</span>
                            </label>
                            <div class="input-group">
                                <input
                                    type="password"
                                    class="form-control <?= isset($errors['password']) ? 'is-invalid' : '' ?>"
                                    id="password"
                                    name="password"
                                    placeholder="Votre mot de passe"
                                    required
                                    autocomplete="new-password"
                                >
                                <button
                                    class="btn btn-outline-secondary"
                                    type="button"
                                    id="togglePassword"
                                    title="Afficher/masquer le mot de passe"
                                >
                                    <i class="bi bi-eye" id="eyeIcon"></i>
                                </button>
                            </div>
                            <?php if (isset($errors['password'])): ?>
                                <div class="invalid-feedback d-block">
                                    <?= clean($errors['password']) ?>
                                </div>
                            <?php endif; ?>
                            <div class="form-text">
                                Au moins 8 caractères avec majuscule, minuscule, chiffre et caractère spécial
                            </div>
                        </div>

                        <!-- Confirmation mot de passe -->
                        <div class="col-md-6 mb-3">
                            <label for="confirm_password" class="form-label">
                                <i class="bi bi-lock-fill me-1"></i>
                                Confirmer le mot de passe <span class="text-danger">*</span>
                            </label>
                            <input
                                type="password"
                                class="form-control <?= isset($errors['confirm_password']) ? 'is-invalid' : '' ?>"
                                id="confirm_password"
                                name="confirm_password"
                                placeholder="Répétez le mot de passe"
                                required
                                autocomplete="new-password"
                            >
                            <?php if (isset($errors['confirm_password'])): ?>
                                <div class="invalid-feedback">
                                    <?= clean($errors['confirm_password']) ?>
                                </div>
                            <?php endif; ?>
                        </div>
                    </div>

                    <!-- Informations optionnelles -->
                    <div class="row">
                        <!-- Téléphone -->
                        <div class="col-md-6 mb-3">
                            <label for="telephone" class="form-label">
                                <i class="bi bi-telephone me-1"></i>
                                Téléphone <small class="text-muted">(optionnel)</small>
                            </label>
                            <input
                                type="tel"
                                class="form-control"
                                id="telephone"
                                name="telephone"
                                value="<?= clean($formData['telephone'] ?? '') ?>"
                                placeholder="06 12 34 56 78"
                            >
                        </div>

                        <!-- Date de naissance -->
                        <div class="col-md-6 mb-3">
                            <label for="date_naissance" class="form-label">
                                <i class="bi bi-calendar me-1"></i>
                                Date de naissance <small class="text-muted">(optionnel)</small>
                            </label>
                            <input
                                type="date"
                                class="form-control"
                                id="date_naissance"
                                name="date_naissance"
                                value="<?= clean($formData['date_naissance'] ?? '') ?>"
                                max="<?= date('Y-m-d', strtotime('-13 years')) ?>"
                            >
                        </div>
                    </div>

                    <!-- Bouton d'inscription -->
                    <div class="d-grid mb-4">
                        <button type="submit" class="btn btn-accent-cinephoria btn-lg">
                            <i class="bi bi-person-plus me-2"></i>
                            Créer mon compte
                        </button>
                    </div>

                    <!-- Lien vers connexion -->
                    <div class="text-center">
                        <p class="mb-0">
                            Déjà un compte ?
                            <a href="login.php" class="text-accent-cinephoria fw-bold text-decoration-none">
                                Connectez-vous ici
                            </a>
                        </p>
                    </div>
                </form>

            </div>
        </div>
    </div>

    <script>
        // Toggle password visibility
        document.getElementById('togglePassword').addEventListener('click', function() {
            const passwordField = document.getElementById('password');
            const eyeIcon = document.getElementById('eyeIcon');

            if (passwordField.type === 'password') {
                passwordField.type = 'text';
                eyeIcon.classList.replace('bi-eye', 'bi-eye-slash');
            } else {
                passwordField.type = 'password';
                eyeIcon.classList.replace('bi-eye-slash', 'bi-eye');
            }
        });

        // Password strength indicator
        document.getElementById('password').addEventListener('input', function() {
            const password = this.value;
            const requirements = [
                { regex: /.{8,}/, text: 'Au moins 8 caractères' },
                { regex: /[A-Z]/, text: 'Une majuscule' },
                { regex: /[a-z]/, text: 'Une minuscule' },
                { regex: /[0-9]/, text: 'Un chiffre' },
                { regex: /[\W_]/, text: 'Un caractère spécial' }
            ];

        });
    </script>

<?php
include '../src/templates/footer.php';
?>