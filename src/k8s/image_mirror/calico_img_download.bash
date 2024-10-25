#!/bin/bash
#change the output path to a dir where you want
out_path=.

images=(
docker.io/calico/cni:v3.28.2
docker.io/calico/node:v3.28.2
docker.io/calico/kube-controllers:v3.28.2
)

for image_name in "${images[@]}" ; do
docker pull "${image_name}"
tar_name="${out_path}/${image_name##*/}.tar"
docker save -o "${tar_name}" "${image_name}"
done