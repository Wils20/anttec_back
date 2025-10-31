# Etapa 1: Instalar dependencias de Composer
FROM composer:2 AS vendor

# Instalar extensiones necesarias también aquí
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-install pdo_mysql mbstring bcmath gd

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Etapa 2: Imagen base PHP con Apache
FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

RUN a2enmod rewrite

WORKDIR /var/www/html
COPY . .
COPY --from=vendor /app/vendor /var/www/html/vendor

RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Configurar Apache para Laravel
RUN echo '<Directory /var/www/html/public>\n\
    AllowOverride All\n\
</Directory>' > /etc/apache2/conf-available/laravel.conf \
    && a2enconf laravel

EXPOSE 80
CMD ["apache2-foreground"]
