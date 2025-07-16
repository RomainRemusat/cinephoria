TP Concepteur développeur d’applications -Novembre-Décembre2025/Janvier-Février-Mars-Avril2026 
# Cinéphoria
Cinéphoria est une suite d'applications (web, mobile, bureautique) destinée à la gestion d'une chaîne de cinémas engagés pour l'écologie. Ce projet a été réalisé dans le cadre du TP de la formation **Concepteur Développeur d'Applications**.

## Objectif du projet
- Proposer une plateforme de réservation en ligne pour les cinémas Cinéphoria.
- Gérer les séances, les réservations, les avis utilisateurs.
- Fournir une application mobile pour visualiser ses billets et QR code.
- Permettre aux employés de déclarer des incidents techniques via une application bureautique.

## Structure du dépôt
```
cinephoria/
├── web/                  # Application web (PHP)
├── mobile/               # Application mobile (Flutter ou responsive)
├── bureautique/          # Application bureautique (Python + Tkinter)
├── sql/                  # Scripts SQL (création, fixtures, transaction)
├── docs/                 # Documentation PDF et charte graphique
├── .gitignore
├── README.md             # Ce fichier
└── .env.example
```

## Technologies utilisées
### Web
- Front : HTML5, CSS3 (Bootstrap), JavaScript
- Back : PHP 8.3 + PDO
- BDD relationnelle : MySQL
- BDD NoSQL : MongoDB (statistiques réservations)
- Déploiement : Fly.io

### Mobile
- Flutter (ou web responsive en fallback)

### Bureautique
- Python 3 + Tkinter

## Installation locale
### 1. Cloner le projet
```bash
git clone https://github.com/RomainRemusat/cinephoria.git
cd cinephoria
```

### 2. Configuration des variables d'environnement
Copier le fichier `.env.example` et le renommer en `.env`, puis modifier les infos de connexion à la BDD.

### 3. Importer la base de données
Dans `phpMyAdmin` ou via terminal :
```sql
source sql/01_creation_bdd.sql;
source sql/02_donnees_test.sql;
source sql/03_transaction_reservation.sql
```

### 4. Lancer le serveur PHP local
```bash
cd web/public
php -S localhost:8000
```

L'application web sera accessible sur [http://localhost:8000](http://localhost:8000).

## Gestion de projet (Git & Trello)
- Branche principale : `main`
- Branche de développement : `develop`
- Chaque fonctionnalité : `feature/nom` → merge dans `develop` → test → merge vers `main`

Un tableau Trello est utilisé pour le suivi des User Stories : [Lien Trello à venir]

## Sécurité & Bonnes pratiques
- Vérification côté serveur des entrées utilisateurs
- Hashage des mots de passe via `password_hash()`
- Filtres XSS et injection SQL avec requêtes préparées PDO
- Gestion des droits via rôles (`utilisateur`, `employe`, `admin`)

## Documentation livrée
- `/docs/charte_graphique.pdf`
- `/docs/manuel_utilisateur.pdf`
- `/docs/documentation_technique.pdf`
- `/docs/documentation_projet.pdf`

## Déploiement en ligne
Lien de démo Fly.io : à venir

---
© Projet Cinéphoria - Formation CDA 2025
