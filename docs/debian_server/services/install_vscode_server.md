# Deploy VS code as a web service

There are two options, which allows you to run VS Code in the browser, giving you access to your development 
environment remotely.:
- VS Code Server
- code-server

## 1. VS Code Server (Remote Development Extension Pack)

In this mode, we use VS code desktop (on client machine) to install a `Remote Development Extension Pack` which allows 
the client vs code to open a ssh tunnel with the vs code server(on remote server).

You can find the official doc [here](https://code.visualstudio.com/docs/remote/vscode-server)

> We don't recommend this option, because ssh uses specific ports which requires extra firewall configuration.
> 
> 
## 2. Code server

In this mode, the code-server (vs code server backend) runs an application server(default port is 8080). For example
user can access the vs code via any browser with http://url:8080/. If you add a proxy, you can run it with 80 or 443.

### 2.1 Installation

**code-server** is an open-source project by Coder that allows you to run a standalone VS Code instance in a web 
browser. You can install it on any machine, even a remote server, and access it from anywhere.

The official github page of the `code-server` is here: https://github.com/coder/code-server

```shell
# use the installation script
curl -fsSL https://code-server.dev/install.sh | sh

# start the server
code-server

```

The above command will generate a config  **~/.config/code-server/config.yaml**. Below is an example of the config file

```shell
# if you want to allow remote access, change the 127.0.0.1 to 0.0.0.0.
# you can also change the 
bind-addr: 127.0.0.1:8080
auth: password
password: changeMe
cert: false
# cert-key: 
```

The default auth method is `password`, it also supports `OAuth2`. To disable authentication, you can put `none`.

For the ssl certificate, we don't recommend to activate it, because nginx can do a better job.

### 2.2 Enable nginx as reverse-proxy

Suppose we start the code-server at 127.0.0.1:8080, Below is a nginx config example

```shell
# add a conf
vim /etc/nginx/sites-available/vscode-server

## Add below content
# set a backend upstream
upstream vscode-server {
    server 127.0.0.1:8080 fail_timeout=0;
}

# a server listen to port 80, which will redirect request to port 443
server {
    listen 80;
    server_name vscode-server.casd.local;

    # redirect http request to https
    return 301 https://$host$request_uri;

    }

# a server listen to port 443, which will ensure https resolution
server {
    listen 443 ssl;
    ssl_certificate /etc/ssl/certs/wildcard-casd.pem;
    ssl_certificate_key /etc/ssl/private/wildcard-casd.key;

    # all request will be redirected to the backend_chart upstream
    location / {
        include proxy_params;
        proxy_pass http://vscode-server;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;

    }
}

# Activate the conf
ln -s /etc/nginx/sites-available/vscode-server /etc/nginx/sites-enabled/vscode-server
```

### 2.3 Edit a systemd service file

To run code-server as a daemon, it's recommended to edit a systemd service file.

```shell
sudo vim /etc/systemd/system/code-server.service

# add the below content
[Unit]
Description=code-server
After=network.target

[Service]
Type=simple
User=pliu
ExecStart=/usr/bin/code-server --bind-addr 0.0.0.0:8080 --auth password
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```shell
# reload systemd daemon
sudo systemctl daemon-reload
# enable code-server as start up service
sudo systemctl enable code-server

# start the service
sudo systemctl start code-server

# check the status
sudo systemctl status code-server

# check the log 
journalctl -u code-server -f

# stop the service
sudo systemctl stop code-server

```