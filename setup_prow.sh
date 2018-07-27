#!/bin/sh

# -- CREATE NAMESPACE
kubectl create namespace "${NAMESPACE}" || echo $NAMESPACE > namespace

# -- CREATE SECRETS
kubectl create secret generic hmac-token --from-file=hmac=/root/prow/hmac_token --namespace="${NAMESPACE}"
kubectl create secret generic oauth-token --from-file=oauth=/root/prow/oauth_token --namespace="${NAMESPACE}"

# -- CREATE PROW DEPLOYMENT
kubectl apply -f /root/prow/starter.yaml --namespace="${NAMESPACE}"

sleep 10

# -- CREATE SERVICE ACCOUNTS
kubectl create clusterrolebinding cluster-admin-binding-"system:serviceaccount:${NAMESPACE}:plank" --clusterrole=cluster-admin --user="system:serviceaccount:${NAMESPACE}:plank"
kubectl create clusterrolebinding cluster-admin-binding-"system:serviceaccount:${NAMESPACE}:deck" --clusterrole=cluster-admin --user="system:serviceaccount:${NAMESPACE}:deck"
kubectl create clusterrolebinding cluster-admin-binding-"system:serviceaccount:${NAMESPACE}:hook" --clusterrole=cluster-admin --user="system:serviceaccount:${NAMESPACE}:hook"
kubectl create clusterrolebinding cluster-admin-binding-"system:serviceaccount:${NAMESPACE}:horologium" --clusterrole=cluster-admin --user="system:serviceaccount:${NAMESPACE}:horologium"
kubectl create clusterrolebinding cluster-admin-binding-"system:serviceaccount:${NAMESPACE}:sinker" --clusterrole=cluster-admin --user="system:serviceaccount:${NAMESPACE}:sinker"

# -- CREATE LOAD BALANCERS
kubectl expose service hook --port=9090 --target-port=8888 --name=hooklb --type=LoadBalancer --namespace=$NAMESPACE
kubectl expose service deck --port=9090 --target-port=8080 --name=decklb --type=LoadBalancer --namespace=$NAMESPACE


# -- UPDATE CONFIG MAPS
kubectl create configmap plugins --from-file=plugins.yaml=/root/prow/plugins.yaml --namespace="${NAMESPACE}" \
    --dry-run -o yaml | kubectl replace configmap plugins --namespace=$NAMESPACE -f -
kubectl create configmap config --from-file=config.yaml=./prow/config.yaml \
   --namespace=$NAMESPACE --dry-run -o yaml \
   | kubectl replace configmap config --namespace=$NAMESPACE -f -

# -- STORE SERVICES AND SERVER REFERENCES
kubectl get services --namespace="${NAMESPACE}" > /root/services
grep 'server' < ./.kube/config | awk '{print $2}' > /root/server
