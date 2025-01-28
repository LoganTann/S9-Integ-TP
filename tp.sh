#!/bin/bash
set -e
IMAGE_NAME="logantann/s9-integ-tp"
IMAGE_NAME_SED="logantann\\/s9-integ-tp"
IMAGE_VERSION="0.1"
NAMESPACE="cloud-integ-tp"

## DOCKER IMAGE BUILD
cd rentalService

# Demander à l'utilisateur s'il souhaite exécuter le bloc de code
echo "Login Docker ? (y/n)"
read reponse
if [ "$reponse" == "y" ]; then
    docker login
fi

echo "Build image ? (y/n)"
read reponse
if [ "$reponse" == "y" ]; then
    docker build -t $IMAGE_NAME:$IMAGE_VERSION .
fi


echo "Run image ? (y/n)"
read reponse
if [ "$reponse" == "y" ]; then
    docker run -p 4000:8080 -t $IMAGE_NAME:$IMAGE_VERSION || true
fi


echo "Push image ? (y/n)"
read reponse
if [ "$reponse" == "y" ]; then
    docker push $IMAGE_NAME:$IMAGE_VERSION
fi


## MINIKUBE LOCAL DEPLOYMENT
cd ..

echo "Démarrer minikube ? (y/n)"
read reponse
if [ "$reponse" == "y" ]; then
    minikube start --driver=docker
fi

echo "Créer namespace ? (y/n)"
read reponse
if [ "$reponse" == "y" ]; then
    kubectl create namespace $NAMESPACE
fi


echo "Télécharger istio ? (y/n)"
read reponse
if [ "$reponse" == "y" ]; then
    curl -L https://istio.io/downloadIstio | sh -
fi

echo "Installer istio + addons ? (y/n)"
read reponse
if [ "$reponse" == "y" ]; then
    cd istio-1.24.2
    export PATH=$PWD/bin:$PATH
    istioctl install --set profile=demo -y
    kubectl label namespace $NAMESPACE istio-injection=enabled
    kubectl apply -f samples/addons
    cd ..
fi

echo "Déployer ? (y/n)"
read reponse
if [ "$reponse" == "y" ]; then
    cat deployment.TPL.yml > deployment.gen.yml
    sed -i "s/%IMAGE%/$IMAGE_NAME_SED/g" deployment.gen.yml
    sed -i "s/%VERSION%/$IMAGE_VERSION/g" deployment.gen.yml
    sed -i "s/%NAMESPACE%/$NAMESPACE/g" deployment.gen.yml
    kubectl apply -f deployment.gen.yml -n $NAMESPACE
fi

echo "Lancer proxy (arrière plan) ? (y/n)"
read reponse
if [ "$reponse" == "y" ]; then
    minikube service rentalservice -n $NAMESPACE --url || true
fi


echo "Utiliser le docker engine de la VM minikube ? (y/n)"
read reponse
if [ "$reponse" == "y" ]; then
    minikube docker-env
    eval $(minikube -p minikube docker-env)
fi

echo "Obtenir gateway istio ? (y/n)"
read reponse
if [ "$reponse" == "y" ]; then
    kubectl -n istio-system port-forward deployment/istio-ingressgateway 31380:8080  
fi