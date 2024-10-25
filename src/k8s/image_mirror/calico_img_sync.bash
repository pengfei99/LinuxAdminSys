#!/bin/bash
# before running the script, make sure to adapt your config
repo_url=reg.casd.local
project_name=calico

images=(
docker.io/calico/cni:v3.28.2
docker.io/calico/node:v3.28.2
docker.io/calico/kube-controllers:v3.28.2
)

for image_name in "${images[@]}" ; do
docker pull "${image_name}"
casd_image_name="${repo_url}/${project_name}/${image_name#*/}"
docker tag "${image_name}" "${casd_image_name}"
docker push "${casd_image_name}"
done