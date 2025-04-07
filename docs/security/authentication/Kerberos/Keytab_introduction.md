# Keytab files

A .keytab file is a binary file that stores `Kerberos principal credentials in an encrypted format`. 
It allows services and users to authenticate with a Kerberos Key Distribution Center (KDC) without 
manually entering a password.

## 1. Use cases

We will use a keytab file for getting a kerberos ticket in the below scenarios:

- **Service-to-Service Authentication**: The authentication between services must be automatically without manual input
            of password. For example, Hadoop YARN ResourceManager or Spark job needs to authenticate to HDFS, it 
             uses a keytab to prove its identity

- **Passwordless Login**: A keytab file securely stores credentials and eliminates the need to hardcode 
                passwords in scripts or configurations.

## 2. Lifecycle of a .keytab File

A .keytab file `does not expire on its own`, but the credentials inside it (Kerberos keys) can become invalid due to 
password changes, key rotations, or policy settings in Active Directory (AD) or the Kerberos Key Distribution Center (KDC). 
Below is the typical lifecycle:
1. Creation of the Keytab: The .keytab file is generated using `ktpass (Windows)` or `kadmin (Linux)`. 
     `It contains encrypted credentials for a Kerberos principal.`
2. Usage in passwordless Authentication: `kinit -kt <keytab> <principal>` command fetches a Kerberos ticket from the KDC.
3. Expiry, renew of Tickets: `TGTs expire` after a certain time (e.g., 10 hours). If the ticket is renewable, it Can be 
        renewed using `kinit -R`. Otherwise, a new ticket must be obtained using `kinit -kt <keytab> <principal>`.
4. Keytab becomes invalid, ask a new keytab:

Below is a list of when you need to renew a .keytab file:
1. Users change the password:
2. Password/key rotation policies: For service accounts, the services do not change the password. But password/key 
                   rotation policies may be enforced. AD may change the password every 90 days.
3. Revocation: If a security breach has been discovered, the admin users will revoke existing credentials.

## 3. Keytab files generation

There are two ways to generate keytab files:
- from the server side(KDC)
- from the client side

### 3.1 From the KDC side

#### 3.1.1 For AD/krb users(Windows):

```shell
# for a user account
ktpass -princ pliu@CASDDS.CASD -mapuser pliu -crypto ALL -ptype KRB5_NT_PRINCIPAL -pass * -out pliu-user.keytab

# for a service account
ktpass -princ host/hadoop-client.casdds.casd@CASDDS.CASD -mapuser HADOOP-CLIENT$ -pass * -ptype KRB5_NT_PRINCIPAL -crypto AES256-SHA1 -out hadoop-client.keytab
```

- In `-mapuser HADOOP-CLIENT$`, The $ indicates it's a service account (not a user). 
- `-pass *`: You will be prompted to enter a password, **this password must match the actual AD account password**.
                ktpass doesn’t have the ability to fetch a user's existing password from Active Directory automatically.

To automate the keytab generation, you can write a powershell which reset the AD account password at the same time.

```shell
# get a new password from prompt
$pass = Read-Host -AsSecureString "Enter AD Password"
$plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass)
)
# reset AD account password with the new password
Set-ADAccountPassword -Identity pliu -Reset -NewPassword (ConvertTo-SecureString $plain -AsPlainText -Force)

# generate keytab with the new password
ktpass -princ pliu@CASDDS.CASD -mapuser pliu -crypto ALL -ptype KRB5_NT_PRINCIPAL -pass $plain -out pliu-user.keytab
```

#### 3.1.2 For MIT kerberos users(Linux):
```shell
# get a kadmin shell
sudo kadmin.local

# create a keytab for one principal
ktadd -k /tmp/pliu-user.keytab pliu@CASDDS.CASD

# if the principal does not exist, you can create a new principal with
addprinc -randkey pliu@CASDDS.CASD
```

### 3.2 From the client side

#### 3.2.1 For AD/krb users(Windows):
For windows user, we can use the `ktpass` command

```shell
ktpass -princ HTTP/client.example.com@EXAMPLE.COM ^
       -mapuser clientuser ^
       -crypto AES256-SHA1 ^
       -ptype KRB5_NT_PRINCIPAL ^
       -pass ActualUserPassword123! ^
       -out C:\Users\YourName\Desktop\client.keytab ^
       -kvno 0

```

- **-princ**: The Kerberos principal (usually service/FQDN@REALM)
- **-mapuser**: AD username (can be service or regular user)
- **-crypto**: Encryption type
- **-out**: Path to save the keytab
- **-pass**: You must know the user's actual password
- **-kvno 0**: Lets the KDC auto-select the current Key Version Number

> Ktpass still needs to contact the KDC, you need to make sure DNS and time sync with the domain are correct.


#### 3.2.2 For MIT kerberos users(Linux):

For linux kerberos client, you can use the **ktutil** tool. Below is an example

```shell
# open ktutil shell
ktutil

# add an kerberos entry(a principal, password pair)
addent -password -p pliu@CASDDS.CASD -k 1 -e aes256-cts-hmac-sha1-96

# output the kerberos entry to a keytab file
wkt /home/pliu/pliu-user.keytab

# you can read the kerberos entry in a keytab file with read_kt command
read_kt /home/pliu/pliu-user.keytab

# the above command will add the content of the keytab in the ktutil cache. When you write the cache to a keytab file
# the content of all kerberos entry will be copied in the keytab file.

# quit the ktutil shell 
q

# test the keytab files
klist -k /home/pliu/pliu-user.keytab

# generate a ticket with the keytab
kinit -kt pliu-user.keytab pliu@CASDDS.CASD
```

- **-password**: prompt to ask user password
- **-p**: specify user principal
- **-k**: specify the key version number.
- **-e**: specify the encryption algorithm.

