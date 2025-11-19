# Docker Setup pour le projet Django Testing

Ce guide explique comment utiliser Docker avec ce projet Django.

## Fichiers Docker créés

- `Dockerfile` : Configuration Docker pour le développement
- `Dockerfile.production` : Configuration optimisée pour la production
- `docker-compose.yml` : Orchestration des services (Django + PostgreSQL)
- `.dockerignore` : Fichiers à ignorer lors du build
- `docker-entrypoint.sh` : Script d'initialisation

## Utilisation

### Développement avec Docker Compose

1. **Build et démarrage des services :**
```bash
docker-compose up --build
```

2. **Démarrage en arrière-plan :**
```bash
docker-compose up -d
```

3. **Voir les logs :**
```bash
docker-compose logs -f
```

4. **Arrêter les services :**
```bash
docker-compose down
```

### Build Manuel

#### Pour le développement :
```bash
# Build de l'image
docker build -t django-testing .

# Run du conteneur
docker run -p 8000:8000 django-testing
```

#### Pour la production :
```bash
# Build de l'image de production
docker build -f Dockerfile.production -t django-testing:prod .

# Run du conteneur de production
docker run -p 8000:8000 django-testing:prod
```

### Commandes utiles

#### Exécuter des commandes Django dans le conteneur :
```bash
# Migrations
docker-compose exec web python manage.py migrate

# Créer un superutilisateur
docker-compose exec web python manage.py createsuperuser

# Shell Django
docker-compose exec web python manage.py shell

# Tests
docker-compose exec web python manage.py test
```

#### Gestion des volumes :
```bash
# Nettoyer les volumes
docker-compose down -v

# Rebuild complet
docker-compose down -v --rmi all
docker-compose up --build
```

## Configuration

### Variables d'environnement

Vous pouvez créer un fichier `.env` pour personnaliser la configuration :

```env
# Base de données
POSTGRES_DB=django_test
POSTGRES_USER=django
POSTGRES_PASSWORD=django123
POSTGRES_HOST=db
POSTGRES_PORT=5432

# Django
DEBUG=False
SECRET_KEY=votre-clé-secrète-ici
ALLOWED_HOSTS=localhost,127.0.0.1
```

### Ports

- **Django** : http://localhost:8000
- **PostgreSQL** : localhost:5432

### Volumes

- `postgres_data` : Données persistantes de PostgreSQL
- `static_volume` : Fichiers statiques Django
- `media_volume` : Fichiers média uploadés

## Production

Pour la production, utilisez `Dockerfile.production` qui inclut :
- Multi-stage build pour optimiser la taille
- Gunicorn comme serveur WSGI
- Configuration de sécurité renforcée
- Utilisateur non-root

```bash
docker build -f Dockerfile.production -t django-testing:prod .
docker run -p 8000:8000 \
  -e DEBUG=False \
  -e SECRET_KEY=votre-clé-secrète \
  django-testing:prod
```

## Troubleshooting

### Base de données non accessible
```bash
docker-compose logs db
docker-compose exec db psql -U django -d django_test
```

### Problèmes de permissions
```bash
docker-compose exec web chown -R django:django /app
```

### Rebuild complet
```bash
docker-compose down -v --rmi all
docker-compose build --no-cache
docker-compose up
```
