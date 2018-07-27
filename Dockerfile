FROM roffe/kubectl

WORKDIR /root

#ARG KUBE_CONFIG=./kube/kube_config
ARG NAMESPACE=default

ENV NAMESPACE=$NAMESPACE

RUN mkdir .minikube
RUN mkdir ./.kube && mkdir ./prow

# --------- MINIKUBE USE ONLY ---------
#COPY ./kube/minikube ./.minikube
# --------- MINIKUBE USE ONLY ---------

COPY ./setup_prow.sh .  
VOLUME /root/.minikube
VOLUME /root/.kube
VOLUME /root/prow
#COPY $KUBE_CONFIG /root/.kube/config
#COPY ./prow ./prow  

ENTRYPOINT sh
