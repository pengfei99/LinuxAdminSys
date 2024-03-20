# Maria DB installation

## Step 1: 

Install software-properties-common if missing:

```shell
sudo apt update
sudo apt install software-properties-common
```

## Step 2: 

Run the command below to add Repository Key to the system
```shell
Import MariaDB gpg key and repo
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8

# Add the apt repository
sudo add-apt-repository "deb [arch=amd64,arm64,ppc64el] http://mariadb.mirror.liquidtelecom.com/repo/10.4/ubuntu $(lsb_release -cs) main"

sudo apt update
sudo apt -y install mariadb-server mariadb-client
```


## Remove/Purge old installation

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

## Recover your root password

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

## Change innodb_page_size
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