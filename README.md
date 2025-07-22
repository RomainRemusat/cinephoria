# Cinéphoria

**TP Concepteur Développeur d’Applications - CDA 2025/2026**  
Cinéphoria est une suite d'applications (web, mobile, bureautique) destinée à la gestion d'une chaîne de cinémas engagés pour l'écologie. Ce projet a été réalisé dans le cadre du TP de la formation **Concepteur Développeur d'Applications**.

---

## Sommaire
- [Objectif du projet](#-objectif-du-projet)
- [Structure du dépôt](#-structure-du-dépôt)
- [Technologies utilisées](#-technologies-utilisées)
- [Installation locale](#-installation-locale)
- [Comptes de test](#-comptes-de-test)
- [Gestion de projet (Git & Trello)](#-gestion-de-projet-git--trello)
- [Sécurité & Bonnes pratiques](#-sécurité--bonnes-pratiques)
- [Documentation livrée](#-documentation-livrée)
- [Déploiement en ligne](#-déploiement-en-ligne)

---

## Objectif du projet
- Proposer une plateforme de réservation en ligne pour les cinémas Cinéphoria.
- Gérer les séances, les réservations, les avis utilisateurs.
- Fournir une application mobile pour visualiser ses billets et QR code.
- Permettre aux employés de déclarer des incidents techniques via une application bureautique.

---

## Structure du dépôt
```
cinephoria/
├── public/               # Application web (interface)
├── api/                  # Application web (backend PHP)
├── mobile/               # Application mobile (Flutter ou responsive)
├── bureautique/          # Application bureautique (Python + Tkinter)
├── sql/                  # Scripts SQL (création, fixtures, transaction)
├── docs/                 # Documentation PDF et charte graphique
├── .gitignore
├── README.md
└── .env.example
```

---

## Technologies utilisées

### Web
- HTML5, CSS3 (Bootstrap), JavaScript
- PHP 8.3 avec PDO
- MySQL
- MongoDB (statistiques réservations)
- Déploiement : Fly.io

### Mobile
- Flutter (cross-platform) ou fallback responsive

### Bureautique
- Python 3 + Tkinter

---

## Installation locale

### 1. Cloner le projet
```bash
git clone https://github.com/RomainRemusat/cinephoria.git
cd cinephoria
```

### 2. Configurer les variables d'environnement
```bash
cp .env.example .env
```
Modifier les infos de connexion à la base de données si besoin.

### 3. Importer la base de données
Dans phpMyAdmin ou via terminal :
```sql
source sql/01_creation_bdd.sql;
source sql/02_donnees_test.sql;
source sql/03_transaction_reservation.sql;
```

### 4. Lancer le serveur PHP local
```bash
cd web/public
php -S localhost:8000
```
Application disponible sur [http://localhost:8000](http://localhost:8000)

---

## Comptes de test

| Rôle        | Email                       | Mot de passe   |
|-------------|-----------------------------|----------------|
| Admin       | admin@cinephoria.com        | Admin123!      |
| Employé     | employe1@cinephoria.com     | Employe123!    |
| Utilisateur | julie.leblanc@gmail.com     | Client123!     |

---

## Gestion de projet (Git & Trello)
- Branche principale : `main`
- Branche de développement : `develop`
- Fonctionnalités : `feature/xxx` → testées → merge dans `develop` → puis `main`

Trello : [Tableau Trello Cinephoria](https://trello.com/b/dLrilC0o/cinephoria-tp-cda)

---

## Sécurité & Bonnes pratiques
- `password_hash()` pour les mots de passe
- Requêtes PDO préparées contre l'injection SQL
- `htmlspecialchars()` pour se protéger des XSS
- Gestion des rôles avec contrôles backend (`admin`, `employe`, `utilisateur`)
- Sessions sécurisées

---

## Documentation livrée
- `/docs/charte_graphique.pdf`
- `/docs/manuel_utilisateur.pdf`
- `/docs/documentation_technique.pdf`
- `/docs/documentation_projet.pdf`

---

## Déploiement en ligne
Lien Fly.io (en cours de mise en place) :  
# Cinéphoria

**TP Concepteur Développeur d’Applications - CDA 2025/2026**  
Cinéphoria est une suite d'applications (web, mobile, bureautique) destinée à la gestion d'une chaîne de cinémas engagés pour l'écologie. Ce projet a été réalisé dans le cadre du TP de la formation **Concepteur Développeur d'Applications**.

---

## Sommaire
- [Objectif du projet](#-objectif-du-projet)
- [Structure du dépôt](#-structure-du-dépôt)
- [Technologies utilisées](#-technologies-utilisées)
- [Installation locale](#-installation-locale)
- [Comptes de test](#-comptes-de-test)
- [Gestion de projet (Git & Trello)](#-gestion-de-projet-git--trello)
- [Sécurité & Bonnes pratiques](#-sécurité--bonnes-pratiques)
- [Documentation livrée](#-documentation-livrée)
- [Déploiement en ligne](#-déploiement-en-ligne)

---

## Objectif du projet
- Proposer une plateforme de réservation en ligne pour les cinémas Cinéphoria.
- Gérer les séances, les réservations, les avis utilisateurs.
- Fournir une application mobile pour visualiser ses billets et QR code.
- Permettre aux employés de déclarer des incidents techniques via une application bureautique.

---

## Structure du dépôt
```
cinephoria/
├── public/               # Application web (interface)
├── api/                  # Application web (backend PHP)
├── mobile/               # Application mobile (Flutter ou responsive)
├── bureautique/          # Application bureautique (Python + Tkinter)
├── sql/                  # Scripts SQL (création, fixtures, transaction)
├── docs/                 # Documentation PDF et charte graphique
├── .gitignore
├── README.md
└── .env.example
```

---

## Technologies utilisées

### Web
- HTML5, CSS3 (Bootstrap), JavaScript
- PHP 8.3 avec PDO
- MySQL
- MongoDB (statistiques réservations)
- Déploiement : Fly.io

### Mobile
- Flutter (cross-platform) ou fallback responsive

### Bureautique
- Python 3 + Tkinter

---

## Installation locale

### 1. Cloner le projet
```bash
git clone https://github.com/RomainRemusat/cinephoria.git
cd cinephoria
```

### 2. Configurer les variables d'environnement
```bash
cp .env.example .env
```
Modifier les infos de connexion à la base de données si besoin.

### 3. Importer la base de données
Dans phpMyAdmin ou via terminal :
```sql
source sql/01_creation_bdd.sql;
source sql/02_donnees_test.sql;
source sql/03_transaction_reservation.sql;
```

### 4. Lancer le serveur PHP local
```bash
cd web/public
php -S localhost:8000
```
Application disponible sur [http://localhost:8000](http://localhost:8000)

---

## Comptes de test

| Rôle        | Email                       | Mot de passe   |
|-------------|-----------------------------|----------------|
| Admin       | admin@cinephoria.com        | Admin123!      |
| Employé     | employe1@cinephoria.com     | Employe123!    |
| Utilisateur | julie.leblanc@gmail.com     | Client123!     |

---

## Gestion de projet (Git & Trello)
- Branche principale : `main`
- Branche de développement : `develop`
- Fonctionnalités : `feature/xxx` → testées → merge dans `develop` → puis `main`

Trello : [Tableau Trello Cinephoria](https://trello.com/b/dLrilC0o/cinephoria-tp-cda)

---

## Sécurité & Bonnes pratiques
- `password_hash()` pour les mots de passe
- Requêtes PDO préparées contre l'injection SQL
- `htmlspecialchars()` pour se protéger des XSS
- Gestion des rôles avec contrôles backend (`admin`, `employe`, `utilisateur`)
- Sessions sécurisées

---

## Documentation livrée
- `/docs/charte_graphique.pdf`
- `/docs/manuel_utilisateur.pdf`
- `/docs/documentation_technique.pdf`
- `/docs/documentation_projet.pdf`

---

## Déploiement en ligne
**Application déployée sur Fly.io :**  
**[https://cinephoria-late-fog-2777.fly.dev](https://cinephoria-late-fog-2777.fly.dev)**

### API REST
**Base URL :** `https://cinephoria-late-fog-2777.fly.dev/api`

### Environnements
- **Production :** Fly.io (URL ci-dessus)
- **Développement :** Installation locale (voir instructions)
- **Repository :** [GitHub - RomainRemusat/cinephoria](https://github.com/RomainRemusat/cinephoria)

### Déploiement automatique
```bash
# Commandes pour redéploiement
flyctl deploy

---

© Projet Cinéphoria - CDA 2025-2026
