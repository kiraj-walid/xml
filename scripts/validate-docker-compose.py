#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour valider les fichiers Docker Compose générés avec Docker CLI
"""

import sys
import os
import subprocess
import json

def validate_docker_compose(file_path):
    """Valide un fichier Docker Compose avec docker-compose config"""
    try:
        # Vérifier si docker-compose est disponible
        result = subprocess.run(
            ['docker-compose', '--version'],
            capture_output=True,
            text=True,
            timeout=5
        )
        
        if result.returncode != 0:
            print("⚠️ docker-compose n'est pas installé ou non disponible")
            return False
        
        print(f"✓ Validation du fichier: {file_path}")
        
        # Valider avec docker-compose config
        result = subprocess.run(
            ['docker-compose', '-f', file_path, 'config'],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            print("✅ Fichier Docker Compose valide")
            print("\nConfiguration validée:")
            print(result.stdout)
            return True
        else:
            print("❌ Erreurs de validation:")
            print(result.stderr)
            return False
            
    except FileNotFoundError:
        print("❌ docker-compose n'est pas installé")
        print("Installez Docker Desktop ou Docker Compose")
        return False
    except subprocess.TimeoutExpired:
        print("❌ Timeout lors de la validation")
        return False
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python validate-docker-compose.py <fichier-docker-compose.yaml>")
        print("Exemple: python validate-docker-compose.py docker-compose-dev.yaml")
        sys.exit(1)
    
    file_path = sys.argv[1]
    
    if not os.path.exists(file_path):
        print(f"❌ Fichier non trouvé: {file_path}")
        sys.exit(1)
    
    success = validate_docker_compose(file_path)
    sys.exit(0 if success else 1)
