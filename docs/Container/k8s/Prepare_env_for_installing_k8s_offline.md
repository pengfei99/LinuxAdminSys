# Prepare environment for installing k8s offline

We need to prepare three things before we are able to install k8s offline
- A system packages repo which provides below packages (e.g. kubeadm, containerd, crictl, runc, etc. )
- A container image repo which provides container images (e.g. kube-apiserver, kube-proxy, etc )
- A helm chart repo which provides chart to deploy services on k8s cluster (e.g. ingress-nginx).

## 1. System package repo

We support only debian server, so a debian package repo is built by using aptly. It has all the basic package of 
debian 11, k8s-main(kubeadm, kubelet, etc.), containerd, and docker.

To use it, follow the below steps

```shell
# step1: add the repo in your source list of the target server
# open the config file
sudo vim /etc/apt/sources.list
# comments the default config, below are some example
# deb http://deb.debian.org/debian bullseye main
# deb http://security.debian.org/debian-security bullseye-security main
# deb http://deb.debian.org/debian bullseye-updates main

# add the private repo, suppose the url is deb.casd.local. we don't want to use ssl
deb [trusted=yes] http://deb.casd.local/ bullseye main

# if you want to enable ssl, you need to add the pgp key of the repo into your target server
wget -qO- http://deb.casd.local/casd_gpg_key.asc | sudo tee /etc/apt/trusted.gpg.d/casd_gpg_key.asc
deb https://deb.casd.local/ bullseye main

# step2: Update the package cache in the target server
sudo apt update

# step3: install the package
sudo apt install containerd.io
```

## 2. Container image registry

We build a container image repo by using harbor. You need to configure the containerd daemon of all the servers in the
cluster to accept the private image repo.

The installation guide of harbor can be found here:
The required images must be pushed into this image registry.

### 2.1 Mirror the required container image in harbor

To init a cluster k8, you need to have the below container images:
- pause
- kube-apiserver
- kube-controller-manager
- kube-scheduler
- kube-proxy
- etcd
- coredns


You can get the complete image list with below command

```shell
k8s_version=1.31.1
kubeadm config images list --kubernetes-version=$k8s_version

# output example
registry.k8s.io/kube-apiserver:v1.31.1
registry.k8s.io/kube-controller-manager:v1.31.1
registry.k8s.io/kube-scheduler:v1.31.1
registry.k8s.io/kube-proxy:v1.31.1
registry.k8s.io/coredns/coredns:v1.11.3
registry.k8s.io/pause:3.10
registry.k8s.io/etcd:3.5.15-0

```
> The official Kubernetes image registry on Google Container Registry (GCR) is called `registry.k8s.io` 


Below script (`k8s_img_sync.bash`) pull k8s images from official repo and pushes them to casd repo

```shell
#!/bin/bash
# before running the script, make sure to adapt your config
repo_url=reg.casd.local
project_name=k8s_image

images=(
registry.k8s.io/kube-apiserver:v1.31.1
registry.k8s.io/kube-controller-manager:v1.31.1
registry.k8s.io/kube-scheduler:v1.31.1
registry.k8s.io/kube-proxy:v1.31.1
registry.k8s.io/coredns/coredns:v1.11.3
registry.k8s.io/pause:3.10
registry.k8s.io/etcd:3.5.15-0
)

for image_name in ${images[@]} ; do
docker pull $image_name
private_image_name="${repo_url}/${project_name}/${image_name#*/}"
docker tag $image_name $casd_image_name
docker push $casd_image_name
done
```

### 2.2 Download the image as tar file

If you don't have image registry, you can download the image and package it as a tar file.

The below script `save_k8s_images.bash`, save the all images in the list as `.tar` file.

```shell
#!/bin/bash
#change the output path to a dir where you want
out_path=.

images=(
registry.k8s.io/kube-apiserver:v1.31.1
registry.k8s.io/kube-controller-manager:v1.31.1
registry.k8s.io/kube-scheduler:v1.31.1
registry.k8s.io/kube-proxy:v1.31.1
registry.k8s.io/coredns/coredns:v1.11.3
registry.k8s.io/pause:3.10
registry.k8s.io/etcd:3.5.15-0
)

for image_name in ${images[@]} ; do
docker pull $image_name
tar_name="${out_path}/${image_name##*/}.tar"
docker save -o $tar_name $image_name
done
```

> The image in .tar still has the origin repository tag. For example the api server image still has 
> the tag `registry.k8s.io/kube-apiserver` 

### 2.3 Use private image registry to init k8s cluster

You can find the official doc of kubeadm [here](https://kubernetes.io/docs/reference/setup-tools/kubeadm/).

The compelte list of option of kubeadm init can be found [here](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/)
```shell
kubeadmin init \
  --apiserver-advertise-address=192.168.32.128\
  --image-repository reg.casd.local/k8s_images
  --control-plane-endpoint=k8s-master \
  --kubernetes-version v1.31.1
```

The default value of the image-repository is `k8s.gcr.io` for `kubeadmin`. So to user our private image registry, we 
need to change the default value. 

### 3. Mirror the images for calico

**calico network addon** handles all the virtual network of the k8s cluster, to install it,  you need to all the required images
- docker.io/calico/cni:`<version>`
- docker.io/calico/pod2deamon-flexvol:`<version>` 
- docker.io/calico/node:`<version>`
- docker.io/calico/kube-controllers:`<version>`

Below is the yaml file to install calico addon, if you use the private image registry, you need to 
```yaml

```