
kubectl create configmap plugins --from-file=plugins=./kubectl/plugins.yaml --namespace="${NAMESPACE}" --dry-run -o yaml | kubectl replace configmap plugins --namespace=$NAMESPACE -f -

# -- BUILD the image to connect to remote KUBERNETES
NAMESPACE=mynamespace
docker image build -t coreos_prow \
  --build-arg NAMESPACE=mynamespace .

# -- RUN image to connect to remote KUBERNETES
docker container run -it \
  --name coreos_prow02 -v $(pwd)/kube_remote/:/root/.kube \
  -v $(pwd)/prow/:/root/prow coreos_prow

# -- Publish hook and deck load balancers
kubectl expose service hook --port=9090 --target-port=8888 --name=hooklb --type=LoadBalancer --namespace=$NAMESPACE
kubectl expose service deck --port=9090 --target-port=8080 --name=decklb --type=LoadBalancer --namespace=$NAMESPACE

# -- Create roles required roles
kubectl create clusterrolebinding cluster-admin-binding-"system:serviceaccount:${NAMESPACE}:plank" --clusterrole=cluster-admin --user="system:serviceaccount:${NAMESPACE}:plank"
kubectl create clusterrolebinding cluster-admin-binding-"system:serviceaccount:${NAMESPACE}:deck" --clusterrole=cluster-admin --user="system:serviceaccount:${NAMESPACE}:deck"
kubectl create clusterrolebinding cluster-admin-binding-"system:serviceaccount:${NAMESPACE}:horologium" --clusterrole=cluster-admin
 --user="system:serviceaccount:${NAMESPACE}:horologium"

# -- Update Config Maps
kubectl create configmap config --from-file=config.yaml=./prow/config.yaml --namespace=$NAMESPACE --dry-run -o yaml | kubectl replace configmap config --namespace=$NAMESPACE -f -
kubectl create configmap plugins --from-file=plugins.yaml=./prow/plugins.yaml --namespace=$NAMESPACE --dry-run -o yaml | kubectl replace configmap plugins --namespace=$NAMESPACE -f -
