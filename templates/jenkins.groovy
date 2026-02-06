// Pipeline Jenkins généré automatiquement
// Utilise les configurations XML pour déployer sur Docker/Kubernetes

pipeline {
    agent any
    
    environment {
        // Variables d'environnement depuis les secrets
        DOCKER_REGISTRY = credentials('docker-registry-credentials')
        KUBECONFIG = credentials('kubeconfig')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Validate XML') {
            steps {
                script {
                    // Valider le fichier XML de configuration
                    sh '''
                        python3 -m pip install lxml --quiet
                        python3 -c "
                        from lxml import etree
                        xml_doc = etree.parse('config.xml')
                        xsd_doc = etree.parse('schemas/config.xsd')
                        xsd_schema = etree.XMLSchema(xsd_doc)
                        if not xsd_schema.validate(xml_doc):
                            print('Erreurs de validation:')
                            for error in xsd_schema.error_log:
                                print(f'  Ligne {error.line}: {error.message}')
                            exit(1)
                        print('Validation XML réussie')
                        "
                    '''
                }
            }
        }
        
        stage('Generate Docker Compose') {
            when {
                expression { params.DEPLOY_TARGET == 'docker-compose' }
            }
            steps {
                script {
                    sh '''
                        python3 -c "
                        from lxml import etree
                        import sys
                        xml_doc = etree.parse('config.xml')
                        xslt_doc = etree.parse('xslt/docker-compose.xslt')
                        xslt_transformer = etree.XSLT(xslt_doc)
                        result = xslt_transformer(xml_doc, environment=etree.XSLT.strparam('${ENVIRONMENT}'))
                        with open('docker-compose.yaml', 'w') as f:
                            f.write(str(result))
                        print('Fichier docker-compose.yaml généré')
                        "
                    '''
                }
            }
        }
        
        stage('Generate Kubernetes Manifests') {
            when {
                expression { params.DEPLOY_TARGET == 'kubernetes' }
            }
            steps {
                script {
                    sh '''
                        python3 -c "
                        from lxml import etree
                        xml_doc = etree.parse('config.xml')
                        xslt_doc = etree.parse('xslt/kubernetes.xslt')
                        xslt_transformer = etree.XSLT(xslt_doc)
                        result = xslt_transformer(xml_doc, environment=etree.XSLT.strparam('${ENVIRONMENT}'))
                        with open('kubernetes.yaml', 'w') as f:
                            f.write(str(result))
                        print('Fichier kubernetes.yaml généré')
                        "
                    '''
                }
            }
        }
        
        stage('Build Docker Images') {
            when {
                expression { params.DEPLOY_TARGET == 'docker-compose' || params.DEPLOY_TARGET == 'kubernetes' }
            }
            steps {
                script {
                    // Extraire les images depuis le XML et les builder
                    sh '''
                        python3 -c "
                        from lxml import etree
                        xml_doc = etree.parse('config.xml')
                        env = xml_doc.xpath(f'//environment[name=\\'${ENVIRONMENT}\\']')[0]
                        for service in env.xpath('.//service'):
                            name = service.xpath('name/text()')[0]
                            image = service.xpath('image/text()')[0]
                            tag = service.xpath('tag/text()')[0] if service.xpath('tag/text()') else 'latest'
                            full_image = f'{image}:{tag}'
                            print(f'Image: {full_image}')
                        "
                    '''
                }
            }
        }
        
        stage('Deploy to Docker Compose') {
            when {
                expression { params.DEPLOY_TARGET == 'docker-compose' }
            }
            steps {
                script {
                    sh '''
                        docker-compose -f docker-compose.yaml down
                        docker-compose -f docker-compose.yaml up -d
                        docker-compose -f docker-compose.yaml ps
                    '''
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            when {
                expression { params.DEPLOY_TARGET == 'kubernetes' }
            }
            steps {
                script {
                    sh '''
                        # Appliquer les secrets depuis AWS Secrets Manager ou Vault
                        # Exemple avec AWS Secrets Manager
                        # aws secretsmanager get-secret-value --secret-id prod/db/password | jq -r .SecretString | kubectl create secret generic app-secrets --from-file=password=/dev/stdin
                        
                        # Appliquer les configurations
                        kubectl apply -f kubernetes.yaml
                        
                        # Vérifier le déploiement
                        kubectl get deployments
                        kubectl get services
                        kubectl get pods
                    '''
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    sh '''
                        echo "Vérification de la santé des services..."
                        # Ajouter vos vérifications de santé ici
                    '''
                }
            }
        }
    }
    
    post {
        always {
            // Nettoyage
            cleanWs()
        }
        success {
            echo 'Pipeline terminé avec succès'
        }
        failure {
            echo 'Pipeline échoué'
        }
    }
}

// Paramètres du pipeline
properties([
    parameters([
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Environnement de déploiement'
        ),
        choice(
            name: 'DEPLOY_TARGET',
            choices: ['docker-compose', 'kubernetes'],
            description: 'Plateforme de déploiement'
        )
    ])
])
