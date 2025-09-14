#!/bin/bash
echo "######## Deploy Kind K8S cluster #######"


kind create cluster --config kind/kind-config.yaml --image kindest/node:v1.31.6


echo "###### Install Localstack using Helm #####"


helm repo add localstack-charts https://localstack.github.io/helm-charts
helm dependency update  ./helm/localstack
helm upgrade localstack -n localstack --install ./helm/localstack --create-namespace




echo "###### Install Crossplane core using Helm #####"


helm repo add crossplane-stable https://charts.crossplane.io/stable
helm dependency update  ./helm/crossplane
helm upgrade crossplane -n crossplane-system --install ./helm/crossplane --create-namespace -f ./helm/crossplane/values.yaml

echo "######## Install Crossplane Provider AWS ######"
kubectl apply -f kustomize/crossplane/provider-aws.yaml

sleep 20

echo "###### Port forward to access AWS API (localstack)#####"
kubectl port-forward -n localstack svc/localstack 4566:4566








