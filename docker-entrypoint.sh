#!/bin/bash
set -e

# Variables por defecto
DB_HOST=${DB_HOST:-127.0.0.1}
DB_PORT=${DB_PORT:-3306}
MIGRATE_FRESH=${MIGRATE_FRESH:-false}   # si pones MIGRATE_FRESH=true hará migrate:fresh --seed

echo "⏳ Esperando a que la base de datos en $DB_HOST:$DB_PORT esté disponible..."

# Esperar a que el puerto MySQL responda (usa nc). Reintentos infinitos, 2s entre intentos.
until nc -z $DB_HOST $DB_PORT >/dev/null 2>&1; do
  echo "Esperando DB... ($DB_HOST:$DB_PORT)"
  sleep 2
done

echo "✅ Base de datos accesible."

# Limpiar caches (no fallará si algo salta)
php artisan config:clear || true
php artisan cache:clear || true
php artisan route:clear || true
php artisan view:clear || true

# Ejecutar migraciones
if [ "$MIGRATE_FRESH" = "true" ] || [ "$MIGRATE_FRESH" = "1" ]; then
  echo "⚠️ MIGRATE_FRESH activado: ejecutando php artisan migrate:fresh --seed --force"
  php artisan migrate:fresh --seed --force
else
  echo "Ejecutando php artisan migrate --force"
  php artisan migrate --force
fi

# Cachear para producción (no falla si ya está cacheado)
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

echo "✅ Migraciones y caches listas. Lanzando Apache..."

# Ejecutar el comando proporcionado (por ejemplo apache2-foreground)
exec "$@"
