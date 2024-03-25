# Maria DB installation

## 1. Installation

### Step 1: 

Install software-properties-common if missing:

```shell
sudo apt update
sudo apt install software-properties-common
```

### Step 2: 

Run the command below to add Repository Key to the system

```shell
Import MariaDB gpg key and repo
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8

# Add the apt repository
# Note the below apt-repository url is for ubuntu, for other distribution you may need to change the url
sudo add-apt-repository "deb [arch=amd64,arm64,ppc64el] http://mariadb.mirror.liquidtelecom.com/repo/10.4/ubuntu $(lsb_release -cs) main"

sudo apt update
sudo apt -y install mariadb-server mariadb-client

# You will be prompted to provide MariaDB root password, after the above command.
# If you didn’t receive password set prompt, then manually run the MySQL hardening script.
sudo mysql_secure_installation 

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none): 
OK, successfully used password, moving on...

Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n] y
Enabled successfully!
Reloading privilege tables..
 ... Success!


You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n] y
New password: 
Re-enter new password: 
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] y
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```
> If you are not able to set up root password, you can follow


### Step 3: Test the mariaDB installation

```shell
# check daemon status
sudo systemctl status mysql

# connect to the server via mysql client
mysql -u root -p

# check your installation version
SELECT VERSION();

# exit the sql terminal
QUIT
```

## 2. Remove/Purge old installation

If you already have one installation of mysql or mariadb, and you need to install a new one. It's recommended to
remove and purge all the dependencies of the old installation. Because you will have many conflicts which are not 
expected.

Just follow the below steps
```shell
# 1. make sure that MySQL service is stopped.
sudo systemctl stop mysql

# 2. Remove MySQL related all packages completely.
sudo apt-get purge mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-*

# 3. Remove MySQL configuration and data. If you have changed database location in your MySQL configuration, 
#    you need to replace /var/lib/mysql according to it.
sudo rm -rf /etc/mysql /var/lib/mysql

# 4. (Optional but recommended) Remove unnecessary packages.
sudo apt autoremove

# 5. (Optional) Remove apt cache.
sudo apt autoclean
```

## 3. Recover your root password

Do not do this if you have other options. `You must have access to the Linux server running MySQL or MariaDB with a sudo user.`


```shell
# Identifying the Database Version
mysql --version

# Stopping the Database Server
sudo systemctl stop mysql/mariadb

# Restarting the Database Server Without Permission Checking
sudo mysqld_safe --skip-grant-tables --skip-networking &
# note this will run the mysqld in the background, if you want to check the status, you can use
jobs
# when you have the job id, you can use 
fg %<job-id>


# Now you can connect to the database as the root user, which should not ask for a password.
mysql -u root

# For MySQL 5.7.6 and newer as well as MariaDB 10.1.20 and newer, use the following command.
# don't forget to change the new_password to a value which you want
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';

# For MySQL 5.7.5 and older as well as MariaDB 10.1.20 and older, use:
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('new_password');

# In either case, you should see confirmation that the command has been successfully executed.
Output
Query OK, 0 rows affected (0.00 sec)

# kill the mysqld unsafe daemon
sudo kill `cat /var/run/mysqld/mysqld.pid`
# for MariaDB
sudo kill `/var/run/mariadb/mariadb.pid`

# Restart the Database Server Normally
sudo systemctl start mysql/mariadb

# connect to the server with the new password
mysql -u root -p
```

## 4. Change innodb_page_size
When we encounter **Row Size Too Large Errors with InnoDB** error, we may need to increase the innodb_page_size

To learn more details of this bug, you can visit this page
https://mariadb.com/kb/en/troubleshooting-row-size-too-large-errors-with-innodb/

```shell
# get a sql terminal
mysql -u root -p

# get the current database innodb_page_size
show variables like '%innodb_page_size%';
exit;

# stop the db daemon
sudo systemctl stop mysql

# backup the system database (e.g. innodb) data and log files
# in debian os, the data ibdata1 and the log files (ib_logfile0 & ib_logfile1) are located at /var/lib/mysql
cd /var/lib/mysql/
sudo mkdir /tmp/innodb_bkp
sudo mv ibdata1 /tmp/innodb_bkp
sudo sudo mv ib_logfile* /tmp/innodb_bkp

# now change the innodb_page_size value
# in debian, the mysql/mariadb conf file are located /etc/mysql/my.cnf
# you can add the below line in the [mysqld]
# suppose we want to put 8k, the default value for MariaDB-1:10.4.33 is 16k
[mysqld]
innodb_page_size=8k

# restart the mysql daemon
sudo systemctl start mysql

```

> after changing the innodb_page_size, the existing database may not work properly, so you may need to export/import
  the existing database for safety.