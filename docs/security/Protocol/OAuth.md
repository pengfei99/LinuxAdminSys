# OAuth 2.0 

In this document, we will discuss:
- What OAuth is for?
- In which situation which we want to use OAuth.
- Best practices when using OAuth.

OAuth 2.0, which stands for “Open Authorization”, is a standard designed to allow a website or application to access 
resources hosted by other web apps on behalf of a user.

**OAuth 2.0 is an authorization protocol and NOT an authentication protocol**. As such, it is designed primarily 
as a means of granting access to a set of resources, for example, remote APIs or user data.

You can find the official doc of OAuth [here](https://oauth.net/2/).

You can find more details of the OAuth 2.0 authorization Framework [here](https://datatracker.ietf.org/doc/html/rfc6749).

## 1. Terminology

A simple version of the OAuth work flow is shown as below:

![oauth2_usecase_flow.png](../../../images/oauth2_usecase_flow.png)


### Client

The client is the system that requires access to the protected resources. To access resources, the Client must hold the appropriate Access Token.

### Resource Server

A server that protects the user’s resources (e.g. API-endpoints) and receives access requests from the Client. 
It accepts and validates an Access Token from the Client and returns the appropriate resources to it.

Only the `Owner(i.e. user or system)` of the protected resources and can grant access to them.

### Authorization Server

This server receives requests from the Client for Access Tokens. It issues them a token if the two condition is satisfied:
- **user successful authentication** 
- **authorization given by the Resource Owner**. 

The authorization server exposes two endpoints: 
- **Authorization endpoint**: it handles the interactive authentication and the authorization consent of the user
- **Token endpoint**: which is involved in a machine to machine interaction.

### Access token

**An Access Token is a piece of data that represents the authorization to access resources on behalf of the end-user**. 
OAuth 2.0 doesn’t define a specific format for Access Tokens. However, in some contexts, the JSON Web Token (JWT) 
format is often used. This enables token issuers to include data in the token itself. Also, for security reasons, 
Access Tokens may have an expiration date.

## 2. How Does OAuth 2.0 Work?

As we mentioned before, Oauth 2.0 is not an authentication protocol, but an authorization protocol. 
So the `Client must acquire its own credentials`(e.g. id and client), from the Authorization Server in order to 
identify and authenticate itself when requesting an Access Token.

OAuth is very often used to protect API endpoints. Imagine the below scenario `A user uses the browser to open a 
SPA (single page application), the SPA calls other APIs which are protected resources.`

The below image shows a detailed work flow of how OAuth works in a such scenario.

![oauth2_authorization_code_flow.png](../../../images/oauth2_authorization_code_flow.png)

## 3. Different Grant types

`Grant types defines a set of steps a Client (e.g. human, machine) has to perform to get resource access authorization`.
 For example, `a machine cannot type in its credentials or apply two factor authentication`. So OAuth provides several 
grant types to address different scenarios:

- **Authorization Code grant**: The Authorization server returns a single-use `Authorization Code` to the Client, 
      which is then exchanged for an `Access Token`. This is the best option for traditional web apps where the 
      exchange can securely happen on the server side. The Authorization Code flow might be used by Single Page 
      Apps (SPA) and mobile/native apps. However, here, the client secret cannot be stored securely, and so 
      authentication, during the exchange, is limited to the use of client id alone. `A better alternative is the 
      Authorization Code with PKCE grant`.
- **Authorization Code Grant with Proof Key for Code Exchange (PKCE)**: This authorization flow is similar to the 
      Authorization Code grant, but with additional steps that make it more secure for mobile/native apps and SPAs.

- **Implicit Grant**: A simplified flow where the Access Token is returned directly to the Client. In the Implicit 
   flow, the authorization server may return the Access Token as a parameter in the callback URI or as a response 
    to a form post. The first option is now deprecated due to potential token leakage.


- **Resource Owner Credentials Grant Type**: This grant requires the Client first to acquire the resource 
      owner’s credentials, which are passed to the Authorization server. It is, therefore, limited to Clients that 
       are completely trusted. It has the advantage that no redirect to the Authorization server is involved, 
       so it is applicable in the use cases where a redirect is infeasible.

- **Client Credentials Grant Type**: Used for non-interactive applications e.g., automated 
     processes, microservices, etc. In this case, the application is authenticated per se by using its client id and secret.

- **Device Authorization Flow**: A grant that enables use by apps on input-constrained devices, such as smart TVs.

- **Refresh Token Grant**: The flow that involves the exchange of a Refresh Token for a new Access Token.

## The access token

`An access token can be anything which stores the user's access rights. In most cases, we use a JWT (JSON Web Token) as access token.

This is what a JWT looks like:

```text
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

Note it has dots. These dots separate the three sections of the token:

- the header
- the payload
- the signature

All of these parts are base64 encoded JSON. You can use [https://jwt.io/](https://jwt.io/) to parse the above JWT.

### The header
When you base64 decode `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9`, this is what you get:

```text
{
  "alg": "HS256",
  "typ": "JWT"
}

```

### The payload
When you base64 decode `eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ`, then this is what you get:

```text
{
 "sub": "1234567890",
 "name": "John Doe",
 "iat": 1516239022
}
```

Note that the payload of the token contains the user-details.

### The signature

The third section of the token is the signature of the token. Everybody can read and create a token. 
So it’s important to validate if the token an API receives has not been tampered with. The signature
signs the content of the token with a secret which can be used to verify the authenticity of the token.

Below is an example, the first parameter is the algo which generates the signature(e.g. HMACSHA256). The content which
apply the algo on is `base64UrlEncode(header) + "." + base64UrlEncode(payload), your-256-bit-secret`. 
```text
HMACSHA256(
  base64UrlEncode(header) + "." +
  base64UrlEncode(payload),
  your-256-bit-secret
)
```

> So if someone try to modify the header or payload, he must know your secret to generate the new signature.

## 4. Session management

When a user has a token, the user can access resources. But at a given moment in time, the user must sign out.

To “sign out” correctly, it is important to understand the difference between the role of the authorization server and the access_token:

- A token is valid for a given period of time, for a specific client
- An authorization server issues tokens
- An authorization server may issue several tokens to several clients for the same end-user
- Depending on the client type (e.g. human or machine)  is signing in, there may be an active user-session 
    on the authorization sever. This is how Single Sign-On works: If the user has authenticated before, 
     the token is issued directly without asking the user to authenticate.

This means to sign-out successfully, from a functional perspective, you must:

- Revoke any token that has been issued
- End the user-session on the authorization server

## 5. Best practice

- **You should never implement an OAuth server yourself.**
- Use an Identity Provider as a service. (e.g. Ldap, Active Directory, etc.)
- Use an OpenID Connect approved implementation here.
- Furthermore, choose carefully which grant type applies in your case. Consider carefully what the 
  likeliness of it being hacked is, and what the impact is.



