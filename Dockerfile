FROM centos:centos7

ENV LC_ALL=en_US.utf-8
ENV LANG=en_US.utf-8

ADD kubernetes.repo /etc/yum.repos.d/kubernetes.repo
ADD *.sh *.json options-kubernetes-cluster.json.template /opt/dcos/

RUN [ -d usr/local/bin ] || mkdir -p /usr/local/bin && \
    curl https://downloads.dcos.io/binaries/cli/linux/x86-64/dcos-1.12/dcos -o dcos && \
    mv dcos /usr/local/bin && \
    chmod +x /usr/local/bin/dcos && \
    yum -y install https://centos7.iuscommunity.org/ius-release.rpm && \
    yum install -y kubectl wget python36u jq && \
    wget https://storage.googleapis.com/kubernetes-helm/helm-v2.12.3-linux-amd64.tar.gz && \
    tar -zxvf helm-v2.12.3-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf helm-v2.12.3-linux-amd64.tar.gz linux-amd64 && \
    yum clean all && \
    chmod 744 /opt/dcos/*.sh

ENTRYPOINT ["/opt/dcos/init.sh"]
