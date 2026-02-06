<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:param name="environment" select="'dev'"/>
    
    <xsl:template match="/">
        <xsl:text>// Pipeline Jenkins généré automatiquement pour </xsl:text>
        <xsl:value-of select="/devops-config/application/name"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>// Version: </xsl:text>
        <xsl:value-of select="/devops-config/application/version"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>// Description: </xsl:text>
        <xsl:value-of select="/devops-config/application/description"/>
        <xsl:text>&#10;&#10;</xsl:text>
        
        <xsl:text>pipeline {&#10;</xsl:text>
        <xsl:text>    agent any&#10;&#10;</xsl:text>
        
        <!-- Environment Variables -->
        <xsl:text>    environment {&#10;</xsl:text>
        <xsl:text>        APP_NAME = '</xsl:text>
        <xsl:value-of select="/devops-config/application/name"/>
        <xsl:text>'&#10;</xsl:text>
        <xsl:text>        APP_VERSION = '</xsl:text>
        <xsl:value-of select="/devops-config/application/version"/>
        <xsl:text>'&#10;</xsl:text>
        <xsl:text>        DOCKER_REGISTRY = credentials('docker-registry-credentials')&#10;</xsl:text>
        <xsl:text>        KUBECONFIG = credentials('kubeconfig')&#10;</xsl:text>
        <xsl:text>    }&#10;&#10;</xsl:text>
        
        <!-- Stages -->
        <xsl:text>    stages {&#10;</xsl:text>
        
        <!-- Checkout Stage -->
        <xsl:text>        stage('Checkout') {&#10;</xsl:text>
        <xsl:text>            steps {&#10;</xsl:text>
        <xsl:text>                checkout scm&#10;</xsl:text>
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>        }&#10;&#10;</xsl:text>
        
        <!-- Validate XML Stage -->
        <xsl:text>        stage('Validate XML') {&#10;</xsl:text>
        <xsl:text>            steps {&#10;</xsl:text>
        <xsl:text>                script {&#10;</xsl:text>
        <xsl:text>                    sh '''&#10;</xsl:text>
        <xsl:text>                        python3 -m pip install lxml --quiet&#10;</xsl:text>
        <xsl:text>                        python3 scripts/validate-xml.py config.xml&#10;</xsl:text>
        <xsl:text>                    '''&#10;</xsl:text>
        <xsl:text>                }&#10;</xsl:text>
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>        }&#10;&#10;</xsl:text>
        
        <!-- Generate Docker Compose Stage -->
        <xsl:text>        stage('Generate Docker Compose') {&#10;</xsl:text>
        <xsl:text>            when {&#10;</xsl:text>
        <xsl:text>                expression { params.DEPLOY_TARGET == 'docker-compose' }&#10;</xsl:text>
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>            steps {&#10;</xsl:text>
        <xsl:text>                script {&#10;</xsl:text>
        <xsl:text>                    sh '''&#10;</xsl:text>
        <xsl:text>                        python3 scripts/generate-yaml.py config.xml \&#10;</xsl:text>
        <xsl:text>                            --type docker-compose \&#10;</xsl:text>
        <xsl:text>                            --environment ${ENVIRONMENT} \&#10;</xsl:text>
        <xsl:text>                            --output docker-compose.yaml&#10;</xsl:text>
        <xsl:text>                        echo "✅ Fichier docker-compose.yaml généré"&#10;</xsl:text>
        <xsl:text>                    '''&#10;</xsl:text>
        <xsl:text>                }&#10;</xsl:text>
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>        }&#10;&#10;</xsl:text>
        
        <!-- Generate Kubernetes Stage -->
        <xsl:text>        stage('Generate Kubernetes Manifests') {&#10;</xsl:text>
        <xsl:text>            when {&#10;</xsl:text>
        <xsl:text>                expression { params.DEPLOY_TARGET == 'kubernetes' }&#10;</xsl:text>
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>            steps {&#10;</xsl:text>
        <xsl:text>                script {&#10;</xsl:text>
        <xsl:text>                    sh '''&#10;</xsl:text>
        <xsl:text>                        python3 scripts/generate-yaml.py config.xml \&#10;</xsl:text>
        <xsl:text>                            --type kubernetes \&#10;</xsl:text>
        <xsl:text>                            --environment ${ENVIRONMENT} \&#10;</xsl:text>
        <xsl:text>                            --output kubernetes.yaml&#10;</xsl:text>
        <xsl:text>                        echo "✅ Fichier kubernetes.yaml généré"&#10;</xsl:text>
        <xsl:text>                    '''&#10;</xsl:text>
        <xsl:text>                }&#10;</xsl:text>
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>        }&#10;&#10;</xsl:text>
        
        <!-- Build Services Stage -->
        <xsl:text>        stage('Build Services') {&#10;</xsl:text>
        <xsl:text>            when {&#10;</xsl:text>
        <xsl:text>                expression { params.DEPLOY_TARGET == 'docker-compose' || params.DEPLOY_TARGET == 'kubernetes' }&#10;</xsl:text>
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>            parallel {&#10;</xsl:text>
        
        <!-- Generate parallel build stages for each service -->
        <xsl:for-each select="//environment[name=$environment]/services/service">
            <xsl:text>                stage('Build </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text>') {&#10;</xsl:text>
            <xsl:text>                    steps {&#10;</xsl:text>
            <xsl:text>                        script {&#10;</xsl:text>
            <xsl:text>                            echo "Building service: </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text>"&#10;</xsl:text>
            <xsl:text>                            // Image: </xsl:text>
            <xsl:value-of select="image"/>
            <xsl:text>:</xsl:text>
            <xsl:value-of select="tag"/>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>                            // Add your build commands here&#10;</xsl:text>
            <xsl:text>                        }&#10;</xsl:text>
            <xsl:text>                    }&#10;</xsl:text>
            <xsl:text>                }&#10;</xsl:text>
        </xsl:for-each>
        
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>        }&#10;&#10;</xsl:text>
        
        <!-- Validate Docker Compose Stage -->
        <xsl:text>        stage('Validate Docker Compose') {&#10;</xsl:text>
        <xsl:text>            when {&#10;</xsl:text>
        <xsl:text>                expression { params.DEPLOY_TARGET == 'docker-compose' }&#10;</xsl:text>
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>            steps {&#10;</xsl:text>
        <xsl:text>                script {&#10;</xsl:text>
        <xsl:text>                    sh '''&#10;</xsl:text>
        <xsl:text>                        docker-compose -f docker-compose.yaml config&#10;</xsl:text>
        <xsl:text>                        echo "✅ Docker Compose validation réussie"&#10;</xsl:text>
        <xsl:text>                    '''&#10;</xsl:text>
        <xsl:text>                }&#10;</xsl:text>
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>        }&#10;&#10;</xsl:text>
        
        <!-- Validate Kubernetes Stage -->
        <xsl:text>        stage('Validate Kubernetes') {&#10;</xsl:text>
        <xsl:text>            when {&#10;</xsl:text>
        <xsl:text>                expression { params.DEPLOY_TARGET == 'kubernetes' }&#10;</xsl:text>
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>            steps {&#10;</xsl:text>
        <xsl:text>                script {&#10;</xsl:text>
        <xsl:text>                    sh '''&#10;</xsl:text>
        <xsl:text>                        kubectl --dry-run=client -f kubernetes.yaml apply&#10;</xsl:text>
        <xsl:text>                        echo "✅ Kubernetes validation réussie"&#10;</xsl:text>
        <xsl:text>                    '''&#10;</xsl:text>
        <xsl:text>                }&#10;</xsl:text>
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>        }&#10;&#10;</xsl:text>
        
        <!-- Deploy to Docker Compose Stage -->
        <xsl:text>        stage('Deploy to Docker Compose') {&#10;</xsl:text>
        <xsl:text>            when {&#10;</xsl:text>
        <xsl:text>                expression { params.DEPLOY_TARGET == 'docker-compose' }&#10;</xsl:text>
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>            steps {&#10;</xsl:text>
        <xsl:text>                script {&#10;</xsl:text>
        <xsl:text>                    sh '''&#10;</xsl:text>
        <xsl:text>                        docker-compose -f docker-compose.yaml down&#10;</xsl:text>
        <xsl:text>                        docker-compose -f docker-compose.yaml up -d&#10;</xsl:text>
        <xsl:text>                        docker-compose -f docker-compose.yaml ps&#10;</xsl:text>
        <xsl:text>                        echo "✅ Déploiement Docker Compose réussi"&#10;</xsl:text>
        <xsl:text>                    '''&#10;</xsl:text>
        <xsl:text>                }&#10;</xsl:text>
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>        }&#10;&#10;</xsl:text>
        
        <!-- Deploy to Kubernetes Stage -->
        <xsl:text>        stage('Deploy to Kubernetes') {&#10;</xsl:text>
        <xsl:text>            when {&#10;</xsl:text>
        <xsl:text>                expression { params.DEPLOY_TARGET == 'kubernetes' }&#10;</xsl:text>
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>            steps {&#10;</xsl:text>
        <xsl:text>                script {&#10;</xsl:text>
        <xsl:text>                    sh '''&#10;</xsl:text>
        <xsl:text>                        # Apply Kubernetes manifests&#10;</xsl:text>
        <xsl:text>                        kubectl apply -f kubernetes.yaml&#10;</xsl:text>
        <xsl:text>                        &#10;</xsl:text>
        <xsl:text>                        # Wait for deployments to be ready&#10;</xsl:text>
        <xsl:text>                        kubectl rollout status deployment --timeout=5m&#10;</xsl:text>
        <xsl:text>                        &#10;</xsl:text>
        <xsl:text>                        # Display deployment status&#10;</xsl:text>
        <xsl:text>                        kubectl get deployments&#10;</xsl:text>
        <xsl:text>                        kubectl get services&#10;</xsl:text>
        <xsl:text>                        kubectl get pods&#10;</xsl:text>
        <xsl:text>                        echo "✅ Déploiement Kubernetes réussi"&#10;</xsl:text>
        <xsl:text>                    '''&#10;</xsl:text>
        <xsl:text>                }&#10;</xsl:text>
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>        }&#10;&#10;</xsl:text>
        
        <!-- Health Check Stage -->
        <xsl:text>        stage('Health Check') {&#10;</xsl:text>
        <xsl:text>            steps {&#10;</xsl:text>
        <xsl:text>                script {&#10;</xsl:text>
        <xsl:text>                    echo "Vérification de la santé des services..."&#10;</xsl:text>
        <xsl:text>                    // Add your health check logic here&#10;</xsl:text>
        <xsl:for-each select="//environment[name=$environment]/services/service">
            <xsl:text>                    echo "Service: </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text>"&#10;</xsl:text>
        </xsl:for-each>
        <xsl:text>                }&#10;</xsl:text>
        <xsl:text>            }&#10;</xsl:text>
        <xsl:text>        }&#10;</xsl:text>
        
        <xsl:text>    }&#10;&#10;</xsl:text>
        
        <!-- Post Actions -->
        <xsl:text>    post {&#10;</xsl:text>
        <xsl:text>        always {&#10;</xsl:text>
        <xsl:text>            // Archive generated files&#10;</xsl:text>
        <xsl:text>            archiveArtifacts artifacts: '*.yaml', allowEmptyArchive: true&#10;</xsl:text>
        <xsl:text>            // Clean workspace&#10;</xsl:text>
        <xsl:text>            cleanWs()&#10;</xsl:text>
        <xsl:text>        }&#10;</xsl:text>
        <xsl:text>        success {&#10;</xsl:text>
        <xsl:text>            echo '✅ Pipeline terminé avec succès'&#10;</xsl:text>
        <xsl:text>        }&#10;</xsl:text>
        <xsl:text>        failure {&#10;</xsl:text>
        <xsl:text>            echo '❌ Pipeline échoué'&#10;</xsl:text>
        <xsl:text>        }&#10;</xsl:text>
        <xsl:text>    }&#10;</xsl:text>
        <xsl:text>}&#10;&#10;</xsl:text>
        
        <!-- Pipeline Parameters -->
        <xsl:text>// Paramètres du pipeline&#10;</xsl:text>
        <xsl:text>properties([&#10;</xsl:text>
        <xsl:text>    parameters([&#10;</xsl:text>
        <xsl:text>        choice(&#10;</xsl:text>
        <xsl:text>            name: 'ENVIRONMENT',&#10;</xsl:text>
        <xsl:text>            choices: [</xsl:text>
        <xsl:for-each select="//environment/name">
            <xsl:text>'</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>'</xsl:text>
            <xsl:if test="position() != last()">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>],&#10;</xsl:text>
        <xsl:text>            description: 'Environnement de déploiement'&#10;</xsl:text>
        <xsl:text>        ),&#10;</xsl:text>
        <xsl:text>        choice(&#10;</xsl:text>
        <xsl:text>            name: 'DEPLOY_TARGET',&#10;</xsl:text>
        <xsl:text>            choices: ['docker-compose', 'kubernetes'],&#10;</xsl:text>
        <xsl:text>            description: 'Plateforme de déploiement'&#10;</xsl:text>
        <xsl:text>        )&#10;</xsl:text>
        <xsl:text>    ])&#10;</xsl:text>
        <xsl:text>])&#10;</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>
