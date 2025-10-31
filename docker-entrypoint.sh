#!/bin/sh

set -e

echo "🚀 Iniciando contenedor Laravel..."

# Esperar a que MySQL esté disponible
echo "⏳ Esperando conexión con la base de datos..."
until php -r "try { new PDO('mysql:host=' . getenv('DB_HOST') . ';port=' . getenv('DB_PORT'), getenv('DB_USERNAME'), getenv('DB_PASSWORD')); } catch (Exception \$e) { exit(1); }"; do
  echo "   ➜ Base de datos no disponible todavía..."
  sleep 3
done

echo "✅ Base de datos conectada correctamente."

# Ejecutar composer (solo si no hay vendor)
if [ ! -d "vendor" ]; then
  echo "📦 Instalando dependencias de Composer..."
  composer install --no-dev --optimize-autoloader
fi

# Generar APP_KEY si no existe
if [ ! -f ".env" ]; then
  echo "⚙️  Generando archivo .env..."
  cp .env.example .env
fi

php artisan key:generate --force || true

# Limpiar caches
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Verificar variable MIGRATE_FRESH
if [ "$MIGRATE_FRESH" = "true" ]; then
  echo "⚠️ MIGRATE_FRESH activado: ejecutando php artisan migrate:fresh --seed --force"
  php artisan migrate:fresh --seed --force
else
  echo "🔹 Ejecutando migraciones normales..."
  php artisan migrate --force
fi

# Crear enlace de almacenamiento
php artisan storage:link || true

echo "✅ Todo listo. Iniciando servidor Laravel..."

# Ejecutar el servidor PHP en el puerto 8000 (Render lo redirige al 10000 interno)
exec php artisan serve --host=0.0.0.0 --port=8000
