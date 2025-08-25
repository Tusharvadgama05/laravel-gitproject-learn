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

# Install dependencies (without dev packages)
RUN composer install --no-dev --optimize-autoloader

# Laravel storage + cache permissions
RUN chown -R www-data:www-data storage bootstrap/cache

# Expose Render port
EXPOSE 8080

# Apache will run automatically
CMD ["apache2-foreground"]
