#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour valider un fichier XML contre le schéma XSD
"""

import sys
import os
from lxml import etree

# Fix encoding pour Windows
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

def validate_xml(xml_path, xsd_path=None):
    """Valide un fichier XML contre le schéma XSD"""
    if xsd_path is None:
        # Utiliser le schéma par défaut
        script_dir = os.path.dirname(os.path.abspath(__file__))
        xsd_path = os.path.join(script_dir, '..', 'schemas', 'config.xsd')
    
    try:
        # Parser le XML
        xml_doc = etree.parse(xml_path)
        print(f"✓ Fichier XML parsé: {xml_path}")
        
        # Charger le schéma XSD
        xsd_doc = etree.parse(xsd_path)
        xsd_schema = etree.XMLSchema(xsd_doc)
        print(f"✓ Schéma XSD chargé: {xsd_path}")
        
        # Valider
        is_valid = xsd_schema.validate(xml_doc)
        
        if is_valid:
            print("✅ Validation réussie: Le fichier XML est valide")
            return 0
        else:
            print("❌ Validation échouée: Le fichier XML contient des erreurs")
            print("\nErreurs détectées:")
            for error in xsd_schema.error_log:
                print(f"  Ligne {error.line}: {error.message}")
            return 1
            
    except etree.XMLSyntaxError as e:
        print(f"❌ Erreur de syntaxe XML: {e}")
        return 1
    except FileNotFoundError as e:
        print(f"❌ Fichier non trouvé: {e}")
        return 1
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return 1

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python validate-xml.py <fichier-xml> [fichier-xsd]")
        print("Exemple: python validate-xml.py examples/sample-config.xml")
        sys.exit(1)
    
    xml_file = sys.argv[1]
    xsd_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    exit_code = validate_xml(xml_file, xsd_file)
    sys.exit(exit_code)
