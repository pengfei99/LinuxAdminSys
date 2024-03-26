# OAuth 2.0 

In this document, we will discuss:
- What OAuth is for?
- In which situation which we want to use OAuth.
- Best practices when using OAuth.

OAuth 2.0, which stands for “Open Authorization”, is a standard designed to allow a website or application to access 
resources hosted by other web apps on behalf of a user.

**OAuth 2.0 is an authorization protocol and NOT an authentication protocol**. As such, it is designed primarily 
as a means of granting access to a set of resources, for example, remote APIs or user data.

You can find the official doc of OAuth [here](https://oauth.net/2/)

## Terminology

### Client

The client is the system that requires access to the protected resources. To access resources, the Client must hold the appropriate Access Token.

### Resource Owner

The user or system that owns the protected resources and can grant access to them.

### Access token

**An Access Token is a piece of data that represents the authorization to access resources on behalf of the end-user**. 
OAuth 2.0 doesn’t define a specific format for Access Tokens. However, in some contexts, the JSON Web Token (JWT) 
format is often used. This enables token issuers to include data in the token itself. Also, for security reasons, 
Access Tokens may have an expiration date.

## OAuth 2.0 Framework (RFC 6749)

You can find more details of the OAuth 2.0 authorization Framework [here](https://datatracker.ietf.org/doc/html/rfc6749).

The OAuth 2.0 authorization framework enables a third-party application to obtain limited access to 
an HTTP service, either on behalf of a resource owner by orchestrating an approval interaction
between the resource owner and the HTTP service, or by allowing the third-party application to obtain access on 
its own behalf

###

