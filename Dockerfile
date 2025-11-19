# Base Python
FROM python:3.10-slim

# Variables d'environnement
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Créer un utilisateur non-root
RUN useradd --create-home --shell /bin/bash django

# Répertoire de travail
WORKDIR /app

# Installer dépendances système
RUN apt-get update && apt-get install -y \
    build-essential \
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

# Copier requirements et installer
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code
COPY . .

# Créer dossiers static et media
RUN mkdir -p static media
RUN chown -R django:django /app

# Passer à l’utilisateur non-root
USER django

# Collecter les fichiers statiques
RUN python manage.py collectstatic --noinput

# Exposer le port 8000
EXPOSE 8000

# Variable d'environnement Django
ENV DJANGO_SETTINGS_MODULE=Project.settings

# Utiliser Gunicorn pour prod
CMD ["gunicorn", "Project.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3"]
