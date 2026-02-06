# DevOps : Gestion centralisée des configurations d'environnements

Application web complète pour centraliser et gérer les configurations DevOps pour différents environnements (dev, staging, prod) via XML, avec transformation automatique vers Docker Compose, Kubernetes et Helm Charts.

## 🎯 Fonctionnalités

- **Interface Web Moderne** : 
  - Éditeur XML avec coloration syntaxique (Monaco Editor)
  - **Formulaire visuel** pour créer des configurations sans écrire de XML
  - Validation en temps réel avec XML Schema (XSD)
  - Prévisualisation des fichiers générés avant téléchargement
  
- **Transformations Multi-Formats** :
  - XML → Docker Compose YAML
  - XML → Kubernetes YAML (Deployment, Service, ConfigMap, Secret)
  - XML → Helm Charts
  - XML → JSON
  - Validation Docker Compose avec Docker CLI
  
- **Gestion Multi-Environnements** :
  - Support de plusieurs environnements (dev, staging, prod)
  - Comparaison entre environnements
  - Export au format JSON
  
- **CI/CD** : 
  - Génération de scripts pour Jenkins
  - Workflows GitHub Actions
  - Intégration dans les pipelines automatisés

## 📋 Prérequis

- Python 3.8+
- Node.js 16+ (pour le frontend)
- npm ou yarn
- Docker (optionnel, pour tester les configurations générées)

## 🚀 Installation

### Backend

```bash
# Créer un environnement virtuel
python -m venv venv

# Activer l'environnement virtuel
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Installer les dépendances
pip install -r requirements.txt

# Lancer le serveur
python app.py
```

Le backend sera accessible sur `http://localhost:5000`

### Frontend

```bash
cd frontend
npm install
npm start
```

Le frontend sera accessible sur `http://localhost:3000`

### Installation Rapide

Utilisez les scripts de démarrage :
- **Windows**: `start.bat`
- **Linux/Mac**: `./start.sh`

## 📁 Structure du projet

```
.
├── app.py                 # Application Flask principale
├── requirements.txt       # Dépendances Python
├── schemas/              # Schémas XML (XSD)
│   └── config.xsd
├── xslt/                 # Transformations XSLT
│   ├── docker-compose.xslt
│   ├── kubernetes.xslt
│   └── helm.xslt
├── examples/             # Exemples de configurations XML
│   └── sample-config.xml
├── templates/           # Templates CI/CD
│   ├── jenkins.groovy
│   └── github-actions.yml
├── scripts/              # Scripts utilitaires
│   ├── validate-xml.py
│   └── generate-yaml.py
├── tests/                # Tests unitaires
│   ├── test_validation.py
│   └── test_transformation.py
├── frontend/             # Application React
│   ├── src/
│   │   ├── components/
│   │   │   ├── ConfigForm.js
│   │   │   └── ConfigForm.css
│   │   ├── App.js
│   │   └── index.js
│   └── package.json
└── docs/                 # Documentation
    ├── xml-guide.md
    └── cicd-integration.md
```

## 🔧 Utilisation

### Mode Éditeur XML

1. Accéder à l'interface web (`http://localhost:3000`)
2. Saisir ou importer une configuration XML
3. Valider la configuration (bouton "Valider XML")
4. Sélectionner un environnement
5. Générer les fichiers Docker Compose, Kubernetes ou Helm Chart
6. Visualiser et télécharger les fichiers générés

### Mode Formulaire Visuel

1. Cliquer sur "Mode Formulaire" dans l'interface
2. Remplir les informations de l'application
3. Ajouter des environnements et services via le formulaire
4. Cliquer sur "Générer XML"
5. Le XML est généré automatiquement et peut être validé/généré

### Comparaison d'Environnements

1. Aller dans l'onglet "Comparer"
2. Sélectionner deux environnements à comparer
3. Voir les différences détaillées

## 📝 Format XML

Voir [docs/xml-guide.md](docs/xml-guide.md) pour la documentation complète du format XML.

## 🧪 Tests

Exécuter les tests unitaires :

```bash
python -m pytest tests/ -v
```

Ou utiliser unittest :

```bash
python -m unittest discover tests
```

## 📚 Documentation

- [Guide du format XML](docs/xml-guide.md)
- [Intégration CI/CD](docs/cicd-integration.md)
- [Guide d'installation](INSTALLATION.md)
- [Guide Minikube](docs/minikube-guide.md) - Tester avec Minikube
- [Personnalisation XSLT](docs/xslt-customization.md) - Personnaliser les transformations
- [Améliorations récentes](IMPROVEMENTS.md)

## 🆕 Nouvelles Fonctionnalités (v2.0)

- ✅ **Formulaire visuel** pour créer des configurations sans XML
- ✅ **Support Helm Charts** - Génération de charts Helm complets
- ✅ **Comparaison d'environnements** - Identifier les différences
- ✅ **Export JSON** - Export des configurations au format JSON
- ✅ **Tests unitaires** - Suite de tests complète
- ✅ **Validation améliorée** - Messages d'erreur détaillés

Voir [IMPROVEMENTS.md](IMPROVEMENTS.md) pour la liste complète des améliorations.

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
1. Ouvrir une issue pour signaler un bug
2. Proposer de nouvelles fonctionnalités
3. Soumettre une pull request

## 📄 Licence

MIT

## 🙏 Remerciements

Projet développé dans le cadre d'un projet pédagogique sur la gestion centralisée des configurations DevOps.
