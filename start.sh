#!/bin/bash
# Script de démarrage pour DevOps Config Manager

echo "🚀 Démarrage de DevOps Config Manager"
echo ""

# Vérifier Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 n'est pas installé"
    exit 1
fi

# Vérifier Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js n'est pas installé"
    exit 1
fi

# Activer l'environnement virtuel si il existe
if [ -d "venv" ]; then
    echo "✓ Activation de l'environnement virtuel Python"
    source venv/bin/activate
fi

# Vérifier les dépendances Python
echo "✓ Vérification des dépendances Python..."
python3 -c "import flask, lxml" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "⚠ Installation des dépendances Python..."
    pip install -r requirements.txt
fi

# Démarrer le backend en arrière-plan
echo "✓ Démarrage du backend Flask..."
python3 app.py &
BACKEND_PID=$!
echo "  Backend démarré (PID: $BACKEND_PID)"

# Attendre que le backend soit prêt
sleep 3

# Vérifier que le backend fonctionne
curl -s http://localhost:5000/api/health > /dev/null
if [ $? -eq 0 ]; then
    echo "✓ Backend opérationnel"
else
    echo "⚠ Le backend peut prendre quelques secondes pour démarrer"
fi

# Démarrer le frontend
echo ""
echo "✓ Démarrage du frontend React..."
cd frontend

# Vérifier node_modules
if [ ! -d "node_modules" ]; then
    echo "⚠ Installation des dépendances Node.js..."
    npm install
fi

echo ""
echo "✅ Application démarrée!"
echo ""
echo "📝 Frontend: http://localhost:3000"
echo "🔧 Backend API: http://localhost:5000"
echo ""
echo "Pour arrêter l'application, utilisez Ctrl+C ou tuez les processus:"
echo "  kill $BACKEND_PID"

# Démarrer le frontend (bloquant)
npm start
