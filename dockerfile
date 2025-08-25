# Use official PHP image with Apache
FROM php:8.2-apache

# Install required system packages and PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev unzip git \
    && docker-php-ext-install pdo pdo_mysql zip

# Enable Apache mod_rewrite (needed for Laravel routes)
RUN a2enmod rewrite

# Copy Composer from official image
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy app code
COPY . .

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Laravel storage + cache permissions
RUN chown -R www-data:www-data storage bootstrap/cache

# Set Apache to serve Laravel from /public
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf \
    && sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/apache2.conf

# Expose Render port
EXPOSE 8080

CMD ["apache2-foreground"]
