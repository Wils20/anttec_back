#!/bin/bash
set -e

# Esperar a que la base de datos esté lista (opcional, si usas MySQL)
until php artisan migrate:status > /dev/null 2>&1; do
    echo "Esperando a que la base de datos esté lista..."
    sleep 3
done

# Ejecutar migraciones automáticamente
php artisan migrate --force

# Ejecutar el comando original del contenedor
exec "$@"
