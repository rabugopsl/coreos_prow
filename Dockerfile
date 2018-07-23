FROM roffe/kubectl

WORKDIR /root

ARG KUBE_CONFIG=./kube/kube_config
ARG NAMESPACE=default

ENV NAMESPACE=$NAMESPACE

# --------- MINIKUBE USE ONLY ---------
RUN mkdir .minikube
COPY ./kube/minikube ./.minikube
# --------- MINIKUBE USE ONLY ---------

COPY ./setup_prow.sh .

RUN mkdir ./.kube && mkdir ./prow
COPY $KUBE_CONFIG /root/.kube/config
COPY ./prow ./prow  

#ENTRYPOINT cat ./.kube/config services.txt server.txt
ENTRYPOINT sh
