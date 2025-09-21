# demo-crossplane

## Documentation Crossplane
[Get started](https://docs.crossplane.io/latest/get-started/install/)
[Provider AWS Contrib](https://marketplace.upbound.io/providers/crossplane-contrib/provider-aws/v0.54.2)

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

- Create a S3 Bucket and check
```
kubectl apply -f kustomize/myapp/bucket.yaml
export AWS_PROFILE=localstack
aws s3 ls
aws s3api get-bucket-versioning --bucket my-bucket
aws s3api put-bucket-versioning --bucket my-bucket --versioning-configuration 'Status=Suspended'

aws s3api get-bucket-tagging --bucket my-bucket | jq
aws s3api put-bucket-tagging --bucket my-bucket --tagging "TagSet=[{Key='Owner',Value='Tremplin BDX'}]"

```
- Create SQS Queues and check
```
kubectl apply -f kustomize/myapp/queues.yaml
aws sqs list-queues --profile localstack --region us-east-1
```

## Uninstall
- Delete App resources
```
 kubectl delete -f kustomize/myapp
```
- Delete provider AWS
```
 kubectl delete -f kustomize/crossplane
```
- Delete Core Crossplane
```
helm uninstall -n crossplane-system crossplane
kubectl delete namespace crossplane-system
kubectl get crds -oname | grep 'crossplane.io' | xargs kubectl delete
```