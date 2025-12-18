FROM php:8.4-apache

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql

# Enable Apache mod_rewrite for .htaccess
RUN a2enmod rewrite

# Copy custom Apache virtual host config
COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf

# Copy application files
COPY . /var/www/html/

# Remove root .htaccess (not needed in Docker - document root is already public/)
RUN rm -f /var/www/html/.htaccess

# Copy Docker env config to env.php (auto-setup for students)
RUN cp /var/www/html/config/env.docker.php /var/www/html/config/env.php

# Create logs directory with proper permissions
RUN mkdir -p /var/www/html/var/logs && chmod -R 777 /var/www/html/var/logs

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
