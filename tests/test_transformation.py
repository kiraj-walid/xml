"""
Tests unitaires pour les transformations XSLT
"""

import unittest
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import transform_xml, validate_xml
from app import DOCKER_COMPOSE_XSLT, KUBERNETES_XSLT


class TestTransformation(unittest.TestCase):
    
    def setUp(self):
        """Préparer un XML de test valide"""
        self.valid_xml = '''<?xml version="1.0" encoding="UTF-8"?>
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
                    <tag>alpine</tag>
                    <ports>
                        <port>
                            <host>8080</host>
                            <container>80</container>
                        </port>
                    </ports>
                </service>
            </services>
        </environment>
    </environments>
</devops-config>'''
    
    def test_docker_compose_transformation(self):
        """Test transformation vers Docker Compose"""
        result = transform_xml(self.valid_xml, DOCKER_COMPOSE_XSLT, 'dev')
        self.assertTrue(result['success'])
        self.assertIsNotNone(result['content'])
        self.assertIn('version:', result['content'])
        self.assertIn('services:', result['content'])
        self.assertIn('web:', result['content'])
    
    def test_kubernetes_transformation(self):
        """Test transformation vers Kubernetes"""
        result = transform_xml(self.valid_xml, KUBERNETES_XSLT, 'dev')
        self.assertTrue(result['success'])
        self.assertIsNotNone(result['content'])
        self.assertIn('apiVersion:', result['content'])
        self.assertIn('kind: Deployment', result['content'])
    
    def test_environment_selection(self):
        """Test sélection d'environnement"""
        xml_multi_env = '''<?xml version="1.0" encoding="UTF-8"?>
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
        <environment>
            <name>prod</name>
            <services>
                <service>
                    <name>web</name>
                    <image>nginx</image>
                    <replicas>3</replicas>
                </service>
            </services>
        </environment>
    </environments>
</devops-config>'''
        
        # Test dev
        result_dev = transform_xml(xml_multi_env, KUBERNETES_XSLT, 'dev')
        self.assertTrue(result_dev['success'])
        self.assertNotIn('replicas: 3', result_dev['content'])
        
        # Test prod
        result_prod = transform_xml(xml_multi_env, KUBERNETES_XSLT, 'prod')
        self.assertTrue(result_prod['success'])
        self.assertIn('replicas: 3', result_prod['content'])


if __name__ == '__main__':
    unittest.main()
