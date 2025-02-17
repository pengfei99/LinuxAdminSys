# Debian server security docs

In this folder, we store all documentation about debian server security.

## 1. SSHD Authentication

The most common way to remote access a debian server is via ssh protocol. On the sever side, a sshd daemon runs as 
ssh server that listens to port 22 (default port). It supports many authentication mechanisms such as:

- Password Authentication (Using /etc/shadow) : This method only works for local users (not LDAP, SSSD, or Kerberos users). In `/etc/ssh/sshd_config`, put `UsePAM no \n PasswordAuthentication yes`
- Public Key Authentication (No Password Required): SSHD checks if the user private key matches a valid public key in ~/.ssh/authorized_keys.
- GSSAPI/Kerberos Authentication: SSHD can authenticate users using GSSAPI (Kerberos-based authentication) without PAM
- **PAM (Pluggable Authentication Modules) Recommended**: It supports multiple authentication methods (LDAP, Kerberos, SSSD, MFA).



### 1.1 Terms

On linux server, to allow user remote access, we use many daemons:

- sshd
- pam(Pluggable Authentication Modules):
- sssd(System Security Services Daemon)**Recommended**: Provides access to remote identity and authentication providers, such as LDAP, Active Directory (AD), FreeIPA, or Kerberos.
- nslcd(Name Service LDAP Daemon) **deprecated**: Connects the Name Service Switch (NSS) and PAM to an LDAP directory for user authentication and identity lookup.
- nscd(Name Service Cache Daemon): Caches results from services like DNS and LDAP to reduce query load. sssd has its own caching mechanism, do not recommend when using sssd.

### 1.2 SSH client server authentication workflow 

In the below section, we describe the authentication 
workflow of a ssh server configured with `sshd -> pam -> sssd -> krb/openldap`

#### Step 1. SSH Client Initiates Connection

A user runs:

```shell
ssh user@debian-server
```

> The SSH daemon (sshd) on the Debian server receives the connection request and begins the authentication process.

#### Step2. SSHD Hands Authentication to PAM

SSHD is configured to use PAM (Pluggable Authentication Modules) for user authentication.
It checks **/etc/pam.d/sshd**, which includes configurations for authentication backends.
PAM invokes the relevant authentication module, in this case, SSSD.


#### Step3. PAM Calls SSSD for Authentication

PAM is configured to use SSSD via the module: **/etc/pam.d/common-auth**

You should see the below line which tells pam to query sssd for authentication

```shell
auth    [success=1 default=ignore]    pam_sss.so
```

#### Step 4. SSSD Queries OpenLDAP/kerberos for User Authentication

SSSD Configuration (/etc/sssd/sssd.conf) specifies OpenLDAP as the backend.
SSSD checks if the credentials are cached:
If cached, it allows authentication without querying OpenLDAP (useful for offline authentication).
If not cached, SSSD sends the authentication request to OpenLDAP.
5. OpenLDAP Validates User Credentials
OpenLDAP checks:
If the user exists in the LDAP directory (uid=user).
The password stored in LDAP.
If using LDAP bind authentication, OpenLDAP attempts to bind as the user with the provided password.
If using Kerberos (via LDAP), OpenLDAP defers authentication to a Kerberos KDC.
6. Authentication Result Passed Back
If authentication is successful, OpenLDAP responds to SSSD.
SSSD caches the credentials (if caching is enabled).
SSSD informs PAM of the successful authentication.
PAM notifies SSHD that the user is authenticated.
7. SSHD Grants Access
If the user has the correct authorization (i.e., shell access, SSH keys, group policies), SSHD grants access.
The user gets a shell on the Debian server.
Authentication Flow Summary
SSH Client → Requests login from SSHD.
SSHD → Delegates authentication to PAM.
PAM → Calls pam_sss.so to use SSSD.
SSSD → Queries OpenLDAP (or checks cache).
OpenLDAP → Verifies user credentials.
SSSD → Returns authentication result to PAM.
PAM → Informs SSHD.
SSHD → Grants or denies access.
Additional Notes
If 2FA (Two-Factor Authentication) is enabled, PAM may prompt for additional verification.
If public key authentication is used, SSHD may bypass PAM and authenticate using the user's SSH key.
If the LDAP server is down, authentication fails unless SSSD has cached credentials.
Authorization (e.g., checking if a user belongs to a specific group) is usually done via sssd's access_provider settings.


`/etc/pam.d/sshd`

```shell
# PAM configuration for the Secure Shell service

# Standard Un*x authentication.
@include common-auth

# Disallow non-root logins when /etc/nologin exists.
auth       required     pam_env.so
auth       sufficient   pam_unix.so nullok 
auth       sufficient   pam_sss.so use_first_pass
auth       required     pam_deny.so

account    required     pam_unix.so
account    sufficient   pam_sss.so

password   required    pam_sss.so
session    required    pam_sss.so

# Uncomment and edit /etc/security/access.conf if you need to set complex
# access limits that are hard to express in sshd_config.
# account  required     pam_access.so

# Standard Un*x authorization.
@include common-account

# SELinux needs to be the first session rule.  This ensures that any
# lingering context has been cleared.  Without this it is possible that a
# module could execute code in the wrong domain.
session [success=ok ignore=ignore module_unknown=ignore default=bad]        pam_selinux.so close

# Set the loginuid process attribute.
session    required     pam_loginuid.so

# Create a new session keyring.
session    optional     pam_keyinit.so force revoke

# Standard Un*x session setup and teardown.
@include common-session

# Print the message of the day upon successful login.
# This includes a dynamically generated part from /run/motd.dynamic
# and a static (admin-editable) part from /etc/motd.
session    optional     pam_motd.so  motd=/run/motd.dynamic
session    optional     pam_motd.so noupdate

# Print the status of the user's mailbox upon successful login.
session    optional     pam_mail.so standard noenv # [1]

# Set up user limits from /etc/security/limits.conf.
session    required     pam_limits.so

# Read environment variables from /etc/environment and
# /etc/security/pam_env.conf.
session    required     pam_env.so # [1]
# In Debian 4.0 (etch), locale-related environment variables were moved to
# /etc/default/locale, so read that as well.
session    required     pam_env.so user_readenv=1 envfile=/etc/default/locale

# SELinux needs to intervene at login time to ensure that the process starts
# in the proper default security context.  Only sessions which are intended
# to run in the user's context should be run after this.
session [success=ok ignore=ignore module_unknown=ignore default=bad]        pam_selinux.so open

# Standard Un*x password updating.
@include common-password

```


