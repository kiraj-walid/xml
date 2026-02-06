# Intégration CI/CD

Ce guide explique comment intégrer les configurations générées dans vos pipelines CI/CD.

## Vue d'ensemble

Les fichiers XML peuvent être intégrés dans des pipelines CI/CD pour automatiser :
- La validation des configurations
- La génération des fichiers Docker Compose et Kubernetes
- Le déploiement automatique sur les environnements cibles

## GitHub Actions

### Configuration

1. Copiez le fichier `.github/workflows/cicd.yml` (basé sur `templates/github-actions.yml`) dans votre dépôt
2. Configurez les secrets nécessaires dans GitHub :
   - `KUBECONFIG` : Configuration Kubernetes
   - `DOCKER_REGISTRY_TOKEN` : Token pour le registre Docker
   - `AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY` : Pour AWS Secrets Manager

### Utilisation

Le workflow peut être déclenché :
- Automatiquement sur push vers `main` ou `develop`
- Manuellement via l'interface GitHub Actions avec sélection de l'environnement

### Étapes du pipeline

1. **Validation XML** : Valide le fichier XML contre le schéma XSD
2. **Génération Docker Compose** : Génère le fichier YAML pour Docker Compose
3. **Génération Kubernetes** : Génère les manifests Kubernetes
4. **Déploiement** : Déploie selon la plateforme sélectionnée

### Exemple de workflow

```yaml
name: Deploy Application

on:
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        options: [dev, staging, prod]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Generate Kubernetes manifests
        run: |
          python -c "
          from lxml import etree
          xml_doc = etree.parse('config.xml')
          xslt_doc = etree.parse('xslt/kubernetes.xslt')
          transformer = etree.XSLT(xslt_doc)
          result = transformer(xml_doc, environment='${{ github.event.inputs.environment }}')
          print(str(result))
          " > k8s.yaml
      - name: Deploy to Kubernetes
        run: kubectl apply -f k8s.yaml
```

## Jenkins

### Configuration

1. Créez un nouveau pipeline Jenkins
2. Copiez le contenu de `templates/jenkins.groovy` dans la définition du pipeline
3. Configurez les credentials :
   - `docker-registry-credentials` : Credentials Docker
   - `kubeconfig` : Configuration Kubernetes

### Paramètres du pipeline

- `ENVIRONMENT` : Environnement de déploiement (dev, staging, prod)
- `DEPLOY_TARGET` : Plateforme (docker-compose, kubernetes)

### Étapes du pipeline

1. **Checkout** : Récupération du code
2. **Validate XML** : Validation du fichier XML
3. **Generate** : Génération des fichiers YAML
4. **Build** : Construction des images Docker
5. **Deploy** : Déploiement sur la plateforme cible
6. **Health Check** : Vérification de la santé des services

### Exemple d'utilisation

```groovy
pipeline {
    agent any
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'])
        choice(name: 'DEPLOY_TARGET', choices: ['docker-compose', 'kubernetes'])
    }
    stages {
        stage('Deploy') {
            steps {
                sh '''
                    python3 -c "
                    from lxml import etree
                    xml_doc = etree.parse('config.xml')
                    xslt_doc = etree.parse('xslt/kubernetes.xslt')
                    transformer = etree.XSLT(xslt_doc)
                    result = transformer(xml_doc, environment='${ENVIRONMENT}')
                    with open('k8s.yaml', 'w') as f:
                        f.write(str(result))
                    "
                    kubectl apply -f k8s.yaml
                '''
            }
        }
    }
}
```

## Gestion des secrets

### AWS Secrets Manager

Pour charger des secrets depuis AWS Secrets Manager :

```bash
# Récupérer un secret
SECRET_VALUE=$(aws secretsmanager get-secret-value \
    --secret-id prod/db/password \
    --query SecretString \
    --output text)

# Créer un secret Kubernetes
kubectl create secret generic app-secrets \
    --from-literal=db-password="$SECRET_VALUE"
```

### HashiCorp Vault

Pour charger des secrets depuis Vault :

```bash
# Récupérer un secret
SECRET_VALUE=$(vault kv get -field=password secret/api/key)

# Créer un secret Kubernetes
kubectl create secret generic app-secrets \
    --from-literal=api-key="$SECRET_VALUE"
```

### Intégration dans le pipeline

```yaml
- name: Load secrets from AWS Secrets Manager
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  run: |
    # Charger les secrets définis dans le XML
    for secret in $(python3 -c "
    from lxml import etree
    xml_doc = etree.parse('config.xml')
    env = xml_doc.xpath('//environment[name=\"prod\"]')[0]
    for s in env.xpath('.//secret'):
        print(s.xpath('name/text()')[0])
    "); do
      VALUE=$(aws secretsmanager get-secret-value \
        --secret-id prod/$secret \
        --query SecretString \
        --output text)
      kubectl create secret generic $secret \
        --from-literal=value="$VALUE" \
        --dry-run=client -o yaml | kubectl apply -f -
    done
```

## Déploiement Docker Compose

### Local

```bash
# Générer le fichier
python3 -c "
from lxml import etree
xml_doc = etree.parse('config.xml')
xslt_doc = etree.parse('xslt/docker-compose.xslt')
transformer = etree.XSLT(xslt_doc)
result = transformer(xml_doc, environment='dev')
with open('docker-compose.yaml', 'w') as f:
    f.write(str(result))
"

# Déployer
docker-compose up -d

# Vérifier
docker-compose ps
```

### Serveur distant

```bash
# Copier le fichier
scp docker-compose.yaml user@server:/path/to/app/

# Déployer via SSH
ssh user@server "cd /path/to/app && docker-compose up -d"
```

## Déploiement Kubernetes

### Prérequis

- Cluster Kubernetes configuré
- `kubectl` installé et configuré
- Accès au cluster avec les permissions nécessaires

### Déploiement manuel

```bash
# Générer les manifests
python3 -c "
from lxml import etree
xml_doc = etree.parse('config.xml')
xslt_doc = etree.parse('xslt/kubernetes.xslt')
transformer = etree.XSLT(xslt_doc)
result = transformer(xml_doc, environment='prod')
with open('k8s.yaml', 'w') as f:
    f.write(str(result))
"

# Appliquer les configurations
kubectl apply -f k8s.yaml

# Vérifier le déploiement
kubectl get deployments
kubectl get services
kubectl get pods
```

### Déploiement avec Helm (optionnel)

Pour des configurations plus complexes, vous pouvez utiliser Helm :

```bash
# Créer un chart Helm
helm create my-app

# Générer les valeurs depuis le XML
python3 generate-helm-values.py config.xml prod > my-app/values-prod.yaml

# Déployer avec Helm
helm install my-app ./my-app -f my-app/values-prod.yaml
```

## Validation dans le pipeline

### Validation XML

```bash
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
print('Validation réussie')
"
```

### Validation Docker Compose

```bash
docker-compose -f docker-compose.yaml config
```

### Validation Kubernetes

```bash
kubectl --dry-run=client -f kubernetes.yaml apply
```

## Bonnes pratiques

1. **Validation préalable** : Toujours valider le XML avant le déploiement
2. **Environnements séparés** : Utilisez des environnements distincts pour dev, staging et prod
3. **Secrets** : Ne jamais commiter de secrets dans le dépôt
4. **Tests** : Testez les configurations sur l'environnement de dev avant la prod
5. **Rollback** : Prévoyez un plan de rollback en cas d'échec
6. **Monitoring** : Surveillez les déploiements et la santé des services
7. **Documentation** : Documentez les changements de configuration

## Dépannage

### Erreurs de validation XML

- Vérifiez la syntaxe XML
- Consultez les erreurs détaillées dans les logs
- Validez contre le schéma XSD manuellement

### Erreurs de déploiement

- Vérifiez les logs Kubernetes : `kubectl logs <pod-name>`
- Vérifiez les événements : `kubectl get events`
- Validez les manifests générés : `kubectl --dry-run=client apply -f k8s.yaml`

### Problèmes de secrets

- Vérifiez que les secrets sont créés : `kubectl get secrets`
- Vérifiez les permissions d'accès aux gestionnaires de secrets
- Vérifiez que les références dans les manifests sont correctes
