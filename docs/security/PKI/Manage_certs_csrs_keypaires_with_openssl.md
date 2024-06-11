# Managing certs, csrs, keypairs with openSSL


**OpenSSL is a versatile command line tool that can be used for a large variety of tasks related to Public Key Infrastructure (PKI)**
and HTTPS (HTTP over TLS). This cheat sheet style guide provides a quick reference to OpenSSL commands that are useful 
in common, everyday scenarios. This includes OpenSSL examples of generating private keys, certificate signing requests, 
and certificate format conversion. It does not cover all the uses of OpenSSL.

## 1. Certificate Signing Requests (CSRs) 

If you would like to obtain an SSL certificate from a `certificate authority (CA)`, you must generate a certificate `signing request (CSR)`. 
A CSR consists mainly of the `public key` of a key pair, and some additional information. Both of these 
components are inserted into the certificate when it is signed.

Whenever you generate a CSR, you will be prompted to provide information regarding the certificate. This 
information is known as a `Distinguised Name (DN)`. An important field in the DN is the `Common Name (CN)`, which 
should be the exact `Fully Qualified Domain Name (FQDN) of the host` that you intend to use the certificate with. 
It is also possible to skip the interactive prompts when creating a CSR by passing the information via command line or from a file.

The other items in a DN provide additional information about your business or organization. If you are purchasing an 
SSL certificate from a certificate authority, it is often required that these additional fields, such as "Organization", 
accurately reflect your organization's details.

Here is an example of what the CSR information prompt will look like:

```shell
---
Country Name (2 letter code) [AU]:US
State or Province Name (full name) [Some-State]:New York
Locality Name (eg, city) []:Brooklyn
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Example Brooklyn Company
Organizational Unit Name (eg, section) []:Technology Division
Common Name (e.g. server FQDN or YOUR name) []:examplebrooklyn.com
Email Address []:

```

### 1.1 Generating a csr without a private key

Use this method if you want to use HTTPS (HTTP over TLS) to secure your Apache HTTP or Nginx web server, 
and you want to use a Certificate Authority (CA) to issue the SSL certificate. The CSR that is generated can be 
sent to a CA to request the issuance of a CA-signed SSL certificate. 
If your CA supports SHA-2, add the -sha256 option to sign the CSR with SHA-2.

This command creates a 2048-bit private key (domain.key) and a CSR (domain.csr) from scratch:

```shell
openssl req \
       -newkey rsa:2048 -nodes -keyout domain.key \
       -out domain.csr
```

Answer the CSR information prompt to complete the process.

The `-newkey rsa:2048` option specifies that the key should be 2048-bit, generated using the RSA algorithm. 
The `-nodes` option specifies that the private key should not be encrypted with a pass phrase. The `-new` option, 
which is not included here but implied, indicates that a CSR is being generated.

### 1.2 Generating a csr with a private key 

This command creates a new CSR (domain.csr) based on an existing private key (domain.key):

```shell
openssl req \
       -key domain.key \
       -new -out domain.csr
```

Answer the CSR information prompt to complete the process.

The `-key` option specifies an existing private key (domain.key) that will be used to generate a new CSR. 
The `-new` option indicates that a CSR is being generated.


### 1.3 Generate a CSR from an Existing Certificate and Private Key 

Use this method if you want to renew an existing certificate but you or your CA do not have the original CSR for some 
reason. It basically saves you the trouble of re-entering the CSR information, as it extracts that information from the existing certificate.

This command creates a new CSR (domain.csr) based on an existing certificate (domain.crt) and private key (domain.key):

```shell
openssl x509 \
       -in domain.crt \
       -signkey domain.key \
       -x509toreq -out domain.csr
```

The `-x509toreq` option specifies that you are using an X509 certificate to make a CSR.

 Generating SSL Certificates (self - signed) 

Use this method if you want to use HTTPS (HTTP over TLS) to secure your Apache HTTP or Nginx web server, and you do not require that your certificate is signed by a CA.

This command creates a 2048-bit private key (domain.key) and a self-signed certificate (domain.crt) from scratch:

```shell
openssl req \
       -newkey rsa:2048 -nodes -keyout domain.key \
       -x509 -days 365 -out domain.crt
```

Answer the CSR information prompt to complete the process.

The `-x509` option tells req to create a self-signed cerificate. 
The `-days 365` option specifies that the certificate will be valid for 365 days. 
A temporary CSR is generated to gather information to associate with the certificate.

## 2. Certificate

### 2.1 Generate a Self-Signed Certificate from an Existing Private Key 

Use this method if you already have a private key that you would like to generate a self-signed certificate with it.

This command creates a self-signed certificate (domain.crt) from an existing private key (domain.key):

```shell
openssl req \
       -key domain.key \
       -new \
       -x509 -days 365 -out domain.crt
```

### 2.2 Generate a Self-Signed Certificate from an Existing Private Key and CSR 

Use this method if you already have a private key and CSR, and you want to generate a self-signed certificate with them.

This command creates a self-signed certificate (domain.crt) from an existing private key (domain.key) and (domain.csr):


```shell
openssl x509 \
       -signkey domain.key \
       -in domain.csr \
       -req -days 365 -out domain.crt
```

The `-days 365` option specifies that the certificate will be valid for 365 days.

## 3. View Certificate, keys, csrs 

Certificate and CSR files are encoded in PEM format, which is not readily human-readable.

This section covers OpenSSL commands that will output the actual entries of PEM-encoded files.

### 3.1 View CSR Entries 

This command allows you to view and verify the contents of a CSR (domain.csr) in plain text:

```shell
openssl req -text -noout -verify -in domain.csr
```

### 3.2 View Certificate Entries 

This command allows you to view the contents of a certificate(domain.crt) in plain text:

```shell
openssl x509 -text -noout -in domain.crt
```

### 3.3 Verify a Certificate was signed by a CA 

Use this command to verify that a certificate (domain.crt) was signed by a specific CA certificate (ca.crt):

```shell
Openssl verify -verboose -CAFile ca.crt domain.crt
```

## 4. Private Keys 

This section covers OpenSSL commands that are specific to creating and verifying private keys.

### 4.1 Create a Private Key 

Use this command to create a password-protected, 2048-bit private key (domain.key):

```shell
openssl genrsa -des3 -out domain.key 2048
```
Enter a password when prompted to complete the process.

### 4.2 Verify a Private Key 

Use this command to check that a private key (domain.key) is a valid key:

```shell
openssl rsa -check -in domain.key
```

If your private key is encrypted, you will be prompted for its pass phrase. Upon success, the unencrypted key will be output on the terminal.


### 4.3 Verify a Private Key Matches a Certificate and CSR 

Use these commands to verify if a private key (domain.key) matches a certificate (domain.crt) and CSR (domain.csr):

```shell
openssl rsa -noout -modulus -in domain.key | openssl md5
# don't know what to do with this
openssl x509 -noout -modulus -in domain.crt | openssl md5
# output certificat with text format
openssl x509 -noout -in ldap.crt -text
#
openssl req -noout -modulus -in domain.csr | openssl md5
```

If the output of each command is identical there is an extremely high probability that the private key, certificate, and CSR are related.

### 4.4 Encrypt a Private Key 

This takes an unencrypted private key (unencrypted.key) and outputs an encrypted version of it (encrypted.key):

```shell
openssl rsa -des3 \
       -in unencrypted.key \
       -out encrypted.key
```

Enter your desired pass phrase, to encrypt the private key with.

### 4.5 Decrypt a Private Key 

This takes an encrypted private key (encrypted.key) and outputs a decrypted version of it (decrypted.key):

```shell
openssl rsa \
       -in encrypted.key \
       -out decrypted.key
```

## 5 Convert certificate Formats 

All of the certificates that we have been working with have been X.509 certificates that are ASCII PEM encoded. There are a variety of other certificate encoding and container types; some applications prefer certain formats over others. Also, many of these formats can contain multiple items, such as a private key, certificate, and CA certificate, in a single file.

OpenSSL can be used to convert certificates to and from a large variety of these formats. This section will cover a some of the possible conversions.

### 5.1 Convert PEM to DER 

Use this command if you want to convert a PEM-encoded certificate (domain.crt) to a DER-encoded certificate (domain.der), a binary format:

```shell
openssl x509 \
       -in domain.crt \
       -outform der -out domain.der
```

The DER format is typically used with Java.

### 5.2 Convert DER to PEM 

Use this command if you want to convert a DER-encoded certificate (domain.der) to a PEM-encoded certificate (domain.crt):

```shell
openssl x509 \
       -inform der -in domain.der \
       -out domain.crt
```

### 5.3 Convert PEM to PKCS7 

Use this command if you want to add PEM certificates (domain.crt and ca-chain.crt) to a PKCS7 file (domain.p7b):

```shell
openssl crl2pkcs7 -nocrl \
       -certfile domain.crt \
       -certfile ca-chain.crt \
       -out domain.p7b
```

Note that you can use one or more -certfile options to specify which certificates to add to the PKCS7 file.

PKCS7 files, also known as P7B, are typically used in Java Keystores and Microsoft IIS (Windows). They are ASCII files which can contain certificates and CA certificates.

### 5.4 Convert PKCS7 to PEM 

Use this command if you want to convert a PKCS7 file (domain.p7b) to a PEM file:

```shell
openssl pkcs7 \
       -in domain.p7b \
       -print_certs -out domain.crt
```

Note that if your PKCS7 file has multiple items in it (e.g. a certificate and a CA intermediate certificate), the PEM file that is created will contain all of the items in it.

### 5.5 Convert PEM to PKCS12 

Use this command if you want to take a private key (domain.key) and a certificate (domain.crt), and combine them into a PKCS12 file (domain.pfx):

```shell
openssl pkcs12 \
       -inkey domain.key \
       -in domain.crt \
       -export -out domain.pfx
```
You will be prompted for export passwords, which you may leave blank. Note that you may add a chain of certificates to the PKCS12 file by concatenating the certificates together in a single PEM file (domain.crt) in this case.

PKCS12 files, also known as PFX files, are typically used for importing and exporting certificate chains in Micrsoft IIS (Windows).

### 5.6 Convert PKCS12 to PEM 

Use this command if you want to convert a PKCS12 file (domain.pfx) and convert it to PEM format (domain.combined.crt):

```shell
openssl pkcs12 \
       -in domain.pfx \
       -nodes -out domain.combined.crt
```
Note that if your PKCS12 file has multiple items in it (e.g. a certificate and private key), the PEM file that is created will contain all of the items in it.


## OpenSSL Version 

The openssl version command can be used to check which version you are running. The version of OpenSSL that you are 
running, and the options it was compiled with affect the capabilities (and sometimes the command line options) that are available to you.

The following command displays the OpenSSL version that you are running, and all of the options that it was compiled with:

```shell
openssl version -a
```


