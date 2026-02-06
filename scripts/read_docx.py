#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour lire le contenu du document Word et l'extraire
"""

import sys
import os
import glob

# Fix encoding pour Windows
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

try:
    from docx import Document
    
    # Trouver le fichier docx
    files = glob.glob('docs/*.docx')
    if not files:
        print("Aucun fichier .docx trouvé dans docs/")
        sys.exit(1)
    
    filepath = files[0]
    print(f"Lecture du fichier: {filepath}\n")
    
    doc = Document(filepath)
    
    # Extraire tout le texte
    all_text = []
    for para in doc.paragraphs:
        if para.text.strip():
            all_text.append(para.text.strip())
    
    # Sauvegarder dans un fichier texte
    output_file = 'docs/document_content.txt'
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(all_text))
    
    print(f"Contenu extrait et sauvegardé dans {output_file}")
    print(f"\nNombre de paragraphes: {len(all_text)}")
    print("\nPremiers paragraphes:")
    print('\n'.join(all_text[:50]))
    
except ImportError:
    print("Erreur: python-docx n'est pas installé")
    print("Installez-le avec: pip install python-docx")
    sys.exit(1)
except Exception as e:
    print(f"Erreur: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
