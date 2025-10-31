# Etapa 1: Instalar dependencias de Composer
FROM composer:2 AS vendor

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Etapa 2: Imagen base PHP con Apache
FROM php:8.2-apache

# Instalar extensiones necesarias para Laravel
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Habilitar mod_rewrite para Laravel
RUN a2enmod rewrite

# Copiar archivos de la app
WORKDIR /var/www/html
COPY . .

# Copiar dependencias desde la etapa anterior
COPY --from=vendor /app/vendor /var/www/html/vendor

# Permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Configurar Apache
RUN echo '<Directory /var/www/html/public>\n\
    AllowOverride All\n\
</Directory>' > /etc/apache2/conf-available/laravel.conf \
    && a2enconf laravel

# Exponer el puerto 80
EXPOSE 80

# Comando para iniciar Laravel
CMD ["apache2-foreground"]
