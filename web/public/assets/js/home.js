/**
 * Gestion de l'affichage dynamique des films par cinéma
 * @author romain@remusat.info / Cinéphoria
 */

document.addEventListener('DOMContentLoaded', () => {
    /** @type {HTMLSelectElement} Élément de sélection du cinéma */
    const cinemaSelect = document.getElementById('cinemaSelect');

    /** @type {HTMLElement} Conteneur principal de la grille de films */
    const filmsContainer = document.getElementById('filmsContainer');




    // On initialise l'écouteur d'événement seulement si l'élément existe dans le DOM
    if (cinemaSelect) {
        /**
         * Écoute le changement de sélection du cinéma pour mettre à jour la liste des films
         */
        cinemaSelect.addEventListener('change', async function() {
            const cinemaId = this.value;

            try {
                // Appel asynchrone à l'API locale
                const response = await fetch(`api/get_films_by_cinema.php?cinema_id=${cinemaId}`);

                // Vérification du statut de la réponse HTTP
                if (!response.ok) throw new Error('Problème lors de la récupération des données');

                // Conversion du flux JSON en objet JavaScript
                const films = await response.json();

                // Mise à jour de l'interface utilisateur
                updateFilmsUI(films);

            } catch (error) {
                console.error("Erreur Cinéphoria Fetch :", error);
            }
        });


        // On simule un changement dès le départ pour charger le premier cinéma de la liste
        if (cinemaSelect && cinemaSelect.value) {
            cinemaSelect.dispatchEvent(new Event('change'));
        }
    }

    /**
     * Reconstruit dynamiquement la grille des films à l'affiche
     * * @param {Array} films Liste des objets films retournée par l'API
     * @returns {void}
     */
    function updateFilmsUI(films) {
        // Sécurité : on arrête tout si le conteneur n'est pas présent
        if (!filmsContainer) return;

        // On vide le contenu actuel (films du précédent cinéma ou message vide)
        filmsContainer.innerHTML = '';

        // Gestion du cas "Aucun film trouvé"
        if (films.length === 0) {
            filmsContainer.innerHTML = `
                <div class="col-12 text-center py-5">
                    <p class="lead text-muted">Aucun film n'est actuellement programmé dans ce cinéma.</p>
                </div>`;
            return;
        }

        /**
         * Boucle de génération des cartes de films
         */
        films.forEach(film => {
            // Préparation de la pastille de note (si disponible)
            const noteHTML = film.note_moyenne > 0
                ? `<div class="film-rating">
                    <i class="bi bi-star-fill text-warning"></i> ${parseFloat(film.note_moyenne).toFixed(1)}
                   </div>`
                : '';

            // Tronquer la description pour garder un design harmonieux
            const descriptionShort = film.description
                ? film.description.substring(0, 80) + '...'
                : 'Aucune description disponible.';

            // Choix du bouton selon l'état de connexion (via le pont PHP/JS window.Cinephoria)
            const footerHTML = window.Cinephoria.isLoggedIn
                ? `<a href="reservation.php?film_id=${film.id}" class="btn btn-warning">
                    <i class="bi bi-ticket me-2"></i>Réserver
                   </a>`
                : `<a href="login.php" class="btn btn-outline-primary">
                    Se connecter pour réserver
                   </a>`;

            // Template de la carte film compatible avec Bootstrap 5
            const card = `
                <div class="col-lg-4 col-md-6">
                    <div class="card h-100 shadow-sm film-card border-0">
                        <div class="card-img-top-wrapper position-relative">
                            <img src="assets/images/affiches/${film.affiche || 'default.jpg'}"
                                 class="card-img-top"
                                 alt="${film.titre}"
                                 style="height: 250px; object-fit: cover;">
                            ${noteHTML}
                        </div>
                        <div class="card-body">
                            <h5 class="card-title fw-bold text-primary">${film.titre}</h5>
                            <span class="badge bg-secondary-subtle text-secondary mb-2">
                                ${film.categorie_nom || 'Général'}
                            </span>
                            <p class="card-text small text-muted mb-2">
                                <i class="bi bi-clock me-1"></i>${film.duree} min
                                • ${film.nb_seances || 0} séance(s)
                            </p>
                            <p class="card-text small text-dark opacity-75">${descriptionShort}</p>
                        </div>
                        <div class="card-footer bg-transparent border-0 pb-3">
                            <div class="d-grid">
                                ${footerHTML}
                            </div>
                        </div>
                    </div>
                </div>
            `;

            // Injection du HTML dans le conteneur sans recharger la page
            filmsContainer.insertAdjacentHTML('beforeend', card);
        });
    }
});