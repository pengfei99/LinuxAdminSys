# Build openssl

There are some feature of signing certificate only exist in v3, and v3 is not in the standard repo or backports repo.
So we have to build it manually.

## Get the source
You can find the full source list [here](https://www.openssl.org/source/). I use version `3.0.9` in this tutorial.

```shell
# the -P option will put the download file in the target dir
sudo wget -P /usr/src/ https://www.openssl.org/source/openssl-3.0.9.tar.gz

cd /usr/src

# unzip the source
sudo tar -xzvf openssl-3.0.9.tar.gz
```

## Config and build the bin

```shell
cd /usr/src/openssl-3.0.9

# install dependencies
sudo apt update
sudo apt install build-essential checkinstall zlib1g-dev libssl-dev

# you can replace the prefix by a custom path
./config --prefix=/usr/local/openssl

# build the source 
sudo make

sudo make test

sudo make install

# if everything works well, you should find the below dirs in /usr/local/openssl
/usr/local/openssl/
├── bin
├── include
├── lib64
├── share
└── ssl

```

## Post installation config

```shell
# try the newly build
/usr/local/openssl/bin/openssl version

# normally, you should see the below error message 
openssl: error while loading shared libraries: libssl.so.3: cannot open shared object file: No such file or directory

# that's because the required lib is not loaded in your env
# run the below command to load 
echo 'export LD_LIBRARY_PATH=/usr/local/openssl/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc

# add the lib path (/usr/local/openssl/lib64) in the below file
sudo vim /etc/ld.so.conf.d/openssl.conf

# reload the ldconfig
sudo ldconfig
# check if the lib exist or not
sudo ldconfig -p | grep libssl.so.3

# if you can find the new lib, then rerun
/usr/local/openssl/bin/openssl version 
```

If you want to replace the old version of openssl, you can run the below command

```shell
# remove the old version  
mv /usr/bin/openssl /root/openssl-old

echo 'PATH="/usr/local/openssl/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```