# Guide de Personnalisation des Transformations XSLT

Ce guide explique comment personnaliser les transformations XSLT pour adapter les fichiers générés à vos besoins spécifiques.

## Vue d'ensemble

Les transformations XSLT permettent de convertir vos configurations XML en différents formats :
- Docker Compose YAML
- Kubernetes YAML
- Helm Charts
- JSON

Tous les fichiers XSLT sont situés dans le répertoire `xslt/`.

## Structure des Transformations

### Fichiers XSLT disponibles

1. **docker-compose.xslt** - Génère des fichiers Docker Compose
2. **kubernetes.xslt** - Génère des manifests Kubernetes
3. **helm.xslt** - Génère des Helm Charts
4. **json.xslt** - Génère des fichiers JSON

### Paramètres des transformations

Toutes les transformations acceptent le paramètre `environment` :

```xml
<xsl:param name="environment" select="'dev'"/>
```

Ce paramètre permet de sélectionner l'environnement à transformer.

## Personnalisation Docker Compose

### Ajouter des réseaux personnalisés

Modifiez `docker-compose.xslt` pour ajouter des réseaux :

```xml
<xsl:template match="environment">
    <xsl:text>version: '3.8'

networks:
  custom-network:
    driver: bridge

services:
</xsl:text>
    <!-- ... reste du template ... -->
</xsl:template>
```

### Ajouter des healthchecks

Ajoutez des healthchecks dans le template des services :

```xml
<xsl:template match="service">
    <!-- ... autres éléments ... -->
    <xsl:if test="healthcheck">
        <xsl:text>    healthcheck:
      test: </xsl:text>
        <xsl:value-of select="healthcheck/test"/>
        <xsl:text>
      interval: </xsl:text>
        <xsl:value-of select="healthcheck/interval"/>
        <xsl:text>
      timeout: </xsl:text>
        <xsl:value-of select="healthcheck/timeout"/>
        <xsl:text>
</xsl:text>
    </xsl:if>
</xsl:template>
```

## Personnalisation Kubernetes

### Ajouter des annotations personnalisées

Modifiez `kubernetes.xslt` pour ajouter des annotations :

```xml
<xsl:template match="service" mode="deployment">
    <xsl:text>apiVersion: apps/v1
kind: Deployment
metadata:
  name: </xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text>
  annotations:
    deployment.kubernetes.io/revision: "1"
    custom.annotation: "value"
</xsl:text>
    <!-- ... reste du template ... -->
</xsl:template>
```

### Ajouter des liveness/readiness probes

```xml
<xsl:if test="probes/liveness">
    <xsl:text>        livenessProbe:
          httpGet:
            path: </xsl:text>
    <xsl:value-of select="probes/liveness/path"/>
    <xsl:text>
            port: </xsl:text>
    <xsl:value-of select="probes/liveness/port"/>
    <xsl:text>
          initialDelaySeconds: </xsl:text>
    <xsl:value-of select="probes/liveness/initial_delay"/>
    <xsl:text>
</xsl:text>
</xsl:if>
```

### Ajouter des node selectors

```xml
<xsl:if test="node_selector">
    <xsl:text>      nodeSelector:
</xsl:text>
    <xsl:for-each select="node_selector/label">
        <xsl:text>        </xsl:text>
        <xsl:value-of select="@key"/>
        <xsl:text>: </xsl:text>
        <xsl:value-of select="@value"/>
        <xsl:text>
</xsl:text>
    </xsl:for-each>
</xsl:if>
```

## Personnalisation Helm

### Modifier les valeurs par défaut

Éditez la section `values.yaml` dans `helm.xslt` :

```xml
<xsl:text>replicaCount: </xsl:text>
<xsl:choose>
    <xsl:when test="services/service/replicas">
        <xsl:value-of select="services/service/replicas"/>
    </xsl:when>
    <xsl:otherwise>1</xsl:otherwise>
</xsl:choose>
```

### Ajouter des templates personnalisés

Créez de nouveaux templates dans `helm.xslt` :

```xml
<xsl:text>
---
# templates/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: </xsl:text>
<xsl:value-of select="$app-name"/>
<xsl:text>
spec:
  rules:
    - host: </xsl:text>
<xsl:value-of select="$app-name"/>
<xsl:text>.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: </xsl:text>
<xsl:value-of select="$app-name"/>
<xsl:text>
                port:
                  number: 80
</xsl:text>
```

## Créer une Transformation Personnalisée

### Exemple : Transformation vers Terraform

Créez un nouveau fichier `xslt/terraform.xslt` :

```xml
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:param name="environment" select="'dev'"/>
    
    <xsl:template match="/">
        <xsl:text># Terraform configuration generated from XML
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

</xsl:text>
        <xsl:apply-templates select="devops-config/environments/environment[name=$environment]/services/service"/>
    </xsl:template>
    
    <xsl:template match="service">
        <xsl:text>resource "docker_container" "</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>" {
  name  = "</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>"
  image = docker_image.</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>.image_id
</xsl:text>
        <!-- Ajouter d'autres propriétés -->
        <xsl:text>}

resource "docker_image" "</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>" {
  name = "</xsl:text>
        <xsl:value-of select="image"/>
        <xsl:if test="tag">
            <xsl:text>:</xsl:text>
            <xsl:value-of select="tag"/>
        </xsl:if>
        <xsl:text>"
}
</xsl:text>
    </xsl:template>
</xsl:stylesheet>
```

### Enregistrer la nouvelle transformation

Ajoutez un endpoint dans `app.py` :

```python
TERRAFORM_XSLT = os.path.join(os.path.dirname(__file__), 'xslt', 'terraform.xslt')

@app.route('/api/transform/terraform', methods=['POST'])
def transform_terraform():
    # ... code similaire aux autres transformations ...
```

## Bonnes Pratiques

### 1. Validation des données

Toujours valider les données avant de les utiliser :

```xml
<xsl:if test="ports/port">
    <!-- Traiter les ports -->
</xsl:if>
```

### 2. Valeurs par défaut

Utiliser `xsl:choose` pour les valeurs par défaut :

```xml
<xsl:choose>
    <xsl:when test="replicas">
        <xsl:value-of select="replicas"/>
    </xsl:when>
    <xsl:otherwise>1</xsl:otherwise>
</xsl:choose>
```

### 3. Échappement des caractères

Faire attention aux caractères spéciaux dans les valeurs :

```xml
<xsl:value-of select="normalize-space(command)"/>
```

### 4. Formatage de sortie

Utiliser `indent="yes"` pour un meilleur formatage :

```xml
<xsl:output method="text" encoding="UTF-8" indent="yes"/>
```

## Tests des Transformations

### Tester une transformation

```bash
# Générer un fichier de test
python scripts/generate-yaml.py examples/sample-config.xml \
    --type docker-compose \
    --environment dev \
    --output test-output.yaml

# Valider le résultat
docker-compose -f test-output.yaml config
```

### Valider la syntaxe XSLT

```bash
# Utiliser xmllint (si disponible)
xmllint --noout xslt/docker-compose.xslt
```

## Exemples Avancés

### Transformation conditionnelle

```xml
<xsl:choose>
    <xsl:when test="$environment = 'prod'">
        <!-- Configuration production -->
    </xsl:when>
    <xsl:when test="$environment = 'staging'">
        <!-- Configuration staging -->
    </xsl:when>
    <xsl:otherwise>
        <!-- Configuration développement -->
    </xsl:otherwise>
</xsl:choose>
```

### Boucles et agrégations

```xml
<xsl:for-each select="services/service">
    <xsl:sort select="name"/>
    <!-- Traiter chaque service -->
</xsl:for-each>
```

### Variables XSLT

```xml
<xsl:variable name="app-name" select="../../application/name"/>
<xsl:variable name="total-services" select="count(services/service)"/>
```

## Ressources

- [Documentation XSLT W3C](https://www.w3.org/TR/xslt/)
- [Tutoriel XSLT](https://www.w3schools.com/xml/xsl_intro.asp)
- [XPath Reference](https://www.w3.org/TR/xpath/)

## Support

Pour toute question sur la personnalisation des transformations, consultez :
- La documentation des fichiers XSLT existants
- Les exemples dans `examples/`
- Les guides dans `docs/`
