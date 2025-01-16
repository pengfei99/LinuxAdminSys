# Use private repo

## add private repo in your apt 

suppose the url of the repo is `https://repolin.casd.fr`

```shell
sudo vim /etc/apt/sources.list

# add below line for a repo
deb [trusted=yes] https://repolin.casd.fr/ bullseye main
```

If the certificate is not signed by a known CA. You can install the certificate 

```shell
# get the certificate of the private repo
openssl s_client -connect {HOSTNAME}:{PORT} -showcerts

# in our case
openssl s_client -connect repolin.casd.fr:443 -showcerts

# copy the output certificate in a file and put it in below folder
sudo mv casd-root.crt /usr/local/share/ca-certificates/
# update the certificate list
run sudo update-ca-certificates

# update the apt repo list
sudo apt update

# update packages
sudo apt upgrade
```