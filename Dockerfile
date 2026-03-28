# =============== СТАДІЯ 1: BUILD ===================
FROM python:3.11-slim AS build

# Системні пакети
RUN apt-get update && apt-get install -y \
    curl build-essential libpq-dev \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

WORKDIR /app

# Python залежності
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Node залежності
COPY package*.json ./
RUN npm install

# Копіюємо весь код
COPY . .

# Збірка Vue фронтенду
RUN npm run build

# =============== СТАДІЯ 2: ПРОД ===================
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DJANGO_SETTINGS_MODULE=DjangoAir.settings.prod

WORKDIR /app

# Системні залежності
RUN apt-get update && apt-get install -y libpq-dev

# Встановлюємо Python-залежності
COPY requirements.txt .
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Копіюємо зібраний код з build stage
COPY --from=build /app /app

# Додаємо entrypoint
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/app/entrypoint.sh"]