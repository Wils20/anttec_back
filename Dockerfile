# ============================
# Etapa 1: Build (instalar dependencias)
# ============================
FROM php:8.2-cli AS build

# Instalar dependencias del sistema y extensiones de PHP
RUN apt-get update && apt-get install -y \
    git unzip zip libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd \
    && rm -rf /var/lib/apt/lists/*

# Copiar Composer desde imagen oficial
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

# Instalar dependencias PHP sin paquetes dev
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

# Generar key y crear storage link para build
RUN php artisan key:generate --force \
    && php artisan storage:link || true

# ============================
# Etapa 2: Runtime (Apache)
# ============================
FROM php:8.2-apache

# Instalar dependencias necesarias para runtime
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev netcat-traditional \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Definir el DocumentRoot a la carpeta public
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

# Copiar el proyecto desde la etapa build
COPY --from=build /app /var/www/html

# Permisos correctos para Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Configurar Apache para permitir .htaccess y usar public/
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' \
       /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN echo '<Directory /var/www/html/public>\n    AllowOverride All\n</Directory>' > /etc/apache2/conf-available/laravel.conf \
    && a2enconf laravel

# Copiar entrypoint y darle permisos
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
