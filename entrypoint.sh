#!/bin/sh
set -e

echo "Running migrations and collecting static files..."

# Використовуємо DATABASE_URL, Render вже забезпечує доступність БД
python manage.py migrate --noinput
python manage.py collectstatic --noinput

exec "$@"