#!/bin/bash
DEMO_MAGIC_PATH='$HOME/Projects/demo-magic/demo-magic.sh'
. demo-magic.sh
# DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"
clear

#### Configure a profile to connect to AWS Provider named localstack ####
pe "cat kustomize/myapp/provider-config.yaml"
pe "kubectl apply -f kustomize/myapp/provider-config.yaml"
clear

#### Check that there is not any bucket already created ####
export AWS_PROFILE=localstack
pe "aws s3 ls"

pe "cat kustomize/myapp/bucket.yaml"
pe "kubectl apply -f kustomize/myapp/bucket.yaml"

pe "aws s3 ls"

#### Check tags on the bucket ####
pe "aws s3api get-bucket-tagging --bucket my-bucket | jq"
wait
clear
### Change tags directly through AWS API
pe "aws s3api put-bucket-tagging --bucket my-bucket --tagging \"TagSet=[{Key='Owner',Value='BDXIO'}]\""

TYPE_SPEED=45
p "for i in {1..7}
do
  echo \"#### Iteration $i ####\"
  aws s3api get-bucket-tagging --bucket my-bucket | jq
  sleep 3
done"
for i in {1..7}
do
  echo "#### Iteration $i ####"
  aws s3api get-bucket-tagging --bucket my-bucket | jq
  sleep 3
done
wait
clear
TYPE_SPEED=35

### Create a new bucket from AWS API directly and import Ressource ###

pe "aws s3 mb s3://imported"
pe "aws s3 ls"
pe "aws s3api get-bucket-tagging --bucket imported | jq"
pe "cat kustomize/myapp/bucket-import.yaml"
pe "kubectl apply -f kustomize/myapp/bucket-import.yaml"
pe "aws s3api get-bucket-tagging --bucket imported | jq"
pe "diff kustomize/myapp/bucket-import.yaml kustomize/myapp/bucket-import-full.yaml"
wait
clear
pe "kubectl apply -f kustomize/myapp/bucket-import-full.yaml"
pe "aws s3api get-bucket-tagging --bucket imported | jq"

# ## Demo down
# kubectl apply -f kustomize/myapp/bucket-import.yaml
# ##Bug on localstack need to delete tag before delete the bucket itself
# aws s3api delete-bucket-tagging --bucket imported 
# aws s3api delete-bucket --bucket imported
# kubectl delete -f kustomize/myapp/bucket-import.yaml
# kubectl delete -f kustomize/myapp/bucket.yaml
# sleep 5
# kubectl delete -f kustomize/myapp/provider-config.yaml