# 

## 1. Install required packages

```shell
sudo apt install realmd sssd sssd-ad krb5-user winbind libpam-krb5 libnss-sss libpam-sss -y
```


### 1.1 realmd service
`realmd` is a service that discovers and joins a machine to `a Kerberos realm (AD domain)` automatically. It simplifies
`joining a Linux system to AD and configuring SSSD`.

Below are some useful commands of the realmd service

```shell
realm discover ad.casd.eu  # Discover AD domain
realm join --user=Administrator ad.casd.eu  # Join the linux server to AD
```

### 1.2 sssd (System Security Services Daemon)

The `sssd` daemon handles authentication and user information retrieval from AD, LDAP, or other identity providers.
It can cache user credentials, so users can log in even if the AD server is temporarily unavailable.
It integrates with `PAM (Pluggable Authentication Modules)` and `NSS (Name Service Switch)` to provide seamless 
authentication.

> You can use `sssd-tools`(A set of command-line utilities) for managing and debugging SSSD.
> 
```shell
# control and test sssd
sssctl
```

### 1.3 

sssd：提供缓存和响应认证请求的服务。
sssd-ad：用于 AD 集成的 SSSD 插件。
krb5-user：Kerberos 客户端。
winbind：用于集成 Windows 域的用户和组信息。
libpam-krb5、libnss-sss、libpam-sss：用于 PAM 和 NSS 的库，以支持 SSSD。