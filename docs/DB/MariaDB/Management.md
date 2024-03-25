# Manage a mysql/mariadb database

## Basic commands 
```mysql
# create a database
create database <db_name>;

# create a user with a password
CREATE USER 'username'@'hostname' IDENTIFIED BY 'password';

# Here’s an example which allows user ‘matthew’ to connect from any host.
CREATE USER 'matthew'@'%' IDENTIFIED BY 'supersecretpassword';

# After creating the user, you will need to grant the necessary privileges to the user. 
# This is done using the GRANT statement, which has the following form:
GRANT priv_type ON priv_level TO 'username'@'hostname';
# priv_type is the type of privilege which you want to grant (such as SELECT, INSERT, UPDATE, etc.), 
# priv_level is the level at which the privilege should apply (such as a specific database or table), 
# and username and hostname with the values you used in the CREATE USER statement.

# Here is an example of granting ALL permissions on all databases to our user, Matthew:
GRANT ALL PRIVILEGES ON * . * TO 'matthew'@'%';

# After granting the necessary privileges to the user, you can use the FLUSH PRIVILEGES statement to make the 
# changes take effect. This statement has the following form:
FLUSH PRIVILEGES;
```

## Enable remote access

### Step1: Update server bind address

By default, mysql/mariadb only listens to local host, and forbid all remote access. To enable it, you need to change
the default config.

```shell
# verify current stat
netstat -ant | grep 3306

# you should see something like this
tcp        0      0 127.0.0.1:3306          0.0.0.0:*               LISTEN      3731352/mysqld  
 
# change the default config
sudo vim /etc/mysql/my.cnf

# find the line bind-address = 127.0.0.1 and change it to 
bind-address = 0.0.0.0

# restart the service 
sudo systemctl restart mysql/mariadb

# check the new bind ip
$ netstat -ant | grep 3306

tcp        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN
```

### Step2: Update user authorization

By default, mysql set an acl for each user to a database with a list of authorize ip. If user try to connect to a server
with an authorized ip address, the connexion will be denied.

Below is an example to set proper acl to allow user to connect to a database with an authorized IP address.

```shell
# First, log in to the MySQL/MariaDB server with the root privilege:

$ mysql -u admin -p

# create a new db
MariaDB [(none)]> CREATE DATABASE wpdb;

# create a user 
MariaDB [(none)]> CREATE USER  'wpuser'@'localhost' IDENTIFIED BY 'password';


# you will need to grant permissions to the remote system with IP address 208.117.84.50 to connect to the database named wpdb as user wpuser. You can do it with the following command:
MariaDB [(none)]> GRANT ALL ON wpdb.* to 'wpuser'@'208.117.84.50' IDENTIFIED BY 'password' WITH GRANT OPTION;

# Next, flush the privileges and exit from the MariaDB shell with the following command:

MariaDB [(none)]> FLUSH PRIVILEGES;
MariaDB [(none)]> EXIT;

# If you want to grant remote access on all databases for wpuser, run the following command:
MariaDB [(none)]> GRANT ALL ON *.* to 'wpuser'@'208.117.84.50' IDENTIFIED BY 'password' WITH GRANT OPTION;

# If you want to grant access to all remote IP addresses on wpdb as wpuser, use % instead of IP address (208.117.84.50) as shown below:
MariaDB [(none)]> GRANT ALL ON wpdb.* to 'wpuser'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;

# If you want to grant access to all IP addresses in the subnet 208.117.84.0/24 on wpdb as user wpuser, run the following command:
MariaDB [(none)]> GRANT ALL ON wpdb.* to 'wpuser'@'208.117.84.%' IDENTIFIED BY 'password' WITH GRANT OPTION;
```

A brief explanation of each parameter is shown below:

- wpdb: It is the name of the MariaDB database that the user wants to connect to.
- wpuser: It is the name of the MariaDB database user.
- 208.117.84.50: It is the IP address of the remote system from which the user wants to connect.
- password: It is the password of the database user.

### Test connection from remote server

```shell
$ sudo apt-get install mariadb-client -y

# Once the installation is completed, connect to the MariaDB server by running the following command on the remote system:
mysql -u <uid> -h <db-ip> -p
```


