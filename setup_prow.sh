#!/bin/sh

# -- CREATE NAMESPACE
kubectl create namespace "${NAMESPACE}" || echo $NAMESPACE > namespace

# -- CREATE SECRETS
kubectl create secret generic hmac-token --from-file=hmac=/root/prow/hmac_token --namespace="${NAMESPACE}"
kubectl create secret generic oauth-token --from-file=oauth=/root/prow/oauth_token --namespace="${NAMESPACE}"

# -- CREATE PROW DEPLOYMENT
kubectl apply -f /root/prow/starter.yaml --namespace="${NAMESPACE}"

# -- CREATE SERVICE ACCOUNTS
kubectl create clusterrolebinding cluster-admin-binding-"system:serviceaccount:${NAMESPACE}:plank" --clusterrole=cluster-admin --user="system:serviceaccount:${NAMESPACE}:plank"
kubectl create clusterrolebinding cluster-admin-binding-"system:serviceaccount:${NAMESPACE}:deck" --clusterrole=cluster-admin --user="system:serviceaccount:${NAMESPACE}:deck"

# -- CREATE PLUGINS
kubectl create configmap plugins --from-file=plugins.yaml=/root/prow/plugins.yaml --namespace="${NAMESPACE}" \
    --dry-run -o yaml | kubectl apply -f -

# -- STORE SERVICES AND SERVER REFERENCES
kubectl get services --namespace="${NAMESPACE}" > /root/services
grep 'server' < ./.kube/config | awk '{print $2}' > /root/server
