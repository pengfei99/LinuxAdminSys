# Configure debian server ssh auth


Suppose we have a ldap and kerberos server running on `10.50.5.200` with url as `krb.casd.local`.

suppose we have 3 server
The architecture 

The full authentication process:
1. user 

## Configure and test krb client

Before 


```shell
[sssd]
services = nss, pam
domains = casd.local
config_file_version = 2

[domain/casd.local]
id_provider = ldap
ldap_uri = ldap://krb.casd.local
ldap_search_base = dc=casd,dc=local

auth_provider = krb5
krb5_realm = CASD.LOCAL
debug_level = 5
krb5_validate = true
krb5_ccachedir = /var/tmp # note that RHEL-7 default to KERNEL ccaches, which are preferred in most cases to FILE
krb5_keytab = /etc/krb5.keytab
cache_credentials = true

override_homedir = /home/%u
default_shell = /bin/bash


[nss]
homedir_substring = /home

[pam]

```