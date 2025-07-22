<?php
/**
 * Script de test de connexion - Étape 1.1
 */

echo "<h1>🔧 Test de connexion Cinephoria</h1>";
echo "<p>Validation des fondations techniques...</p>";

try {

    echo "<h2>📋 Étapes de validation :</h2>";
    echo "<ol>";

    // 1. Test inclusion du fichier Database
    echo "<li><strong>Inclusion Database.php...</strong><br>";
    require_once 'src/config/Database.php';
    echo "✅ Fichier Database.php trouvé et inclus<br><br></li>";

    // 2. Test création instance
    echo "<li><strong>Création instance Database...</strong><br>";
    $db = Database::getInstance();
    echo "✅ Instance Database créée (pattern Singleton)<br><br></li>";

    // 3. Test connexion basique
    echo "<li><strong>Test connexion PDO...</strong><br>";
    $isConnected = $db->testConnection();
    if ($isConnected) {
        echo "✅ Connexion PDO fonctionnelle<br>";
    } else {
        echo "❌ Problème de connexion PDO<br>";
    }
    echo "<br></li>";

    // 4. Test lecture données
    echo "<li><strong>Test lecture données...</strong><br>";

    try {
        $userCount = $db->count('utilisateurs');
        echo "👥 <strong>{$userCount}</strong> utilisateurs trouvés<br>";

        $filmCount = $db->count('films');
        echo "🎬 <strong>{$filmCount}</strong> films trouvés<br>";

        $seanceCount = $db->count('seances');
        echo "🎫 <strong>{$seanceCount}</strong> séances trouvées<br>";

    } catch (Exception $e) {
        echo "⚠️ Erreur lecture données : " . $e->getMessage() . "<br>";
        echo "<small>Vérifiez que les tables existent et contiennent des données</small><br>";
    }
    echo "<br></li>";

    // 5. Test utilisateur spécifique
    echo "<li><strong>Test utilisateur admin...</strong><br>";

    try {
        $admin = $db->getUserByEmail('admin@cinephoria.com');
        if ($admin) {
            echo "✅ Admin trouvé : <strong>" . htmlspecialchars($admin['prenom'] . ' ' . $admin['nom']) . "</strong><br>";
            echo "📧 Email : " . htmlspecialchars($admin['email']) . "<br>";
            echo "🔑 Rôle : <strong>" . htmlspecialchars($admin['role']) . "</strong><br>";
        } else {
            echo "⚠️ Admin non trouvé - vérifiez les données de test<br>";
        }
    } catch (Exception $e) {
        echo "❌ Erreur recherche admin : " . $e->getMessage() . "<br>";
    }
    echo "<br></li>";

    echo "</ol>";

    // Résumé
    echo "<div style='background: #d4edda; border: 1px solid #c3e6cb; padding: 15px; border-radius: 5px; margin: 20px 0;'>";
    echo "<h3>🎉 Résultat du test :</h3>";

    if ($isConnected && $userCount > 0) {
        echo "<p><strong style='color: #155724;'>✅ SUCCÈS !</strong> La connexion à la base de données fonctionne parfaitement.</p>";
        echo "<p><strong>Prochaine étape :</strong> Créer la classe User et tester l'authentification.</p>";
    } else {
        echo "<p><strong style='color: #721c24;'>❌ PROBLÈME</strong> détecté. Vérifiez la configuration.</p>";
    }
    echo "</div>";

} catch (Exception $e) {

    echo "</ol>"; // Fermer la liste si erreur

    echo "<div style='background: #f8d7da; border: 1px solid #f5c6cb; padding: 15px; border-radius: 5px; margin: 20px 0;'>";
    echo "<h3>❌ Erreur détectée :</h3>";
    echo "<p><strong>Message :</strong> " . htmlspecialchars($e->getMessage()) . "</p>";

    echo "<h4>🔧 Actions de débogage :</h4>";
    echo "<ul>";
    echo "<li>Vérifiez que <strong>XAMPP</strong> est démarré (Apache + MySQL)</li>";
    echo "<li>Vérifiez que le fichier <strong>.env</strong> existe dans <code>web/config/.env</code></li>";
    echo "<li>Vérifiez que la base <strong>cinephoria</strong> existe dans phpMyAdmin</li>";
    echo "<li>Vérifiez que les <strong>tables ont été importées</strong> (01_creation_bdd.sql + 02_donnees_test.sql)</li>";
    echo "<li>Vérifiez les <strong>paramètres de connexion</strong> dans le fichier .env</li>";
    echo "</ul>";
    echo "</div>";
}

echo "<hr>";
echo "<p><small>Script de test - Étape 1.1 - " . date('Y-m-d H:i:s') . "</small></p>";

?>
