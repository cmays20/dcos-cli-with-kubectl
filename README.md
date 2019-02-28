# DC/OS CLI with Kubectl and Helm
## Running the Image - Lab Perspective
### Manual Setup
Run the image in the following way to get a command line with DC/OS, Kubectl and Helm preinstalled. This should be used to have the student go through the entire lab manually.
```
docker run -e APPNAME=training -e CLUSTER=<Assigned Cluster> -e PUBLICIP=<Public EC2 IP> \
  -it cmays/dcos-cli-with-kubectl-helm:latest
```
### Full Setup - Installs Cluster
Run the image with the following command to run all the cluster installation steps automatically.
```
docker run -e APPNAME=training -e CLUSTER=<Assigned Cluster> -e PUBLICIP=<Public EC2 IP> \
  -e FULL_SETUP=true -e DCOS_URL=<DC/OS URL> -e DCOS_USER=<username> -e DCOS_PASSWORD=<password> \
  -it cmays/dcos-cli-with-kubectl-helm:latest
```
### proxy - kubectl proxy Setup
Creates a proxy on the users machine. A token for authentication gets outputted to the stdout before the proxy comes up.
```
docker run -e APPNAME=training -e CLUSTER=<Assigned Cluster> -e PUBLICIP=<Public EC2 IP> \
  -e DCOS_URL=<DC/OS URL> -e DCOS_USER=<username> -e DCOS_PASSWORD=<password> \
  -it cmays/dcos-cli-with-kubectl-helm:latest proxy
```
Connect to the proxy with the following command and use the token to login:
```
http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```
## Running the Image - SE Perspective
The following methods of running the container are for the Sales Engineers.
### se-setup - MKE & EdgeLB installation
Run the image with the following command to install MKE and setup EdgeLB for the number of clusters specified
```
docker run -e APPNAME=training -e NUM_CLUSTERS=<Num Clusters> -e DCOS_URL=<DC/OS URL> \
  -e DCOS_USER=<username> -e DCOS_PASSWORD=<password> -it \
  cmays/dcos-cli-with-kubectl-helm:latest se-setup
```
### se-bash - Enterprise and Kubernetes CLIs preinstalled
Run the image with the following command to get a bash session with the DC/OS Enterprise and Kubernetes CLIs preinstalled
```
docker run -e APPNAME=training -e NUM_CLUSTERS=<Num Clusters> -e DCOS_URL=<DC/OS URL> \
  -e DCOS_USER=<username> -e DCOS_PASSWORD=<password> -it \
  cmays/dcos-cli-with-kubectl-helm:latest se-bash
```
## Logging into a DC/OS cluster
The below URL should be an HTTPS address:
```
dcos cluster setup <URL to DC/OS Cluster>
```
## Adding additional CLIs
Install the enterprise DC/OS CLI with the following:
```
dcos package install --yes --cli dcos-enterprise-cli
```
Install the kubernetes CLI with the following:
```
dcos package install kubernetes --cli --yes
```
Install the Edge LB CLI with the following (This can only be run if edgelb has already been installed in the clusters catalog):
```
dcos package install edgelb --cli --yes
```
