<?php
/**
 * INDEX MINIMAL TEMPORAIRE - Cinéphoria
 * Pour éviter la redirection infinie
 */

// Démarrer la session
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Charger les dépendances
require_once '../src/helpers/helpers.php';

$pageTitle = 'Accueil - Cinéphoria';
?>

<?php include '../src/templates/header.php'; ?>

    <div class="container mt-5">
        <div class="row">
            <div class="col-12">
                <div class="text-center">
                    <h1 class="display-4 text-primary-cinephoria">
                        🎬 Bienvenue sur Cinéphoria !
                    </h1>

                    <?php if (isLoggedIn()): ?>
                        <?php $user = getCurrentUser(); ?>
                        <div class="alert alert-success">
                            <h4>Connexion réussie !</h4>
                            <p>Bonjour <strong><?= clean($user['prenom'] . ' ' . $user['nom']) ?></strong></p>
                            <p>Rôle : <span class="badge bg-primary"><?= clean($user['role']) ?></span></p>

                            <div class="mt-3">
                                <a href="logout.php" class="btn btn-danger">
                                    <i class="bi bi-box-arrow-right me-2"></i>
                                    Se déconnecter
                                </a>
                            </div>
                        </div>
                    <?php else: ?>
                        <div class="alert alert-info">
                            <p>Vous n'êtes pas connecté.</p>
                            <a href="login.php" class="btn btn-primary me-2">Se connecter</a>
                            <a href="register.php" class="btn btn-success">S'inscrire</a>
                        </div>
                    <?php endif; ?>

                    <!-- Test rapide base de données -->
                    <div class="mt-4">
                        <h3>🔧 Tests techniques :</h3>
                        <?php
                        try {
                            $db = db();
                            $stmt = $db->getPdo()->query("SELECT COUNT(*) as nb FROM utilisateurs");
                            $result = $stmt->fetch();
                            echo "<p>Base de données : <strong>{$result['nb']} utilisateurs</strong></p>";

                            $stmt = $db->getPdo()->query("SELECT COUNT(*) as nb FROM films");
                            $result = $stmt->fetch();
                            echo "<p>Films disponibles : <strong>{$result['nb']}</strong></p>";

                        } catch (Exception $e) {
                            echo "<p>Erreur BDD : " . $e->getMessage() . "</p>";
                        }
                        ?>
                    </div>
                </div>
            </div>
        </div>
    </div>

<?php include '../src/templates/footer.php'; ?>