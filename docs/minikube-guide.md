# Guide de Test avec Minikube

Ce guide explique comment tester les configurations Kubernetes générées avec Minikube, un outil qui permet d'exécuter Kubernetes localement.

## Prérequis

- Minikube installé ([Installation](https://minikube.sigs.k8s.io/docs/start/))
- kubectl installé
- Docker ou un autre driver de virtualisation

## Installation de Minikube

### Windows

```powershell
# Télécharger Minikube
choco install minikube
# Ou télécharger depuis: https://minikube.sigs.k8s.io/docs/start/
```

### Linux

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### macOS

```bash
brew install minikube
```

## Démarrage de Minikube

```bash
# Démarrer Minikube
minikube start

# Vérifier le statut
minikube status

# Configurer kubectl pour utiliser Minikube
kubectl config use-context minikube
```

## Génération et Test des Configurations

### 1. Générer les fichiers Kubernetes

```bash
# Générer depuis votre configuration XML
python scripts/generate-yaml.py examples/sample-config.xml \
    --type kubernetes \
    --environment dev \
    --output k8s-dev.yaml
```

### 2. Valider les manifests

```bash
# Valider avec kubectl (dry-run)
kubectl apply -f k8s-dev.yaml --dry-run=client

# Valider avec plus de détails
kubectl apply -f k8s-dev.yaml --dry-run=client -o yaml
```

### 3. Déployer sur Minikube

```bash
# Appliquer les configurations
kubectl apply -f k8s-dev.yaml

# Vérifier les déploiements
kubectl get deployments
kubectl get services
kubectl get pods

# Voir les logs
kubectl logs -l app=my-web-app

# Décrire un déploiement
kubectl describe deployment my-web-app-dev
```

### 4. Accéder aux services

```bash
# Obtenir l'URL du service
minikube service my-web-app-service-dev --url

# Ouvrir dans le navigateur
minikube service my-web-app-service-dev
```

### 5. Tester avec port-forward

```bash
# Forwarder un port local vers un pod
kubectl port-forward deployment/my-web-app-dev 8080:80

# Accéder via http://localhost:8080
```

## Exemple Complet

### Script de test automatisé

Créez un fichier `test-minikube.sh`:

```bash
#!/bin/bash

echo "🚀 Test de déploiement sur Minikube"

# Vérifier que Minikube est démarré
if ! minikube status > /dev/null 2>&1; then
    echo "Démarrage de Minikube..."
    minikube start
fi

# Générer les fichiers Kubernetes
echo "📝 Génération des fichiers Kubernetes..."
python scripts/generate-yaml.py examples/sample-config.xml \
    --type kubernetes \
    --environment dev \
    --output k8s-dev.yaml

# Valider
echo "✓ Validation des manifests..."
kubectl apply -f k8s-dev.yaml --dry-run=client

# Déployer
echo "🚀 Déploiement sur Minikube..."
kubectl apply -f k8s-dev.yaml

# Attendre que les pods soient prêts
echo "⏳ Attente du déploiement..."
kubectl wait --for=condition=available --timeout=300s deployment/my-web-app-dev

# Vérifier le statut
echo "📊 Statut du déploiement:"
kubectl get all -l app=my-web-app

# Obtenir l'URL du service
echo "🌐 URL du service:"
minikube service my-web-app-service-dev --url

echo "✅ Test terminé!"
```

### Exécuter le script

```bash
chmod +x test-minikube.sh
./test-minikube.sh
```

## Gestion des Secrets

### Créer des secrets manuellement

```bash
# Créer un secret depuis un fichier
kubectl create secret generic app-secrets \
    --from-literal=db-password=mysecretpassword

# Créer depuis un fichier
kubectl create secret generic app-secrets \
    --from-file=password=./password.txt
```

### Utiliser les secrets dans les déploiements

Les secrets définis dans votre XML seront référencés dans les manifests générés. Assurez-vous de créer les secrets avant de déployer:

```bash
# Créer les secrets nécessaires
kubectl create secret generic my-app-secrets-dev \
    --from-literal=DATABASE_PASSWORD=devpassword \
    --from-literal=API_KEY=devkey

# Déployer
kubectl apply -f k8s-dev.yaml
```

## Monitoring et Debugging

### Voir les événements

```bash
kubectl get events --sort-by='.lastTimestamp'
```

### Voir les logs

```bash
# Logs d'un pod spécifique
kubectl logs <pod-name>

# Logs de tous les pods d'une application
kubectl logs -l app=my-web-app

# Logs en temps réel
kubectl logs -f <pod-name>
```

### Décrire les ressources

```bash
# Décrire un déploiement
kubectl describe deployment my-web-app-dev

# Décrire un service
kubectl describe service my-web-app-service-dev

# Décrire un pod
kubectl describe pod <pod-name>
```

### Accéder à un pod

```bash
# Exécuter une commande dans un pod
kubectl exec -it <pod-name> -- /bin/sh

# Exécuter une commande spécifique
kubectl exec <pod-name> -- env
```

## Nettoyage

### Supprimer les ressources

```bash
# Supprimer toutes les ressources d'un fichier
kubectl delete -f k8s-dev.yaml

# Supprimer par label
kubectl delete all -l app=my-web-app

# Supprimer les secrets
kubectl delete secret my-app-secrets-dev
```

### Arrêter Minikube

```bash
# Arrêter Minikube
minikube stop

# Supprimer le cluster
minikube delete
```

## Intégration dans les Tests CI/CD

### GitHub Actions

Ajoutez cette étape dans votre workflow:

```yaml
- name: Test with Minikube
  run: |
    minikube start --driver=docker
    kubectl apply -f generated/kubernetes-dev.yaml --dry-run=client
    kubectl apply -f generated/kubernetes-dev.yaml
    kubectl wait --for=condition=available --timeout=300s deployment/my-app-dev
    kubectl get all
```

### Jenkins

```groovy
stage('Test Minikube') {
    steps {
        sh '''
            minikube start --driver=docker
            kubectl apply -f kubernetes.yaml --dry-run=client
            kubectl apply -f kubernetes.yaml
            kubectl wait --for=condition=available --timeout=300s deployment/my-app-dev
        '''
    }
}
```

## Dépannage

### Problèmes courants

1. **Minikube ne démarre pas**
   ```bash
   minikube delete
   minikube start --driver=docker
   ```

2. **Pods en état CrashLoopBackOff**
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

3. **Services non accessibles**
   ```bash
   kubectl get svc
   minikube service <service-name>
   ```

4. **Problèmes de ressources**
   ```bash
   minikube start --memory=4096 --cpus=2
   ```

## Ressources

- [Documentation Minikube](https://minikube.sigs.k8s.io/docs/)
- [Guide kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [Kubernetes Tutorials](https://kubernetes.io/docs/tutorials/)
