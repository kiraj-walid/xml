<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:param name="environment" select="'dev'"/>
    
    <xsl:template match="/">
        <xsl:text>name: CI/CD Pipeline - </xsl:text>
        <xsl:value-of select="/devops-config/application/name"/>
        <xsl:text>&#10;&#10;</xsl:text>
        
        <xsl:text>on:&#10;</xsl:text>
        <xsl:text>  push:&#10;</xsl:text>
        <xsl:text>    branches: [ main, develop ]&#10;</xsl:text>
        <xsl:text>  pull_request:&#10;</xsl:text>
        <xsl:text>    branches: [ main ]&#10;</xsl:text>
        <xsl:text>  workflow_dispatch:&#10;</xsl:text>
        <xsl:text>    inputs:&#10;</xsl:text>
        <xsl:text>      environment:&#10;</xsl:text>
        <xsl:text>        description: 'Environnement de déploiement'&#10;</xsl:text>
        <xsl:text>        required: true&#10;</xsl:text>
        <xsl:text>        default: 'dev'&#10;</xsl:text>
        <xsl:text>        type: choice&#10;</xsl:text>
        <xsl:text>        options:&#10;</xsl:text>
        <xsl:for-each select="//environment/name">
            <xsl:text>          - </xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
        <xsl:text>      deploy_target:&#10;</xsl:text>
        <xsl:text>        description: 'Plateforme de déploiement'&#10;</xsl:text>
        <xsl:text>        required: true&#10;</xsl:text>
        <xsl:text>        default: 'docker-compose'&#10;</xsl:text>
        <xsl:text>        type: choice&#10;</xsl:text>
        <xsl:text>        options:&#10;</xsl:text>
        <xsl:text>          - docker-compose&#10;</xsl:text>
        <xsl:text>          - kubernetes&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
        
        <xsl:text>env:&#10;</xsl:text>
        <xsl:text>  PYTHON_VERSION: '3.11'&#10;</xsl:text>
        <xsl:text>  APP_NAME: </xsl:text>
        <xsl:value-of select="/devops-config/application/name"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>  APP_VERSION: </xsl:text>
        <xsl:value-of select="/devops-config/application/version"/>
        <xsl:text>&#10;&#10;</xsl:text>
        
        <xsl:text>jobs:&#10;</xsl:text>
        
        <!-- Validation Job -->
        <xsl:text>  validate-xml:&#10;</xsl:text>
        <xsl:text>    name: Valider la configuration XML&#10;</xsl:text>
        <xsl:text>    runs-on: ubuntu-latest&#10;</xsl:text>
        <xsl:text>    steps:&#10;</xsl:text>
        <xsl:text>      - name: Checkout code&#10;</xsl:text>
        <xsl:text>        uses: actions/checkout@v4&#10;&#10;</xsl:text>
        <xsl:text>      - name: Setup Python&#10;</xsl:text>
        <xsl:text>        uses: actions/setup-python@v5&#10;</xsl:text>
        <xsl:text>        with:&#10;</xsl:text>
        <xsl:text>          python-version: ${{ env.PYTHON_VERSION }}&#10;&#10;</xsl:text>
        <xsl:text>      - name: Install dependencies&#10;</xsl:text>
        <xsl:text>        run: |&#10;</xsl:text>
        <xsl:text>          python -m pip install --upgrade pip&#10;</xsl:text>
        <xsl:text>          pip install lxml&#10;&#10;</xsl:text>
        <xsl:text>      - name: Validate XML against XSD&#10;</xsl:text>
        <xsl:text>        run: |&#10;</xsl:text>
        <xsl:text>          python scripts/validate-xml.py config.xml&#10;&#10;</xsl:text>
        
        <!-- Generate Docker Compose Job -->
        <xsl:text>  generate-docker-compose:&#10;</xsl:text>
        <xsl:text>    name: Générer Docker Compose&#10;</xsl:text>
        <xsl:text>    runs-on: ubuntu-latest&#10;</xsl:text>
        <xsl:text>    needs: validate-xml&#10;</xsl:text>
        <xsl:text>    if: github.event.inputs.deploy_target == 'docker-compose' || github.event_name == 'push'&#10;</xsl:text>
        <xsl:text>    steps:&#10;</xsl:text>
        <xsl:text>      - name: Checkout code&#10;</xsl:text>
        <xsl:text>        uses: actions/checkout@v4&#10;&#10;</xsl:text>
        <xsl:text>      - name: Setup Python&#10;</xsl:text>
        <xsl:text>        uses: actions/setup-python@v5&#10;</xsl:text>
        <xsl:text>        with:&#10;</xsl:text>
        <xsl:text>          python-version: ${{ env.PYTHON_VERSION }}&#10;&#10;</xsl:text>
        <xsl:text>      - name: Install dependencies&#10;</xsl:text>
        <xsl:text>        run: |&#10;</xsl:text>
        <xsl:text>          python -m pip install --upgrade pip&#10;</xsl:text>
        <xsl:text>          pip install lxml pyyaml&#10;&#10;</xsl:text>
        <xsl:text>      - name: Generate Docker Compose YAML&#10;</xsl:text>
        <xsl:text>        run: |&#10;</xsl:text>
        <xsl:text>          ENVIRONMENT=${{ github.event.inputs.environment || 'dev' }}&#10;</xsl:text>
        <xsl:text>          python scripts/generate-yaml.py config.xml --type docker-compose --environment $ENVIRONMENT --output generated/docker-compose-$ENVIRONMENT.yaml&#10;&#10;</xsl:text>
        <xsl:text>      - name: Validate Docker Compose&#10;</xsl:text>
        <xsl:text>        run: |&#10;</xsl:text>
        <xsl:text>          ENVIRONMENT=${{ github.event.inputs.environment || 'dev' }}&#10;</xsl:text>
        <xsl:text>          docker-compose -f generated/docker-compose-$ENVIRONMENT.yaml config&#10;&#10;</xsl:text>
        <xsl:text>      - name: Upload artifact&#10;</xsl:text>
        <xsl:text>        uses: actions/upload-artifact@v4&#10;</xsl:text>
        <xsl:text>        with:&#10;</xsl:text>
        <xsl:text>          name: docker-compose-${{ github.event.inputs.environment || 'dev' }}&#10;</xsl:text>
        <xsl:text>          path: generated/docker-compose-*.yaml&#10;&#10;</xsl:text>
        
        <!-- Generate Kubernetes Job -->
        <xsl:text>  generate-kubernetes:&#10;</xsl:text>
        <xsl:text>    name: Générer Kubernetes Manifests&#10;</xsl:text>
        <xsl:text>    runs-on: ubuntu-latest&#10;</xsl:text>
        <xsl:text>    needs: validate-xml&#10;</xsl:text>
        <xsl:text>    if: github.event.inputs.deploy_target == 'kubernetes' || github.event_name == 'push'&#10;</xsl:text>
        <xsl:text>    steps:&#10;</xsl:text>
        <xsl:text>      - name: Checkout code&#10;</xsl:text>
        <xsl:text>        uses: actions/checkout@v4&#10;&#10;</xsl:text>
        <xsl:text>      - name: Setup Python&#10;</xsl:text>
        <xsl:text>        uses: actions/setup-python@v5&#10;</xsl:text>
        <xsl:text>        with:&#10;</xsl:text>
        <xsl:text>          python-version: ${{ env.PYTHON_VERSION }}&#10;&#10;</xsl:text>
        <xsl:text>      - name: Install dependencies&#10;</xsl:text>
        <xsl:text>        run: |&#10;</xsl:text>
        <xsl:text>          python -m pip install --upgrade pip&#10;</xsl:text>
        <xsl:text>          pip install lxml pyyaml&#10;&#10;</xsl:text>
        <xsl:text>      - name: Setup kubectl&#10;</xsl:text>
        <xsl:text>        uses: azure/setup-kubectl@v3&#10;</xsl:text>
        <xsl:text>        with:&#10;</xsl:text>
        <xsl:text>          version: 'latest'&#10;&#10;</xsl:text>
        <xsl:text>      - name: Generate Kubernetes YAML&#10;</xsl:text>
        <xsl:text>        run: |&#10;</xsl:text>
        <xsl:text>          ENVIRONMENT=${{ github.event.inputs.environment || 'dev' }}&#10;</xsl:text>
        <xsl:text>          python scripts/generate-yaml.py config.xml --type kubernetes --environment $ENVIRONMENT --output generated/kubernetes-$ENVIRONMENT.yaml&#10;&#10;</xsl:text>
        <xsl:text>      - name: Validate Kubernetes manifests&#10;</xsl:text>
        <xsl:text>        run: |&#10;</xsl:text>
        <xsl:text>          ENVIRONMENT=${{ github.event.inputs.environment || 'dev' }}&#10;</xsl:text>
        <xsl:text>          kubectl --dry-run=client -f generated/kubernetes-$ENVIRONMENT.yaml apply&#10;&#10;</xsl:text>
        <xsl:text>      - name: Upload artifact&#10;</xsl:text>
        <xsl:text>        uses: actions/upload-artifact@v4&#10;</xsl:text>
        <xsl:text>        with:&#10;</xsl:text>
        <xsl:text>          name: kubernetes-${{ github.event.inputs.environment || 'dev' }}&#10;</xsl:text>
        <xsl:text>          path: generated/kubernetes-*.yaml&#10;&#10;</xsl:text>
        
        <!-- Build Services Job -->
        <xsl:text>  build-services:&#10;</xsl:text>
        <xsl:text>    name: Build Docker Images&#10;</xsl:text>
        <xsl:text>    runs-on: ubuntu-latest&#10;</xsl:text>
        <xsl:text>    needs: validate-xml&#10;</xsl:text>
        <xsl:text>    if: github.event_name == 'push' || github.event.inputs.environment != ''&#10;</xsl:text>
        <xsl:text>    strategy:&#10;</xsl:text>
        <xsl:text>      matrix:&#10;</xsl:text>
        <xsl:text>        service:&#10;</xsl:text>
        <xsl:for-each select="//environment[name=$environment]/services/service">
            <xsl:text>          - </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
        <xsl:text>    steps:&#10;</xsl:text>
        <xsl:text>      - name: Checkout code&#10;</xsl:text>
        <xsl:text>        uses: actions/checkout@v4&#10;&#10;</xsl:text>
        <xsl:text>      - name: Build ${{ matrix.service }}&#10;</xsl:text>
        <xsl:text>        run: |&#10;</xsl:text>
        <xsl:text>          echo "Building service: ${{ matrix.service }}"&#10;</xsl:text>
        <xsl:text>          # Add your build commands here&#10;&#10;</xsl:text>
        
        <!-- Deploy Docker Compose Job -->
        <xsl:text>  deploy-docker-compose:&#10;</xsl:text>
        <xsl:text>    name: Déployer sur Docker Compose&#10;</xsl:text>
        <xsl:text>    runs-on: ubuntu-latest&#10;</xsl:text>
        <xsl:text>    needs: [generate-docker-compose, build-services]&#10;</xsl:text>
        <xsl:text>    if: github.event.inputs.deploy_target == 'docker-compose' &amp;&amp; github.event.inputs.environment != ''&#10;</xsl:text>
        <xsl:text>    environment: ${{ github.event.inputs.environment }}&#10;</xsl:text>
        <xsl:text>    steps:&#10;</xsl:text>
        <xsl:text>      - name: Checkout code&#10;</xsl:text>
        <xsl:text>        uses: actions/checkout@v4&#10;&#10;</xsl:text>
        <xsl:text>      - name: Download artifact&#10;</xsl:text>
        <xsl:text>        uses: actions/download-artifact@v4&#10;</xsl:text>
        <xsl:text>        with:&#10;</xsl:text>
        <xsl:text>          name: docker-compose-${{ github.event.inputs.environment }}&#10;&#10;</xsl:text>
        <xsl:text>      - name: Deploy&#10;</xsl:text>
        <xsl:text>        run: |&#10;</xsl:text>
        <xsl:text>          ENVIRONMENT=${{ github.event.inputs.environment }}&#10;</xsl:text>
        <xsl:text>          docker-compose -f generated/docker-compose-$ENVIRONMENT.yaml up -d&#10;</xsl:text>
        <xsl:text>          docker-compose -f generated/docker-compose-$ENVIRONMENT.yaml ps&#10;&#10;</xsl:text>
        
        <!-- Deploy Kubernetes Job -->
        <xsl:text>  deploy-kubernetes:&#10;</xsl:text>
        <xsl:text>    name: Déployer sur Kubernetes&#10;</xsl:text>
        <xsl:text>    runs-on: ubuntu-latest&#10;</xsl:text>
        <xsl:text>    needs: [generate-kubernetes, build-services]&#10;</xsl:text>
        <xsl:text>    if: github.event.inputs.deploy_target == 'kubernetes' &amp;&amp; github.event.inputs.environment != ''&#10;</xsl:text>
        <xsl:text>    environment: ${{ github.event.inputs.environment }}&#10;</xsl:text>
        <xsl:text>    steps:&#10;</xsl:text>
        <xsl:text>      - name: Checkout code&#10;</xsl:text>
        <xsl:text>        uses: actions/checkout@v4&#10;&#10;</xsl:text>
        <xsl:text>      - name: Download artifact&#10;</xsl:text>
        <xsl:text>        uses: actions/download-artifact@v4&#10;</xsl:text>
        <xsl:text>        with:&#10;</xsl:text>
        <xsl:text>          name: kubernetes-${{ github.event.inputs.environment }}&#10;&#10;</xsl:text>
        <xsl:text>      - name: Setup kubectl&#10;</xsl:text>
        <xsl:text>        uses: azure/setup-kubectl@v3&#10;&#10;</xsl:text>
        <xsl:text>      - name: Configure kubectl&#10;</xsl:text>
        <xsl:text>        run: |&#10;</xsl:text>
        <xsl:text>          # Configure cluster access&#10;</xsl:text>
        <xsl:text>          echo "Configuring kubectl..."&#10;&#10;</xsl:text>
        <xsl:text>      - name: Deploy to Kubernetes&#10;</xsl:text>
        <xsl:text>        run: |&#10;</xsl:text>
        <xsl:text>          ENVIRONMENT=${{ github.event.inputs.environment }}&#10;</xsl:text>
        <xsl:text>          kubectl apply -f generated/kubernetes-$ENVIRONMENT.yaml&#10;</xsl:text>
        <xsl:text>          kubectl get deployments&#10;</xsl:text>
        <xsl:text>          kubectl get services&#10;</xsl:text>
        <xsl:text>          kubectl get pods&#10;</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>
