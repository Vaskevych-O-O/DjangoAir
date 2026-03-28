#!/bin/sh
set -e

echo "Running migrations and collecting static files..."

# Міграції та збірка статичних файлів
python manage.py migrate --noinput
python manage.py collectstatic --noinput

# Запуск Celery, якщо увімкнено
if [ "${USE_CELERY}" = "True" ]; then
    echo "Starting Celery worker and beat..."
    celery -A air worker --loglevel=info --pool=solo &
    celery -A air beat --loglevel=info &
fi

# Запускаємо сервер Daphne, якщо команда не передана
if [ "$#" -eq 0 ]; then
    echo "No command provided, starting Daphne server..."
    daphne -b 0.0.0.0 -p 8000 DjangoAir.asgi:application
else
    exec "$@"
fi