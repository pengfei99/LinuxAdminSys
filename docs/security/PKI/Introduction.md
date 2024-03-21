#  PKI (Public Key Infrastructure)

PKI stands for **Public Key Infrastructure**. It is `a framework of policies, procedures, and technologies designed to 
manage digital keys and certificates securely`. PKI enables `secure communication` and `digital signatures` over the 
Internet and other communication networks. The core components of a PKI include:

- **Public and Private Key Pairs**: PKI uses `asymmetric cryptography`, where each entity has a pair of 
    cryptographic keys - a public key and a private key. The public key is shared openly, while the private key 
    is kept confidential.

- **Digital Certificates**: These are electronic documents that `bind an individual's or organization's identity to 
     their public key`. Certificates are issued by trusted entities known as `Certificate Authorities (CAs)`.

- **Certificate Authorities (CAs)**: CAs are trusted organizations that issue digital certificates. They verify 
     the identity of individuals, servers, or other entities and vouch for the authenticity of their public keys.

- **Registration Authorities (RAs)**: RAs act as verification entities that confirm the identity of individuals 
      or entities before the CA issues a digital certificate.

- **Certificate Revocation Lists (CRLs)**: CRLs are lists maintained by CAs that contain information about 
      certificates that have been revoked before their expiration date.

- **Public and Private Key Management**: PKI provides a framework for the secure generation, storage, distribution, 
       and revocation of public and private key pairs.


## 7.5 Standards and formats

There are several standards and formats related to the `public key infrastructure (PKI)`, each serving different 
purposes. Below are some examples:

- **PKCS#7 (Cryptographic Message Syntax)**: Defines a standard syntax for data that may have cryptography applied 
    to it, such as digital signatures and encryption. It's often used for encoding and signing messages.

- **PKCS#11 (Cryptographic Token Interface)**: Defines an API for accessing cryptographic tokens, such as hardware 
     security modules (HSMs) and smart cards. It allows applications to interact with cryptographic devices.

- **PKCS#12 (Public Key Cryptography Standards #12)**: is a standard that defines a file format commonly used to store 
     private keys with their corresponding public key certificates, protected by a password-based symmetric key. It is often used for securely exchanging public and private key pairs between different systems.

- **X.509**: A standard that defines the format of public key certificates. It's commonly used in various internet 
       protocols like SSL/TLS and provides a standardized way to represent and exchange public key information.

- **PEM (Privacy-Enhanced Mail)**: A format that is often used to encode X.509 certificates and private keys in a 
    text-based format. It's commonly used in various contexts, including SSL/TLS.

- **CMS (Cryptographic Message Syntax)**: An IETF standard that is similar to PKCS#7 and is used for securing 
     messages by applying digital signatures, encryption, and other cryptographic operations.

- **SPKI (Simple Public Key Infrastructure)**: A more lightweight approach to PKI that focuses on simplicity. 
    It's designed to be more flexible and scalable than traditional PKI.

- **ACME (Automated Certificate Management Environment)**: An IETF standard protocol designed to automate the 
      issuance and renewal of X.509 certificates, typically used in the context of web servers and HTTPS.

- **JWT (JSON Web Tokens)**: A compact, URL-safe means of representing claims to be transferred between two parties. 
       While not directly related to PKI, it's often used in authentication and authorization processes.

- **OCSP (Online Certificate Status Protocol)**: A protocol used to obtain the revocation status of an X.509 digital 
       certificate. It's used to check whether a certificate is still considered valid.

- **CRL (Certificate Revocation List)**: A list of digital certificates that have been revoked by the 
      issuing Certificate Authority (CA) before their scheduled expiration date.

### More details about the format

A complete doc can be found [here](https://www.sslmarket.fr/ssl/help-la-difference-entre-certificats)

#### PEM format

**PEM (Privacy Enhanced Mail)** is a widely used format for storing and sharing cryptographic objects such 
as `X.509 certificates, private keys`, and other related information. PEM files are typically 
**ASCII-encoded, with a header, the data, and a footer**. Below is a general template for a PEM-encoded X.509 certificate:

```shell
-----BEGIN CERTIFICATE-----
<base64-encoded certificate data>
-----END CERTIFICATE-----
```
The general file extension are: `.cer, .crt, .pem` for certificate or  `.key` for private key.

#### DER format

The X.509 certificate is typically encoded in binary `DER (Distinguished Encoding Rules) format`. DER is a standard 
for encoding data structures defined by the `Abstract Syntax Notation One (ASN.1) standard`.

You can convert a PEM format certificate

```shell
openssl x509 -in certificate.pem -outform der -out certificate.der
```

#### PKCS#12

PKCS#12 is a standard that defines a `file format commonly used to store private keys with their corresponding public 
key certificates`, protected by a password-based symmetric key. It is often used for securely exchanging public and 
private key pairs between different systems.

PKCS#12 files typically have a ".p12" or ".pfx" extension. They can store not only the private key and corresponding 
public key certificate but also additional certificates forming a chain of trust.

```shell
# generate a pkcs11 () from private key and certificate in .pem format
openssl pkcs12 -export -inkey wildcard-casd.key  -in wildcard-casd.pem  -out /tmp/final_result.pfx

# you can also provide the chain certificate
openssl pkcs12 -export -inkey your_private_key.key -in your_certificate.cer -certfile your_chain.pem -out final_result.pfx

# check the content of the pkcs11 file
openssl pkcs12 -noout -info -in /tmp/final_result.pfx
```

#### jks

In java

```shell
# generate a keystore in .jks format from .pfx 
keytool -importkeystore -destkeystore /tmp/keystore.jks -srcstoretype PKCS12 -srckeystore /tmp/final_result.pfx

# Import Connected System Root Certificate to Keystore
keytool -importcert -file connectedSystemRoot.cer -keystore keystore.jks -alias "Connected System Name"
```
https://www.wowza.com/docs/how-to-import-an-existing-ssl-certificate-and-private-key#:~:text=You%20can't%20directly%20import,12%20file%20into%20your%20keystore.

