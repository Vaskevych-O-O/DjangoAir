#!/bin/sh
set -e

echo "Waiting for Postgres..."

python << END
import time
import psycopg2
import os

while True:
    try:
        psycopg2.connect(
            dbname="DjangoAir",
            user="postgres",
            password="mysecretpassword",
            host=os.environ.get("POSTGRES_HOST", "db"),
            port=5432,
        )
        break
    except psycopg2.OperationalError:
        time.sleep(1)
END

echo "Postgres started"

python manage.py migrate --noinput
python manage.py collectstatic --noinput

exec "$@"