FROM php:8.2-apache

# Instalar dependencias del sistema y extensiones PHP necesarias para Laravel
RUN apt-get update && apt-get install -y \
    git unzip libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libzip-dev zip curl && \
    docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiar el código del proyecto
COPY . /var/www/html

WORKDIR /var/www/html

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Exponer el puerto 10000 (Render usa este)
EXPOSE 10000

# Comando por defecto
CMD php artisan serve --host 0.0.0.0 --port 10000
