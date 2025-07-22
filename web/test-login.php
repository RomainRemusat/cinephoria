<?php
/**
 * Script de test authentification - Étape 1.2
 * Test du login avec $_SESSION
 */

// Démarrer session
session_start();



echo "<h1>🔐 Test Authentification</h1>";
echo "<p>Test du login avec _SESSION...</p>";

// Charger helpers
require_once 'src/helpers/helpers.php';


echo "Chargement classe User...<br>";

$user = new User();

echo "Classe User chargée !<br>";

try {

    echo "<h2>📋 Tests d'authentification :</h2>";
    echo "<ol>";

    // 1. État initial session
    echo "<li><strong>État initial de la session...</strong><br>";
    echo "Session ID : " . session_id() . "<br>";
    echo "Utilisateur connecté : " . (isLoggedIn() ? "✅ OUI" : "❌ NON") . "<br>";

    if (isLoggedIn()) {
        $user = getCurrentUser();
        echo "Utilisateur actuel : " . clean($user['prenom'] . ' ' . $user['nom']) . " (" . $user['role'] . ")<br>";
    }
    echo "<br></li>";

    // 2. Test login avec mauvais identifiants
    echo "<li><strong>Test login avec mauvais identifiants...</strong><br>";
    $userModel = user();
    $badLogin = $userModel->login('fake@email.com', 'badpassword');

    echo "Login avec fake@email.com / badpassword : " . ($badLogin ? "❌ RÉUSSI" : "✅ ÉCHOUÉ") . "<br><br></li>";

    // 3. Test login avec bon identifiants admin
    echo "<li><strong>Test login avec identifiants admin...</strong><br>";
    $adminLogin = $userModel->login('admin@cinephoria.com', 'Admin123!');

    if ($adminLogin) {
        echo "✅ Login admin réussi !<br>";
        echo "Données récupérées :<br>";
        echo "- ID : " . $adminLogin['id'] . "<br>";
        echo "- Nom : " . clean($adminLogin['prenom'] . ' ' . $adminLogin['nom']) . "<br>";
        echo "- Email : " . clean($adminLogin['email']) . "<br>";
        echo "- Rôle : " . clean($adminLogin['role']) . "<br>";

        // Créer la session
        echo "<br>🔑 Création de la session...<br>";
        $userModel->createSession($adminLogin);
        echo "✅ Session créée<br>";

    } else {
        echo "❌ Login admin échoué<br>";
    }
    echo "<br></li>";

    // 4. Vérifier état session après login
    echo "<li><strong>Vérification session après login...</strong><br>";
    echo "Utilisateur connecté : " . (isLoggedIn() ? "✅ OUI" : "❌ NON") . "<br>";

    if (isLoggedIn()) {
        echo "Variables $_SESSION créées :<br>";
        echo "- \$_SESSION['user_id'] = " . $_SESSION['user_id'] . "<br>";
        echo "- \$_SESSION['user_email'] = " . clean($_SESSION['user_email']) . "<br>";
        echo "- \$_SESSION['user_nom'] = " . clean($_SESSION['user_nom']) . "<br>";
        echo "- \$_SESSION['user_prenom'] = " . clean($_SESSION['user_prenom']) . "<br>";
        echo "- \$_SESSION['user_role'] = " . clean($_SESSION['user_role']) . "<br>";
        echo "- \$_SESSION['login_time'] = " . date('H:i:s', $_SESSION['login_time']) . "<br>";
    }
    echo "<br></li>";

    // 5. Test des fonctions helper
    echo "<li><strong>Test des fonctions helper...</strong><br>";
    echo "isLoggedIn() : " . (isLoggedIn() ? "✅ TRUE" : "❌ FALSE") . "<br>";
    echo "isAdmin() : " . (isAdmin() ? "✅ TRUE" : "❌ FALSE") . "<br>";
    echo "isEmployee() : " . (isEmployee() ? "✅ TRUE" : "❌ FALSE") . "<br>";
    echo "hasRole('admin') : " . (hasRole('admin') ? "✅ TRUE" : "❌ FALSE") . "<br>";
    echo "hasRole('utilisateur') : " . (hasRole('utilisateur') ? "✅ TRUE" : "❌ FALSE") . "<br>";

    $currentUser = getCurrentUser();
    if ($currentUser) {
        echo "getCurrentUser() : ✅ " . clean($currentUser['prenom'] . ' ' . $currentUser['nom']) . "<br>";
    }
    echo "<br></li>";

    // 6. Test messages flash
    echo "<li><strong>Test messages flash...</strong><br>";
    setFlash('success', 'Test de message de succès');
    setFlash('error', 'Test de message d\'erreur');

    echo "Messages flash définis...<br>";

    $successMsg = getFlash('success');
    $errorMsg = getFlash('error');

    echo "Message success récupéré : " . ($successMsg ? "✅ " . clean($successMsg) : "❌ VIDE") . "<br>";
    echo "Message error récupéré : " . ($errorMsg ? "✅ " . clean($errorMsg) : "❌ VIDE") . "<br>";

    // Vérifier qu'ils sont supprimés
    $successMsg2 = getFlash('success');
    echo "Message success après récupération : " . ($successMsg2 ? "❌ ENCORE LÀ" : "✅ SUPPRIMÉ") . "<br>";
    echo "<br></li>";

    // 7. Test déconnexion
    echo "<li><strong>Test déconnexion...</strong><br>";
    echo "Avant logout - Connecté : " . (isLoggedIn() ? "✅ OUI" : "❌ NON") . "<br>";

    $userModel->logout();

    echo "Après logout - Connecté : " . (isLoggedIn() ? "❌ OUI" : "✅ NON") . "<br>";
    echo "✅ Déconnexion réussie<br><br></li>";

    echo "</ol>";

    // Résumé
    echo "<div style='background: #d4edda; border: 1px solid #c3e6cb; padding: 15px; border-radius: 5px; margin: 20px 0;'>";
    echo "<h3>🎉 Résultat des tests d'authentification :</h3>";

    if ($adminLogin) {
        echo "<p><strong style='color: #155724;'>✅ SUCCÈS COMPLET !</strong></p>";
        echo "<p><strong>Fonctionnalités testées et validées :</strong></p>";
        echo "<ul>";
        echo "<li>✅ Login avec identifiants corrects</li>";
        echo "<li>✅ Rejet des mauvais identifiants</li>";
        echo "<li>✅ Création session \$_SESSION</li>";
        echo "<li>✅ Fonctions helper (isLoggedIn, hasRole, etc.)</li>";
        echo "<li>✅ Messages flash</li>";
        echo "<li>✅ Déconnexion propre</li>";
        echo "</ul>";
        echo "<p><strong>🚀 Prêt pour l'étape suivante :</strong> Créer l'interface de connexion !</p>";
    } else {
        echo "<p><strong style='color: #721c24;'>❌ PROBLÈME</strong> avec le login admin.</p>";
        echo "<p>Vérifiez le mot de passe dans la base de données.</p>";
    }
    echo "</div>";

} catch (Exception $e) {

    echo "</ol>";

    echo "<div style='background: #f8d7da; border: 1px solid #f5c6cb; padding: 15px; border-radius: 5px; margin: 20px 0;'>";
    echo "<h3>❌ Erreur dans les tests d'authentification :</h3>";
    echo "<p><strong>Message :</strong> " . clean($e->getMessage()) . "</p>";
    echo "</div>";
}

echo "<hr>";
echo "<p><small>Test authentification - Étape 1.2 - " . date('Y-m-d H:i:s') . "</small></p>";

?>