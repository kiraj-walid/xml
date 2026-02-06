# Guide du format XML

Ce guide décrit la structure XML utilisée pour définir les configurations DevOps multi-environnements.

## Structure générale

Le fichier XML suit cette structure de base :

```xml
<?xml version="1.0" encoding="UTF-8"?>
<devops-config version="1.0">
    <application>
        <!-- Informations sur l'application -->
    </application>
    <environments>
        <!-- Définitions des environnements -->
    </environments>
</devops-config>
```

## Élément racine : `devops-config`

L'élément racine contient l'attribut `version` qui indique la version du schéma utilisé.

### Attributs
- `version` (obligatoire) : Version du schéma XML (ex: "1.0")

## Section `application`

Décrit les informations générales de l'application.

```xml
<application>
    <name>my-web-app</name>
    <version>1.0.0</version>
    <description>Description de l'application</description>
</application>
```

### Éléments
- `name` (obligatoire) : Nom de l'application
- `version` (obligatoire) : Version de l'application
- `description` (optionnel) : Description de l'application

## Section `environments`

Contient les définitions des différents environnements (dev, staging, prod, etc.).

### Élément `environment`

Chaque environnement contient :
- Un nom unique
- Des services (conteneurs)
- Des variables d'environnement globales
- Des secrets
- Des configurations Kubernetes spécifiques

```xml
<environment>
    <name>dev</name>
    <services>
        <!-- Services définis ci-dessous -->
    </services>
    <variables>
        <!-- Variables globales -->
    </variables>
    <secrets>
        <!-- Secrets -->
    </secrets>
    <kubernetes>
        <!-- Configurations Kubernetes -->
    </kubernetes>
</environment>
```

## Section `services`

Définit les conteneurs/services de l'application.

### Élément `service`

Chaque service représente un conteneur Docker.

```xml
<service>
    <name>web</name>
    <image>nginx</image>
    <tag>alpine</tag>
    <ports>
        <!-- Ports exposés -->
    </ports>
    <volumes>
        <!-- Volumes montés -->
    </volumes>
    <environment>
        <!-- Variables d'environnement spécifiques -->
    </environment>
    <depends_on>
        <!-- Dépendances -->
    </depends_on>
    <command>python app.py</command>
    <working_dir>/app</working_dir>
    <replicas>3</replicas>
</service>
```

#### Éléments du service

- `name` (obligatoire) : Nom du service
- `image` (obligatoire) : Image Docker à utiliser
- `tag` (optionnel) : Tag de l'image (défaut: "latest")
- `ports` (optionnel) : Ports à exposer
- `volumes` (optionnel) : Volumes à monter
- `environment` (optionnel) : Variables d'environnement spécifiques au service
- `depends_on` (optionnel) : Services dont ce service dépend
- `command` (optionnel) : Commande à exécuter dans le conteneur
- `working_dir` (optionnel) : Répertoire de travail
- `replicas` (optionnel) : Nombre de répliques (pour Kubernetes)

### Ports

```xml
<ports>
    <port>
        <host>8080</host>
        <container>80</container>
        <protocol>tcp</protocol>
    </port>
</ports>
```

- `host` : Port sur l'hôte
- `container` : Port dans le conteneur
- `protocol` (optionnel) : Protocole (défaut: "tcp")

### Volumes

```xml
<volumes>
    <volume>
        <host_path>./data</host_path>
        <container_path>/var/lib/data</container_path>
        <mode>rw</mode>
    </volume>
</volumes>
```

- `host_path` : Chemin sur l'hôte
- `container_path` : Chemin dans le conteneur
- `mode` (optionnel) : Mode de montage (rw, ro) (défaut: "rw")

### Variables d'environnement

```xml
<environment>
    <variable>
        <name>DATABASE_URL</name>
        <value>postgresql://user:pass@db:5432/mydb</value>
    </variable>
</environment>
```

- `name` : Nom de la variable
- `value` : Valeur de la variable

### Dépendances

```xml
<depends_on>
    <service>db</service>
    <service>redis</service>
</depends_on>
```

Liste les noms des services dont ce service dépend.

## Variables globales

Variables d'environnement partagées par tous les services d'un environnement.

```xml
<variables>
    <variable>
        <name>LOG_LEVEL</name>
        <value>DEBUG</value>
    </variable>
</variables>
```

## Secrets

Définit les secrets à charger depuis des gestionnaires externes.

```xml
<secrets>
    <secret>
        <name>DATABASE_PASSWORD</name>
        <source>AWS_SECRETS_MANAGER</source>
        <key>prod/db/password</key>
    </secret>
</secrets>
```

- `name` : Nom du secret
- `source` : Source du secret (AWS_SECRETS_MANAGER, VAULT, etc.)
- `key` (optionnel) : Clé dans le gestionnaire de secrets

## Configuration Kubernetes

Configurations spécifiques pour Kubernetes.

```xml
<kubernetes>
    <namespace>production</namespace>
    <resources>
        <requests>
            <cpu>500m</cpu>
            <memory>512Mi</memory>
        </requests>
        <limits>
            <cpu>2000m</cpu>
            <memory>2Gi</memory>
        </limits>
    </resources>
    <service>
        <type>LoadBalancer</type>
        <ports>
            <port>
                <port>80</port>
                <target_port>80</target_port>
                <protocol>TCP</protocol>
            </port>
        </ports>
    </service>
</kubernetes>
```

### Éléments Kubernetes

- `namespace` (optionnel) : Namespace Kubernetes
- `resources` (optionnel) : Limites de ressources
  - `requests` : Ressources demandées
  - `limits` : Ressources maximales
  - `cpu` : CPU (ex: "500m", "1")
  - `memory` : Mémoire (ex: "512Mi", "2Gi")
- `service` (optionnel) : Configuration du service Kubernetes
  - `type` : Type de service (ClusterIP, NodePort, LoadBalancer)
  - `ports` : Ports du service

## Exemple complet

Voir le fichier `examples/sample-config.xml` pour un exemple complet avec plusieurs environnements et services.

## Validation

Le fichier XML doit être validé contre le schéma XSD (`schemas/config.xsd`). L'interface web effectue cette validation automatiquement.

## Bonnes pratiques

1. **Nommage** : Utilisez des noms de services descriptifs et cohérents
2. **Environnements** : Définissez des environnements séparés pour dev, staging et prod
3. **Secrets** : Ne jamais mettre de valeurs de secrets en clair dans le XML
4. **Variables** : Utilisez des variables d'environnement pour les valeurs configurables
5. **Documentation** : Ajoutez des descriptions pour clarifier l'utilisation de chaque service
