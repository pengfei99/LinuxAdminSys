# Manage a mysql/mariadb database

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