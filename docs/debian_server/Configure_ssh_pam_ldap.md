# Configure debian server ssh to use pam ldap

We will use **libpam-ldapd** as the ldap server client and server authenticator to check user login and password via ldap server. It is a newer alternative to the original `libpam-ldap`. **libpam-ldapd** uses the same backend `(nslcd)` as `libnss-ldapd`, and thus also shares the same configuration file `(/etc/nslcd.conf)` for LDAP connection parameters. If you're already using libnss-ldapd for NSS, it may be more convenient to use libpam-ldapd's **pam_ldap** implementation.

The /etc/pam.d/common-* files are managed by pam-auth-update (from libpam-runtime).

The libpam-ldapd package includes `/usr/share/pam-configs/ldap`, and running `dpkg-reconfigure libpam-runtime` will let you configure the `pam_unix/pam_ldap` module(s) to use in /etc/pam.d/common-*.

The **nslcd** is the name service LDAP connection daemon.

> Installing the libpam-ldapd package will automatically select the pam_ldap module for use in /etc/pam.d/common-*.

### 6.1 Install the required packages

```shell
sudo apt-get install libnss-ldapd libpam-ldapd
```
After the installation, a pop-up window will require you to enter the `ldap uri` and the `base dn` of the ldap server

For example
```text
ldap_uri: ldap://10.50.5.57/ or ldap://ldap.casd.local/

ldap_base_dn: dc=casd,dc=local

```
### 6.2 Edit the config

#### 6.2.1 The first config is `/etc/nslcd.conf`
As you already enter some information during installation. This file is filled with some info.

Below is a working example.

```text
# /etc/nslcd.conf
# nslcd configuration file. See nslcd.conf(5)
# for details.

# The user and group nslcd should run as.
uid nslcd
gid nslcd

# The location at which the LDAP server(s) should be reachable.
uri ldap://10.50.5.57/

# The search base that will be used for all queries.
base dc=casd,dc=local

# The LDAP protocol version to use.
#ldap_version 3

# The DN to bind with for normal lookups.
#binddn cn=annonymous,dc=example,dc=net
#bindpw secret

# The DN used for password modifications by root.
#rootpwmoddn cn=admin,dc=example,dc=com

# SSL options
#ssl off
#tls_reqcert never
# tls_cacertfile /etc/ssl/certs/ca-certificates.crt

# The search scope.
#scope sub

```

> The good practice is not write the `binddn` and `bindpw` with admin privilege. If you leave it empty, `pam-ldapd` will use the current user login and pwd to bind to the ldap. So it's safer.

#### 6.2.2 /etc/nsswitch.conf

Change the old version to below version

```text
# /etc/nsswitch.conf
#
# Example configuration of GNU Name Service Switch functionality.
# If you have the `glibc-doc-reference' and `info' packages installed, try:
# `info libc "Name Service Switch"' for information about this file.

passwd:         files ldap
group:          files ldap
shadow:         files ldap
gshadow:        files

hosts:          files dns
networks:       files

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files

netgroup:       nis

```

#### 6.2.3  /etc/pam.d/common-*

There are a list of config files for pam which are located at  **/etc/pam.d/**. In our case, we need to modify:
- /etc/pam.d/common-auth
- /etc/pam.d/common-account
- /etc/pam.d/common-session
- /etc/pam.d/common-password


```text
sudo vim /etc/pam.d/common-auth

# comment the old content, and add below line
auth      sufficient  pam_unix.so
auth      sufficient  pam_ldap.so minimum_uid=1000 use_first_pass
auth      required    pam_deny.so

```

```text
sudo vim /etc/pam.d/common-account
# comment the old content, and add below line
account   required    pam_unix.so
account   sufficient  pam_ldap.so minimum_uid=1000
account   required    pam_permit.so

```

```text
sudo vim /etc/pam.d/common-session
# comment the old content, and add below line
session   required    pam_unix.so
session   optional    pam_ldap.so minimum_uid=1000
# this line will create the user home for first login
session    required   pam_mkhomedir.so skel=/etc/skel/ umask=0022

```

```text
sudo vim /etc/pam.d/common-password
# comment the old content, and add below line
password  sufficient  pam_unix.so nullok md5 shadow use_authtok
password  sufficient  pam_ldap.so minimum_uid=1000 try_first_pass
password  required    pam_deny.so

```

#### 6.2.4 /etc/ssh/sshd_config

Normally, you don't need to modify the  **/etc/ssh/sshd_config**. Because the `libpam-ldapd` will set **UsePAM yes** automatically for sshd to use PAM authentication.

If you have troubles, don't forget to check 

> The above conf is the minimun for the pam-ldapd works. You need to enrich it if you have special requirements

### 6.3 Restart the service

As we metioned before, the

```shell
# check the status of the daemon
sudo systemctl status nscd
sudo systemctl status nslcd

# restart the service
sudo systemctl restart nscd
sudo systemctl restart nslcd

```

### 6.4 Test and troubleshoot

To ensure that everything is working correctly you can run 
```shell
# this command prints all user account of the server which also includes the users from LDAP
getent passwd

# below is an example of user passwd from ldap
trigaud:x:3000:3000:Titouan:/home/trigaud:/bin/bash

# below can show the user shadow form ldap too
getent shadow 
```


To test authentication log in with an LDAP user, you can run below command

```shell
# general form to local login
su - <UID>

# for example, run below command and enter the pwd. if it's correct, 
su - trigaud
```


To troubleshoot problems you can run `nslcd in debug mode` (remember to stop nscd when debugging). Debug mode should return a lot of information about the LDAP queries that are performed and errors that may arise.

```shell
/etc/init.d/nscd stop
/etc/init.d/nslcd stop
nslcd -d
```


## For AD compatibility

To use **AD** as authentication server, we can't use `nslcd` anymore. We need to test the `sssd` and `AD` connexion.