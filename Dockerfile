# On utilise PHP 8.3 avec Apache
FROM php:8.3-apache

# Installation des extensions pour MySQL (PDO)
RUN docker-php-ext-install pdo pdo_mysql

# Activation de la réécriture d'URL (important pour le routing)
RUN a2enmod rewrite

# Copie de ton code vers le serveur
COPY . /var/www/html/

# Ajustement des permissions
RUN chown -R www-data:www-data /var/www/html