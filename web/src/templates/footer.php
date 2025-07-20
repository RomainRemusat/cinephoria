</main>

<!-- Footer -->
<footer class="footer-cinephoria mt-5">
    <div class="container">
        <div class="row">
            <!-- À propos -->
            <div class="col-lg-4 col-md-6 mb-4">
                <h5><i class="bi bi-film text-accent-cinephoria me-2"></i>À propos de Cinéphoria</h5>
                <p class="mb-3">
                    Cinéma moderne et responsable alliant passion du cinéma et engagement écologique.
                    <span class="text-accent-cinephoria fw-bold">20% de nos revenus</span> soutiennent
                    des initiatives écologiques.
                </p>
                <div class="d-flex gap-3">
                    <a href="#" class="text-accent-cinephoria">
                        <i class="bi bi-facebook fs-4"></i>
                    </a>
                    <a href="#" class="text-accent-cinephoria">
                        <i class="bi bi-twitter fs-4"></i>
                    </a>
                    <a href="#" class="text-accent-cinephoria">
                        <i class="bi bi-instagram fs-4"></i>
                    </a>
                    <a href="#" class="text-accent-cinephoria">
                        <i class="bi bi-youtube fs-4"></i>
                    </a>
                </div>
            </div>

            <!-- Informations pratiques -->
            <div class="col-lg-4 col-md-6 mb-4">
                <h5><i class="bi bi-info-circle text-accent-cinephoria me-2"></i>Informations pratiques</h5>
                <ul class="list-unstyled">
                    <li class="mb-2">
                        <i class="bi bi-geo-alt me-2"></i>
                        <strong>Adresse :</strong><br>
                        123 Avenue du Cinéma<br>
                        75001 Paris, France
                    </li>
                    <li class="mb-2">
                        <i class="bi bi-telephone me-2"></i>
                        <strong>Téléphone :</strong><br>
                        <a href="tel:+33123456789">01 23 45 67 89</a>
                    </li>
                    <li class="mb-2">
                        <i class="bi bi-clock me-2"></i>
                        <strong>Horaires :</strong><br>
                        Lun-Dim : 10h00 - 23h30
                    </li>
                </ul>
            </div>

            <!-- Liens utiles -->
            <div class="col-lg-4 col-md-12 mb-4">
                <h5><i class="bi bi-link-45deg text-accent-cinephoria me-2"></i>Liens utiles</h5>
                <div class="row">
                    <div class="col-6">
                        <ul class="list-unstyled">
                            <li><a href="films.php">Nos films</a></li>
                            <li><a href="reservation.php">Réserver</a></li>
                            <li><a href="tarifs.php">Tarifs</a></li>
                            <li><a href="contact.php">Contact</a></li>
                        </ul>
                    </div>
                    <div class="col-6">
                        <ul class="list-unstyled">
                            <li><a href="cgv.php">CGV</a></li>
                            <li><a href="mentions-legales.php">Mentions légales</a></li>
                            <li><a href="politique-confidentialite.php">Confidentialité</a></li>
                            <li><a href="accessibilite.php">Accessibilité</a></li>
                        </ul>
                    </div>
                </div>

                <!-- Badge éco-responsable -->
                <div class="mt-3">
                    <span class="badge-eco">
                        <i class="bi bi-leaf me-1"></i>
                        Cinéma éco-responsable
                    </span>
                </div>
            </div>
        </div>

        <!-- Séparateur -->
        <hr class="my-4 border-secondary">

        <!-- Copyright -->
        <div class="row align-items-center">
            <div class="col-md-6">
                <p class="mb-0">
                    &copy; <?= date('Y') ?> <strong class="text-accent-cinephoria">Cinéphoria</strong>.
                    Tous droits réservés.
                </p>
            </div>
            <div class="col-md-6 text-md-end">
                <p class="mb-0 small text-white">
                    <i class="bi bi-code-slash me-1"></i>
                    Développé avec ❤️ par @tatort pour l'environnement
                </p>
            </div>
        </div>
    </div>
</footer>

<!-- Bootstrap 5 JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>