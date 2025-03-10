# Upgrade k8s cluster

The official doc

https://v1-30.docs.kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/


## Changing the k8s package repository

https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/change-package-repository/

## update repo gpg key

When you update k8s package from the repo, you may encounter the below problems

```shell
Err:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  InRelease
  The following signatures were invalid: EXPKEYSIG 234654DA9A296436 isv:kubernetes OBS Project <isv:kubernetes@build.opensuse.org>

W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  InRelease: The following signatures were invalid: EXPKEYSIG 234654DA9A296436 isv:kubernetes OBS Project <isv:kubernetes@build.opensuse.org>

W: Failed to fetch https://pkgs.k8s.io/core:/stable:/v1.31/deb/InRelease  The following signatures were invalid: EXPKEYSIG 234654DA9A296436 isv:kubernetes OBS Project <isv:kubernetes@build.opensuse.org>

W: Some index files failed to download. They have been ignored, or old ones used instead.
```

The problem is caused by the repo who has changed its pgp key.
To fix it, you need to download the new gpg key.

```shell
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```