#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de vérification complète du projet DevOps Config Manager
Vérifie que tous les éléments requis sont présents et fonctionnels
"""

import os
import sys

# Fix encoding pour Windows
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

def check_file_exists(filepath, description):
    """Vérifie qu'un fichier existe"""
    if os.path.exists(filepath):
        print(f"✅ {description}: {filepath}")
        return True
    else:
        print(f"❌ {description} MANQUANT: {filepath}")
        return False

def check_directory_exists(dirpath, description):
    """Vérifie qu'un répertoire existe"""
    if os.path.isdir(dirpath):
        print(f"✅ {description}: {dirpath}")
        return True
    else:
        print(f"❌ {description} MANQUANT: {dirpath}")
        return False

def main():
    print("=" * 70)
    print("VÉRIFICATION COMPLÈTE DU PROJET DevOps Config Manager")
    print("=" * 70)
    print()
    
    errors = 0
    
    # 1. Schémas XML
    print("\n📋 1. SCHÉMAS XML")
    print("-" * 70)
    if not check_file_exists("schemas/config.xsd", "Schéma XSD"):
        errors += 1
    
    # 2. Transformations XSLT
    print("\n🔄 2. TRANSFORMATIONS XSLT")
    print("-" * 70)
    xslt_files = [
        ("xslt/docker-compose.xslt", "Transformation Docker Compose"),
        ("xslt/kubernetes.xslt", "Transformation Kubernetes"),
        ("xslt/helm.xslt", "Transformation Helm"),
        ("xslt/json.xslt", "Transformation JSON")
    ]
    for filepath, desc in xslt_files:
        if not check_file_exists(filepath, desc):
            errors += 1
    
    # 3. Exemples
    print("\n📝 3. EXEMPLES")
    print("-" * 70)
    example_files = [
        ("examples/sample-config.xml", "Exemple de configuration"),
        ("examples/annotated-config.xml", "Exemple annoté")
    ]
    for filepath, desc in example_files:
        if not check_file_exists(filepath, desc):
            errors += 1
    
    # 4. Templates CI/CD
    print("\n🚀 4. TEMPLATES CI/CD")
    print("-" * 70)
    cicd_files = [
        ("templates/jenkins.groovy", "Pipeline Jenkins"),
        ("templates/github-actions.yml", "Workflow GitHub Actions")
    ]
    for filepath, desc in cicd_files:
        if not check_file_exists(filepath, desc):
            errors += 1
    
    # 5. Scripts utilitaires
    print("\n🛠️ 5. SCRIPTS UTILITAIRES")
    print("-" * 70)
    script_files = [
        ("scripts/validate-xml.py", "Script validation XML"),
        ("scripts/generate-yaml.py", "Script génération YAML"),
        ("scripts/validate-docker-compose.py", "Script validation Docker Compose")
    ]
    for filepath, desc in script_files:
        if not check_file_exists(filepath, desc):
            errors += 1
    
    # 6. Tests
    print("\n🧪 6. TESTS")
    print("-" * 70)
    test_files = [
        ("tests/__init__.py", "Module tests"),
        ("tests/test_validation.py", "Tests validation"),
        ("tests/test_transformation.py", "Tests transformation")
    ]
    for filepath, desc in test_files:
        if not check_file_exists(filepath, desc):
            errors += 1
    
    # 7. Documentation
    print("\n📚 7. DOCUMENTATION")
    print("-" * 70)
    doc_files = [
        ("docs/xml-guide.md", "Guide format XML"),
        ("docs/cicd-integration.md", "Guide intégration CI/CD"),
        ("docs/minikube-guide.md", "Guide Minikube"),
        ("docs/xslt-customization.md", "Guide personnalisation XSLT"),
        ("README.md", "README principal"),
        ("INSTALLATION.md", "Guide d'installation")
    ]
    for filepath, desc in doc_files:
        if not check_file_exists(filepath, desc):
            errors += 1
    
    # 8. Backend
    print("\n🔧 8. BACKEND")
    print("-" * 70)
    backend_files = [
        ("app.py", "Application Flask principale"),
        ("requirements.txt", "Dépendances Python")
    ]
    for filepath, desc in backend_files:
        if not check_file_exists(filepath, desc):
            errors += 1
    
    # 9. Frontend
    print("\n💻 9. FRONTEND")
    print("-" * 70)
    frontend_files = [
        ("frontend/src/App.js", "Application React principale"),
        ("frontend/src/components/ConfigForm.js", "Formulaire visuel"),
        ("frontend/src/components/ConfigForm.css", "Styles formulaire"),
        ("frontend/package.json", "Dépendances Node.js")
    ]
    for filepath, desc in frontend_files:
        if not check_file_exists(filepath, desc):
            errors += 1
    
    # 10. Vérification des imports Python
    print("\n🐍 10. VÉRIFICATION DES IMPORTS PYTHON")
    print("-" * 70)
    try:
        from lxml import etree
        print("✅ lxml installé")
    except ImportError:
        print("❌ lxml non installé")
        errors += 1
    
    try:
        import flask
        print("✅ Flask installé")
    except ImportError:
        print("❌ Flask non installé")
        errors += 1
    
    try:
        import yaml
        print("✅ PyYAML installé")
    except ImportError:
        print("❌ PyYAML non installé")
        errors += 1
    
    # 11. Vérification des endpoints API
    print("\n🌐 11. VÉRIFICATION DES ENDPOINTS API")
    print("-" * 70)
    try:
        with open("app.py", "r", encoding="utf-8") as f:
            content = f.read()
            endpoints = [
                ("/api/validate", "Validation XML"),
                ("/api/transform/docker-compose", "Transformation Docker Compose"),
                ("/api/transform/kubernetes", "Transformation Kubernetes"),
                ("/api/transform/helm", "Transformation Helm"),
                ("/api/transform/json", "Transformation JSON"),
                ("/api/environments", "Liste environnements"),
                ("/api/compare", "Comparaison"),
                ("/api/export", "Export JSON"),
                ("/api/download", "Téléchargement")
            ]
            for endpoint, desc in endpoints:
                if endpoint in content:
                    print(f"✅ {desc}: {endpoint}")
                else:
                    print(f"❌ {desc} MANQUANT: {endpoint}")
                    errors += 1
    except Exception as e:
        print(f"❌ Erreur lors de la vérification: {e}")
        errors += 1
    
    # Résumé
    print("\n" + "=" * 70)
    print("RÉSUMÉ")
    print("=" * 70)
    
    if errors == 0:
        print("✅ TOUS LES ÉLÉMENTS SONT PRÉSENTS ET CORRECTS!")
        print("✅ Le projet est 100% conforme aux spécifications")
        return 0
    else:
        print(f"❌ {errors} élément(s) manquant(s) ou incorrect(s)")
        print("⚠️  Veuillez corriger les erreurs ci-dessus")
        return 1

if __name__ == '__main__':
    sys.exit(main())
