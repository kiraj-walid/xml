# Guide d'installation

Ce guide vous explique comment installer et configurer le projet DevOps Config Manager.

## Prérequis

- **Python 3.8+** : Pour le backend Flask
- **Node.js 16+** : Pour le frontend React
- **npm** ou **yarn** : Gestionnaire de paquets Node.js
- **Git** : Pour cloner le dépôt (optionnel)

## Installation

### 1. Cloner le dépôt (si applicable)

```bash
git clone <url-du-repo>
cd xml
```

### 2. Configuration du backend

#### Créer un environnement virtuel Python

```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

#### Installer les dépendances Python

```bash
pip install -r requirements.txt
```

#### Vérifier l'installation

```bash
python -c "import flask, lxml; print('✓ Dépendances installées')"
```

### 3. Configuration du frontend

```bash
cd frontend
npm install
```

### 4. Exécuter le script de configuration (optionnel)

```bash
python setup.py
```

Ce script va :
- Créer les répertoires nécessaires
- Vérifier les dépendances
- Configurer le workflow GitHub Actions

## Démarrage

### Démarrer le backend

Dans un terminal :

```bash
# Activer l'environnement virtuel si ce n'est pas déjà fait
# Windows: venv\Scripts\activate
# Linux/Mac: source venv/bin/activate

python app.py
```

Le backend sera accessible sur `http://localhost:5000`

### Démarrer le frontend

Dans un autre terminal :

```bash
cd frontend
npm start
```

Le frontend sera accessible sur `http://localhost:3000`

## Vérification

### Tester l'API backend

```bash
# Test de santé
curl http://localhost:5000/api/health

# Devrait retourner: {"status":"ok","message":"API fonctionnelle"}
```

### Tester la validation XML

```bash
python scripts/validate-xml.py examples/sample-config.xml
```

### Générer des fichiers YAML

```bash
# Docker Compose
python scripts/generate-yaml.py examples/sample-config.xml --type docker-compose --environment dev

# Kubernetes
python scripts/generate-yaml.py examples/sample-config.xml --type kubernetes --environment prod
```

## Dépannage

### Erreur : Module non trouvé

Si vous obtenez une erreur `ModuleNotFoundError` :

```bash
pip install -r requirements.txt
```

### Erreur : Port déjà utilisé

Si le port 5000 ou 3000 est déjà utilisé :

**Backend** : Modifiez le port dans `app.py` :
```python
app.run(debug=True, port=5001)  # Changer 5000 en 5001
```

**Frontend** : Créez un fichier `.env` dans `frontend/` :
```
PORT=3001
```

### Erreur : CORS

Si vous rencontrez des erreurs CORS, assurez-vous que :
- Le backend Flask-CORS est installé
- Le frontend utilise le bon URL de l'API (vérifiez `API_BASE_URL` dans `App.js`)

### Erreur : Fichier XSD non trouvé

Vérifiez que le fichier `schemas/config.xsd` existe et que vous exécutez les scripts depuis la racine du projet.

## Structure des répertoires

```
.
├── app.py                 # Application Flask
├── requirements.txt       # Dépendances Python
├── schemas/              # Schémas XSD
├── xslt/                 # Transformations XSLT
├── examples/             # Exemples XML
├── templates/            # Templates CI/CD
├── scripts/              # Scripts utilitaires
├── frontend/             # Application React
└── docs/                 # Documentation
```

## Prochaines étapes

1. Consultez le [Guide du format XML](docs/xml-guide.md)
2. Lisez le [Guide d'intégration CI/CD](docs/cicd-integration.md)
3. Explorez les exemples dans `examples/`

## Support

Pour toute question ou problème, consultez la documentation ou ouvrez une issue sur le dépôt.
