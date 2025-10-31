#!/bin/bash
set -e

# -----------------------
# Esperar a que la base de datos esté lista
# -----------------------
DB_HOST=${DB_HOST:-127.0.0.1}
DB_PORT=${DB_PORT:-3306}

echo "⏳ Esperando a que la base de datos en $DB_HOST:$DB_PORT esté disponible..."

until nc -z $DB_HOST $DB_PORT; do
  sleep 1
done

echo "✅ Base de datos lista"

# -----------------------
# Ejecutar migraciones y caches de Laravel
# -----------------------
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

# -----------------------
# Ejecutar Apache en foreground
# -----------------------
exec apache2-foreground
