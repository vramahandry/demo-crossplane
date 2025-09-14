#!/bin/bash

echo "Delete myapp (bucket s3/ queues)"
kubectl delete -f kustomize/myapp
sleep 30
echo "Delete provider AWS"

kubectl delete -f kustomize/crossplane
sleep 30
echo "Delete Core Crossplane"

helm uninstall -n crossplane-system crossplane
kubectl delete namespace crossplane-system

sleep 30
kubectl get crds -oname | grep 'crossplane.io' | xargs kubectl delete

#kind delete cluster demo