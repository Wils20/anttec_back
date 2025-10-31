#!/bin/sh
set -e

echo "🚀 Iniciando contenedor Laravel (Apache)..."

# Esperar a que MySQL esté disponible
echo "⏳ Esperando conexión con la base de datos..."
until php -r "try { new PDO('mysql:host=' . getenv('DB_HOST') . ';port=' . getenv('DB_PORT'), getenv('DB_USERNAME'), getenv('DB_PASSWORD')); } catch (Exception \$e) { exit(1); }"; do
  echo "   ➜ Base de datos no disponible todavía..."
  sleep 3
done
echo "✅ Base de datos conectada correctamente."

# Instalar dependencias si no existen
if [ ! -d "vendor" ]; then
  echo "📦 Instalando dependencias de Composer..."
  composer install --no-dev --optimize-autoloader
fi

# Crear .env si no existe
if [ ! -f ".env" ]; then
  echo "⚙️  Generando archivo .env..."
  cp .env.example .env
fi

php artisan key:generate --force || true

# Limpiar cachés
php artisan config:clear || true
php artisan cache:clear || true
php artisan route:clear || true
php artisan view:clear || true

# Ejecutar migraciones
if [ "$MIGRATE_FRESH" = "true" ]; then
  echo "⚠️ MIGRATE_FRESH activado: ejecutando php artisan migrate:fresh --seed --force"
  php artisan migrate:fresh --seed --force
else
  echo "🔹 Ejecutando migraciones normales..."
  php artisan migrate --force
fi

# Crear enlace de almacenamiento
php artisan storage:link || true

# Cachear nuevamente
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

echo "✅ Laravel listo. Iniciando Apache..."
exec apache2-foreground
