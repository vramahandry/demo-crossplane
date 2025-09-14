#!/bin/bash

#Demo up
set -x
echo "#### Configure a profile to connect to AWS Provider named localstack ####"
kubectl apply -f kustomize/myapp/provider-config.yaml

echo "#### Check that there is not any bucket already created ####"
export AWS_PROFILE=localstack
aws s3 ls

echo "#### Create a S3 bucket and check that is exist####"
kubectl apply -f kustomize/myapp/bucket.yaml
sleep 5
aws s3 ls

echo "#### Check tags on the bucket ####"
aws s3api get-bucket-tagging --bucket my-bucket | jq

echo "### Change tags directly through AWS API"
aws s3api put-bucket-tagging --bucket my-bucket --tagging "TagSet=[{Key='Owner',Value='Tremplin BDX'}]"
 
for i in {1..7}
do
  echo "#### Iteration $i ####"
  aws s3api get-bucket-tagging --bucket my-bucket | jq
  sleep 5
done

echo "### Create a new bucket from AWS API directly and import Ressource ###"
aws s3 mb s3://imported
aws s3 ls
aws s3api get-bucket-tagging --bucket imported | jq
kubectl apply -f kustomize/myapp/bucket-import.yaml

set +x

## Demo down
kubectl delete -f kustomize/myapp/bucket-import.yaml
kubectl delete -f kustomize/myapp/bucket.yaml
sleep 5
kubectl delete -f kustomize/myapp/provider-config.yaml