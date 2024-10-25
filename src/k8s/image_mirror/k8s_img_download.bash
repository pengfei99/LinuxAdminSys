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

for image_name in "${images[@]}" ; do
docker pull "${image_name}"
tar_name="${out_path}/${image_name##*/}.tar"
docker save -o "${tar_name}" "${image_name}"
done