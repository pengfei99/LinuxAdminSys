# Install on configure gitlab CE on debian 11

GitLab Community Edition (CE) is an open-source application for hosting Git repositories in your own infrastructure. 
With GitLab you can do project planning and source code management to CI/CD and monitoring. GitLab has evolved to 
become a complete DevOps platform, delivered as a single application.

## 1. The minimum requirements

The Gitlab CE is an application web with a database. To allow it to run correctly. We recommend you to meet the below
minimum requirements:
- 8GB of Ram
- 4 vcpus
- 40GB Disk space

> Having a domain name allows user to easily access it. So we recommand you to provide a domain name 

In this tutorial, we set the domain name as:  `git.casd.local`

## 2. Install the gitlab ce dependencies packages

```shell
# update apt repo
sudo apt update && sudo apt -y full-upgrade

# Install GitLab Server Dependencies
sudo apt -y install curl vim openssh-server ca-certificates

```

## 3. Configure Postfix Send-Only SMTP

You can find the full doc [here](../Install_configure_Postfix_to_sendmail.md)

## 4. Add the GitLab CE Repository 

With the below script, we will add the GitLab repository (`gitlab_gitlab-ce.list`) to `/etc/apt/sources.list.d/`.

```shell
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
```        

The content of the `gitlab_gitlab-ce.list` should looks like:

```shell
# this file was generated by packages.gitlab.com for
# the repository at https://packages.gitlab.com/gitlab/gitlab-ce

deb [signed-by=/usr/share/keyrings/gitlab_gitlab-ce-archive-keyring.gpg] https://packages.gitlab.com/gitlab/gitlab-ce/debian/ bullseye main
deb-src [signed-by=/usr/share/keyrings/gitlab_gitlab-ce-archive-keyring.gpg] https://packages.gitlab.com/gitlab/gitlab-ce/debian/ bullseye main

```

## 5. Install GitLab CE on Debian

```shell
export GITLAB_URL="http://git.casd.local"
sudo EXTERNAL_URL="${GITLAB_URL}" apt install gitlab-ce
```

If everything goes well, you should see the success output. And the gitlab-ce server is up and running at 
**http://git.casd.local**

## 6.Test the gitlab server

By default, it generates a root account with a password. You can get the password with the below command

```shell
sudo cat /etc/gitlab/initial_root_password 
```

If everything goes well, you should be able to login with root/pwd

## 7. Custom config

The main config file is located at `/etc/gitlab/gitlab.rb`. If you followed the above procedure, it will install a 
gitlab with minimun config.
- No external authentication
- built-in postgres db
- Etc.

We need to modify the config to make the gitlab server production ready.

```shell
# open the conf file
sudo vim /etc/gitlab/gitlab.rb

# do some change 

# apply the change
sudo gitlab-ctl reconfigure
```

### 7.1 Use an openldap server for authentication

You can find the official doc here https://docs.gitlab.com/ee/administration/auth/ldap/#updating-ldap-dn-and-email
To enable the ldap authentication, you need to 
```shell
# enable the ldap authentication
gitlab_rails['ldap_enabled'] = true

# config the ldap server connexion
gitlab_rails['ldap_servers'] = YAML.load <<-'EOS'
     host: 'ldap.casd.local'
     port: 389
     uid: 'uid'
     bind_dn: 'cn=gitlab,ou=serviceAccounts,dc=casd,dc=local'
     password: 'gitlabServiceAccountPassword'
     encryption: 'plain'
     base: 'ou=people,dc=casd,dc=local'
     verify_certificates: false
     active_directory: false
     lowercase_usernames: false
     block_auto_created_users: false
     attributes:
        username: ['uid']
        email: ['mail']
        name: 'displayName'
        first_name: 'givenName'
        last_name: 'sn'
EOS
```

### 7.2 Use external postgresql db

https://docs.gitlab.com/ee/administration/postgresql/external.html

https://stackoverflow.com/questions/23580268/gitlab-omnibus-configuration-for-postgres