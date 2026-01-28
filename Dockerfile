# On part de l'image PHP 8.3 avec Apache
FROM php:8.3-apache

# Installation des extensions
RUN docker-php-ext-install pdo pdo_mysql

# Activation de la réécriture d'URL
RUN a2enmod rewrite

# --- CONFIGURATION DU DOSSIER PUBLIC ---
# On définit le dossier où se trouve index.php
ENV APACHE_DOCUMENT_ROOT /var/www/html/web/public

# On modifie la configuration d'Apache pour utiliser ce dossier
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# Copie des fichiers
COPY . /var/www/html/

# Permissions
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

# Port
EXPOSE 80