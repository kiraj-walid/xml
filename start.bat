@echo off
REM Script de démarrage pour DevOps Config Manager (Windows)

echo 🚀 Démarrage de DevOps Config Manager
echo.

REM Vérifier Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python n'est pas installé
    exit /b 1
)

REM Vérifier Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js n'est pas installé
    exit /b 1
)

REM Activer l'environnement virtuel si il existe
if exist venv\Scripts\activate.bat (
    echo ✓ Activation de l'environnement virtuel Python
    call venv\Scripts\activate.bat
)

REM Vérifier les dépendances Python
echo ✓ Vérification des dépendances Python...
python -c "import flask, lxml" >nul 2>&1
if errorlevel 1 (
    echo ⚠ Installation des dépendances Python...
    pip install -r requirements.txt
)

REM Démarrer le backend en arrière-plan
echo ✓ Démarrage du backend Flask...
start "Backend Flask" python app.py

REM Attendre que le backend soit prêt
timeout /t 3 /nobreak >nul

REM Démarrer le frontend
echo.
echo ✓ Démarrage du frontend React...
cd frontend

REM Vérifier node_modules
if not exist node_modules (
    echo ⚠ Installation des dépendances Node.js...
    call npm install
)

echo.
echo ✅ Application démarrée!
echo.
echo 📝 Frontend: http://localhost:3000
echo 🔧 Backend API: http://localhost:5000
echo.
echo Pour arrêter l'application, fermez les fenêtres ou utilisez Ctrl+C

REM Démarrer le frontend
call npm start
