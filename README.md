# demo-crossplane

## Prerequesities

- Docker
- Kind
- Kubectl
- Helm
- awscli v2

## Deploy Kind K8S cluster

```
kind create cluster --config kind/kind-config.yaml --image kindest/node:v1.31.6
```

## Install Localstack using Helm

```
helm repo add localstack-charts https://localstack.github.io/helm-charts
helm dependency update  ./helm/localstack
helm upgrade localstack -n localstack --install ./helm/localstack --create-namespace
```
## Interact with Localstack with awscli

- Add in you ~/.aws/config

```
[profile localstack]
region=eu-central-1
output=json
endpoint_url = http://localhost:4566
```
- Add in your ~/.aws/credentials

```
[localstack]
aws_access_key_id=test
aws_secret_access_key=test
```
- Port forward the service localstack to localhost
```
kubectl port-forward -n localstack svc/localstack 4566:4566
```
- Create a S3 bucket
```
aws s3 ls --profile localstack
aws s3 mb s3://test --profile localstack
aws s3 ls --profile localstack
```

## Install Crossplane using Helm

```
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm dependency update  ./helm/crossplane
helm upgrade crossplane -n crossplane-system --install ./helm/crossplane --create-namespace

```

## Install Crossplane Provider AWS and configure localstack

- Install Crossplane Provider AWS 
```
kubectl apply -f kustomize/crossplane/provider-aws.yaml
```
- Install ProviderConfig
```
kubectl apply -f kustomize/myapp/provider-config.yaml
```
## Create S3 bucket / SQS queues with Crossplane

- Create a S3 Bucket
```
kubectl apply -f kustomize/myapp/bucket.yaml
```
- Create SQS Queues
```
kubectl apply -f kustomize/myapp/queues.yaml
```

