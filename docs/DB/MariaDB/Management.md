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