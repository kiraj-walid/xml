#!/usr/bin/env python3
"""
Script de configuration pour le projet DevOps Config Manager
"""

import os
import sys

def create_directories():
    """Crée les répertoires nécessaires"""
    directories = [
        'generated',
        'logs',
        '.github/workflows'
    ]
    
    for directory in directories:
        os.makedirs(directory, exist_ok=True)
        print(f"✓ Répertoire créé: {directory}")

def check_dependencies():
    """Vérifie les dépendances Python"""
    try:
        import lxml
        print("✓ lxml installé")
    except ImportError:
        print("✗ lxml non installé. Exécutez: pip install -r requirements.txt")
        return False
    
    try:
        import flask
        print("✓ Flask installé")
    except ImportError:
        print("✗ Flask non installé. Exécutez: pip install -r requirements.txt")
        return False
    
    return True

def setup_github_workflow():
    """Configure le workflow GitHub Actions"""
    workflow_dir = '.github/workflows'
    os.makedirs(workflow_dir, exist_ok=True)
    
    workflow_file = os.path.join(workflow_dir, 'cicd.yml')
    if not os.path.exists(workflow_file):
        import shutil
        shutil.copy('templates/github-actions.yml', workflow_file)
        print(f"✓ Workflow GitHub Actions créé: {workflow_file}")
    else:
        print(f"ℹ Workflow GitHub Actions existe déjà: {workflow_file}")

def main():
    print("🚀 Configuration du projet DevOps Config Manager\n")
    
    print("1. Création des répertoires...")
    create_directories()
    
    print("\n2. Vérification des dépendances...")
    if not check_dependencies():
        print("\n❌ Veuillez installer les dépendances avant de continuer")
        sys.exit(1)
    
    print("\n3. Configuration GitHub Actions...")
    setup_github_workflow()
    
    print("\n✅ Configuration terminée!")
    print("\nProchaines étapes:")
    print("  1. Lancer le backend: python app.py")
    print("  2. Lancer le frontend: cd frontend && npm install && npm start")
    print("  3. Accéder à l'application: http://localhost:3000")

if __name__ == '__main__':
    main()
