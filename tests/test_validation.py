"""
Tests unitaires pour la validation XML
"""

import unittest
import sys
import os

# Ajouter le répertoire parent au path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import validate_xml


class TestValidation(unittest.TestCase):
    
    def test_valid_xml(self):
        """Test avec un XML valide"""
        xml_content = '''<?xml version="1.0" encoding="UTF-8"?>
<devops-config version="1.0">
    <application>
        <name>test-app</name>
        <version>1.0.0</version>
    </application>
    <environments>
        <environment>
            <name>dev</name>
            <services>
                <service>
                    <name>web</name>
                    <image>nginx</image>
                </service>
            </services>
        </environment>
    </environments>
</devops-config>'''
        
        result = validate_xml(xml_content)
        self.assertTrue(result['valid'])
    
    def test_invalid_xml_syntax(self):
        """Test avec un XML syntaxiquement invalide"""
        xml_content = '<devops-config><application><name>test</name></application>'
        
        result = validate_xml(xml_content)
        self.assertFalse(result['valid'])
    
    def test_invalid_xml_structure(self):
        """Test avec un XML structurellement invalide"""
        xml_content = '''<?xml version="1.0" encoding="UTF-8"?>
<devops-config version="1.0">
    <application>
        <name>test-app</name>
    </application>
</devops-config>'''
        
        result = validate_xml(xml_content)
        # Manque la section environments
        self.assertFalse(result['valid'])
    
    def test_missing_required_fields(self):
        """Test avec des champs obligatoires manquants"""
        xml_content = '''<?xml version="1.0" encoding="UTF-8"?>
<devops-config version="1.0">
    <application>
        <name>test-app</name>
    </application>
    <environments>
        <environment>
            <name>dev</name>
            <services>
                <service>
                    <image>nginx</image>
                </service>
            </services>
        </environment>
    </environments>
</devops-config>'''
        
        result = validate_xml(xml_content)
        # Manque le nom du service
        self.assertFalse(result['valid'])


if __name__ == '__main__':
    unittest.main()
