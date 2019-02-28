#!/bin/sh
set -e
export KUBE_VERSION=2.1.1-1.12.5

function pre_check_env_vars {
  if [ -z "$APPNAME" ]; then
    echo "An APPNAME environment variable is expected (ex. APPNAME=training)"
    exit 1
  fi

  if [ -z "$CLUSTER" ]; then
    echo "An CLUSTER environment variable is expected (ex. CLUSTER=01, CLUSTER=21)"
    exit 1
  fi

  if [ -z "$PUBLICIP" ]; then
    echo "A PUBLICIP environment variable is expected (ex. PUBLICIP=<IP of Public LB>)"
    exit 1
  fi
}

function pre_check_dcos_env_vars {
  if [ -z "$DCOS_URL" ]; then
    echo "When doing a full setup, a DCOS_URL environment variable is needed (ex. DCOS_URL=https://someUrl)"
    exit 1
  fi

  if [ -z "$DCOS_USER" ]; then
    echo "When doing a full setup, a DCOS_USER environment variable is needed (ex. DCOS_USER=<some user>)"
    exit 1
  fi

  if [ -z "$DCOS_PASSWORD" ]; then
    echo "When doing a full setup, a DCOS_PASSWORD environment variable is needed (ex. DCOS_PASSWORD=<some password>)"
    exit 1
  fi
}

function pre_check_se_env_vars {
  if [ -z "$APPNAME" ]; then
    echo "An APPNAME environment variable is expected (ex. APPNAME=training)"
    exit 1
  fi

  if [ -z "$NUM_CLUSTERS" ]; then
    echo "When doing a DC/OS SE setup, a NUM_CLUSTERS environment variable is needed (ex. NUM_CLUSTERS=3)"
    exit 1
  fi
}

function dcos_connect_install_clis {
  echo "$PUBLICIP ${APPNAME}.prod.k8s.cluster${CLUSTER}.mesos.lab" >> /etc/hosts
  dcos cluster setup --insecure --username $DCOS_USER --password $DCOS_PASSWORD $DCOS_URL
  dcos package install --yes --cli dcos-enterprise-cli
  dcos package install kubernetes --yes --cli
}

function kubectl_setup {
  dcos kubernetes cluster kubeconfig --context-name=${APPNAME}-prod-k8s-cluster${CLUSTER} --cluster-name=${APPNAME}/prod/k8s/cluster${CLUSTER} \
    --apiserver-url https://${APPNAME}.prod.k8s.cluster${CLUSTER}.mesos.lab:8443 \
    --insecure-skip-tls-verify
}

if [ "$1" = "proxy" -o "$1" = "kubectl" ]; then
  echo "Starting proxy setup"

  pre_check_env_vars
  pre_check_dcos_env_vars
  cd /opt/dcos

  dcos_connect_install_clis
  kubectl_setup
  if [ "$1" = "proxy" ]; then
    cat ~/.kube/config | grep token
    kubectl proxy --address="0.0.0.0" --disable-filter=true
  else
    exec "bash"
  fi
fi

if [ "$1" = "se-setup" -o "$1" = "se-bash" ]; then
  echo "Setting up cluster"
  pre_check_dcos_env_vars
  pre_check_se_env_vars
  cd /opt/dcos
  dcos_connect_install_clis

  if [ "$1" = "se-setup" ]; then
    ./deploy-kubernetes-mke.sh
    ./check-kubernetes-mke-status.sh
    ./create-pool-edgelb-all.sh ${NUM_CLUSTERS}
    ./deploy-edgelb.sh
    ./check-app-status.sh infra/network/dcos-edgelb/pools/all
  fi
  exec "bash"
fi

if [ -z "$1" ]; then
  pre_check_env_vars
  cd /opt/dcos

  sed "s/TOBEREPLACED/${CLUSTER}/g" options-kubernetes-cluster.json.template > options-kubernetes-cluster${CLUSTER}.json

  if [ "$FULL_SETUP" = "true" ] || [ "$FULL_SETUP" = "TRUE" ]; then
    pre_check_dcos_env_vars
    dcos_connect_install_clis
    ./deploy-kubernetes-cluster.sh
    ./check-kubernetes-cluster-status.sh
    kubectl_setup

    exec "bash"
  fi
else
  exec "$@"
fi
