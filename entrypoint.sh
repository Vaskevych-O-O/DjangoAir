#!/bin/sh
set -e

echo "Running migrations and collecting static files..."

# Використовуємо DATABASE_URL, Render вже забезпечує доступність БД
python manage.py migrate --noinput
python manage.py collectstatic --noinput

# Запускаємо сервер, якщо команда передана, або залишаємо контейнер живим
if [ "$#" -eq 0 ]; then
    echo "No command provided, starting Daphne server..."
    daphne -b 0.0.0.0 -p 8000 DjangoAir.asgi:application
else
    exec "$@"
fi