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
casd_image_name="${repo_url}/${project_name}/${image_name#*/}"
docker tag $image_name $casd_image_name
docker push $casd_image_name
done