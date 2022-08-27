---
title: Multi-Factor Authentication (MFA)
---

# Multi-factor Authentication (MFA)

Multi-factor Authentication, also known as MFA, and most commonly appearing in
the form of Two-factor Authentication (2FA) is the practice of requiring a user
to provide multiple pieces of evidence (such as passwords, one-time-codes etc.)
to be granted access to a service. There are many different methods which can
be used but not all of them are equal in terms of the protection they provide.

## SMS

SMS is considered to be a weak form of MFA, as it is susceptible to
[SIM Swapping Attacks](https://en.wikipedia.org/wiki/SIM_swap_scam). A quick
web-search will surface a number of SIM swapping attacks that have been
executed in the wild, often targeting, but not limited to, crypto-currency
holders. SMS for providers that support 2G may also be susceptible, as the
security of 2G networks is based on A5/1, a commonly-exploited implementation
of the A5 security protocol. Even if your phone supports a better standard, a
message downgrade attack may result in the message being replayed over 2G.

## TOTP

Time-based One Time Passwords (TOTP), are one of the more common authentication
methods which are relatively good compared to SMS, but still have some
weaknesses. TOTP is based on symmetric cryptography, which means the secret
used to generate codes is stored by both the client and the authentication
server, and can be leaked by being intercepted during the setup process or by
being improperly stored on the user's device.

Some examples of applications which generate TOTP codes are: Authy, Microsoft
Authenticator, Google Authenticator and most notably Yubico Authenticator.

Yubico Authenticator sets itself apart by allowing users to store their TOTP
secret on a yubikey, improving the way secrets are stored, as well as allowing
one to leverage additional protection measures such as yubikey's password, and
touch options.

## WebAuthn

WebAuthn is a protocol based on asymmetric cryptography, which is the clear
winner in terms of achieving reasonable security when it comes to MFA. Due to
the nature of asymmetric keys, only the client knows the private key; the
server can only verify that a signature was made by that key. Additionally,
WebAuthn implemented by a trusted program (such as a web browser) is not
vulnerable to phishing attacks, as it is cryptographically tied to an origin,
such as a domain name (like "github.com"). WebAuthn does a significantly better
job of protecting users compared to other available methods, particularly when
paired with a hardware token device, and is the recommended method which should
be used whenever available.

### When setting up MFA the user

* must use WebAuthn based authentication where available
* must disable other methods of MFA when WebAuthn is active
* should use a HSM to store WebAuthn credentials
* should back up WebAuthn MFA with a secondary HSM
* should use Yubico Authenticator when WebAuthn is not available

## Personal HSM Instructions

* [Personal HSMS Guide](./personal-hsms/_index.md)

### Github 2FA Setup

[Link to Edit 2FA on Github](https://github.com/settings/two_factor_authentication/configure)

![Setup 2FA on Github](/img/github-2fa.gif)
