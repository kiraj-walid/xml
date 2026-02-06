#!/usr/bin/env python3
"""
Script pour générer des fichiers YAML depuis XML
"""

import sys
import os
import argparse
from lxml import etree

def generate_yaml(xml_path, xslt_path, environment, output_path=None):
    """Génère un fichier YAML depuis XML en utilisant XSLT"""
    try:
        # Parser le XML
        xml_doc = etree.parse(xml_path)
        print(f"✓ Fichier XML chargé: {xml_path}")
        
        # Charger le XSLT
        xslt_doc = etree.parse(xslt_path)
        xslt_transformer = etree.XSLT(xslt_doc)
        print(f"✓ Transformation XSLT chargée: {xslt_path}")
        
        # Appliquer la transformation
        result = xslt_transformer(xml_doc, environment=etree.XSLT.strparam(environment))
        print(f"✓ Transformation appliquée pour l'environnement: {environment}")
        
        # Écrire le résultat
        if output_path:
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(str(result))
            print(f"✅ Fichier généré: {output_path}")
        else:
            print("\n" + "="*50)
            print(str(result))
            print("="*50)
        
        return 0
        
    except FileNotFoundError as e:
        print(f"❌ Fichier non trouvé: {e}")
        return 1
    except Exception as e:
        print(f"❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
        return 1

def main():
    parser = argparse.ArgumentParser(description='Génère des fichiers YAML depuis XML')
    parser.add_argument('xml_file', help='Fichier XML source')
    parser.add_argument('--type', choices=['docker-compose', 'kubernetes'], 
                       required=True, help='Type de fichier à générer')
    parser.add_argument('--environment', default='dev', 
                       help='Environnement cible (défaut: dev)')
    parser.add_argument('--output', '-o', help='Fichier de sortie (optionnel)')
    
    args = parser.parse_args()
    
    # Déterminer le chemin XSLT
    script_dir = os.path.dirname(os.path.abspath(__file__))
    if args.type == 'docker-compose':
        xslt_file = os.path.join(script_dir, '..', 'xslt', 'docker-compose.xslt')
    else:
        xslt_file = os.path.join(script_dir, '..', 'xslt', 'kubernetes.xslt')
    
    # Générer le nom de sortie par défaut
    if not args.output:
        if args.type == 'docker-compose':
            args.output = f'docker-compose-{args.environment}.yaml'
        else:
            args.output = f'kubernetes-{args.environment}.yaml'
    
    exit_code = generate_yaml(args.xml_file, xslt_file, args.environment, args.output)
    sys.exit(exit_code)

if __name__ == '__main__':
    main()
