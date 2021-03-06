# !/bin/bash

set -e
docker build -t wecs/demo:$CIRCLE_SHA1 .

docker login -u="$HUB_USER" -p="$HUB_PASS" docker.io  && docker push wecs/demo:$CIRCLE_SHA1
export KOPS_STATE_STORE=$KOPS_STORE
echo $KOPS_STATE_STORE
CLUSTER_NAME=cd.k8s.local
kops export kubecfg ${CLUSTER_NAME}

export PASSWORD=`kops get secrets kube --type secret -oplaintext`

sudo kubectl --insecure-skip-tls-verify=true --username=$USERNAME --password=$PASSWORD --server $MASTER_SERVER set image deployment/${DEPLOYMENT_NAME} ${CONTAINER_NAME}=wecs/demo:$CIRCLE_SHA1

echo "✓ Successful..."