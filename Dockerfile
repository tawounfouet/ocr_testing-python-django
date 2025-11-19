# Utiliser une image Python officielle comme base
FROM python:3.10-slim

# Définir les variables d'environnement
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Créer un utilisateur non-root pour la sécurité
RUN useradd --create-home --shell /bin/bash django

# Définir le répertoire de travail
WORKDIR /app

# Installer les dépendances système nécessaires (toutes en une fois pour optimiser les couches)
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    libmagic1 \
    libffi-dev \
    zlib1g-dev \
    libjpeg-dev \
    libtiff-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxcb1-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --upgrade pip

# Copier et installer les dépendances Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code de l'application
COPY . .

# Créer les répertoires nécessaires pour les fichiers statiques et media
RUN mkdir -p static media

# Changer le propriétaire des fichiers vers l'utilisateur django
RUN chown -R django:django /app

# Passer à l'utilisateur non-root
USER django

# Collecter les fichiers statiques
RUN python manage.py collectstatic --noinput

# Exposer le port 8000
EXPOSE 8000

# Définir les variables d'environnement pour Django
ENV DJANGO_SETTINGS_MODULE=Project.settings

# Script de démarrage
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
