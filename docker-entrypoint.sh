#!/bin/bash

# Script d'entrée pour Docker
set -e

echo "Attente de la base de données..."
python << END
import sys
import time
import psycopg2
from psycopg2 import OperationalError

suggest_unrecoverable_after = 30
start = time.time()

while True:
    try:
        psycopg2.connect(
            dbname="${POSTGRES_DB:-django_test}",
            user="${POSTGRES_USER:-django}",
            password="${POSTGRES_PASSWORD:-django123}",
            host="${POSTGRES_HOST:-db}",
            port="${POSTGRES_PORT:-5432}",
        )
        break
    except OperationalError as error:
        sys.stderr.write("Waiting for PostgreSQL to become available...\n")
        
        if time.time() - start > suggest_unrecoverable_after:
            sys.stderr.write("  This is taking longer than expected. The following exception may be indicative of an unrecoverable error: '{}'\n".format(error))
    
    time.sleep(1)
END

echo "Base de données disponible!"

# Exécuter les migrations
echo "Application des migrations..."
python manage.py migrate

# Créer un superutilisateur si nécessaire
echo "Création du superutilisateur..."
python manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print('Superutilisateur créé: admin/admin123')
else:
    print('Superutilisateur existe déjà')
END

# Collecter les fichiers statiques
echo "Collecte des fichiers statiques..."
python manage.py collectstatic --noinput

# Exécuter la commande passée en paramètre
exec "$@"
