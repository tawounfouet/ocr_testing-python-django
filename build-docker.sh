#!/bin/bash

# Script de build Docker pour le projet Django Testing
# Teste différentes approches pour éviter les problèmes de compilation

echo "🚀 Build Docker pour Django Testing"
echo "=================================="

# Option 1 : Build optimisé (recommandé)
echo "📦 Option 1 : Build avec Dockerfile optimisé..."
if docker build -f Dockerfile.optimized -t django-testing:optimized . ; then
    echo "✅ Build optimisé réussi!"
    echo "💡 Pour lancer : docker run -p 8000:8000 django-testing:optimized"
else
    echo "❌ Build optimisé échoué, tentative avec Dockerfile standard..."
    
    # Option 2 : Build standard avec toutes les dépendances
    echo "📦 Option 2 : Build avec Dockerfile standard..."
    if docker build -t django-testing:standard . ; then
        echo "✅ Build standard réussi!"
        echo "💡 Pour lancer : docker run -p 8000:8000 django-testing:standard"
    else
        echo "❌ Build standard échoué"
        echo "💡 Vérifiez les logs d'erreur ci-dessus"
        exit 1
    fi
fi

echo ""
echo "🎯 Images Docker créées :"
docker images | grep django-testing

echo ""
echo "🏃‍♂️ Pour démarrer l'application :"
echo "   docker run -p 8000:8000 django-testing:optimized"
echo ""
echo "🐳 Ou avec Docker Compose :"
echo "   docker-compose up --build"

echo ""
echo "🌐 L'application sera accessible sur http://localhost:8000"
