# Configure Postfix MTA as Send-Only on Debian 11

## 1 Setup server hostname

The hostname of the server will be used as the name of the sender of the emails. So you should keep it nice and clean

```shell
# get the current hostname
hostname

# if the name does not fit you, you can set up a new hostname
sudo hostnamectl set-hostname smtp.casd.local --static
```

## 2Install the packages

```shell
# Install mailutils package
sudo apt install mailutils

# install postfix
sudo apt install postfix
```

As the `postfix` package installs, you’ll be asked to select an option on screen for your mail server. 
For **General type of email configuration** window, select **Internet site** and click **OK** button. Here we suppose
your server has internet connexion.

The next page will ask you to set your **Mail server name**, this can be domain or server hostname with an A record.
In this tutorial, we choose the host name of the server `smtp.casd.local`.

## 3. Configure Postfix MTA Server
Edit Postfix configuration file **/etc/postfix/main.cf** to ensure it is configured as send only ( Only relaying emails from the local server).

Set Postfix to listen on the 127.0.0.1loopback interface. `The default setting is to listen on all interfaces`

```shell
# open the conf file
sudo vim /etc/postfix/main.cf

# edit the below line
inet_interfaces=loopback-only
myhostname=smtp.casd.local

# restart the postfix service
sudo systemctl restart postfix
```

## 4. Test the postfix service

To test email delivery, use the mail command like below.

```shell
# send a mail to userx@example.com with title `Postfix Testing` and content `Postfix Send-Only Server`
echo "Postfix Send-Only Server" | mail -s "Postfix Testing" userx@example.com
```

Check the junk mails, you may find it there.