---
title: Multi-Factor Authentication (MFA)
---

# Multi-factor Authentication (MFA)
Multi-factor Authentication, also known as MFA, and most commonly appearing in the form of Two-factor Authentication (2FA) is the practice of requiring a user to provide multiple pieces of evidence (such as passwords, one-time-codes etc.) to be granted access to a service. There are many different methods which can be used but not all of them are equal in terms of the protection they provide.

## SMS
SMS is considered to be a weak form of MFA, as it is susceptible to [SIM Swapping Attacks](https://en.wikipedia.org/wiki/SIM_swap_scam). A quick web-search will surface a number of SIM swapping attacks that have been executed in the wild, often targeting, but not limited to, crypto-currency holders.

## TOTP
Time-based One Time Passwords (TOTP), are one of the more common authentication methods which are relatively good compared to SMS, but still have some weaknesses. TOTP is based on asymmetric cryptography, which means the secret used to generate codes is stored in multiple locations, and is also subject to being intercepted during the setup process, as well as at later points in time while stored on the user's device.

Some examples of applications which generate TOTP codes are: Authy, Microsoft Authenticator, Google Authenticator and most notably Yubico Authenticator.

Yubico Authenticator sets itself apart by allowing users to store their TOTP secret on a yubikey, improving the way secrets are stored, as well as allowing one to leverage additional protection measures such as yubikey's password, and touch options.

## FIDO
FIDO is a family of authentication protocols based on asymmetric cryptography, which is the clear winner in terms of achieving reasonable security when it comes to MFA. U2F, UAF and FIDO2 all do a significantly better job of protecting users compared to the other available methods, particularly when paired with a hardware token device, and is the recommended method which should be used whenever available.

## When setting up MFA the user
* must use FIDO based authentication where available
* must disable other methods of MFA when FIDO is active
* must use a HSM to store FIDO credentials
* should back up FIDO MFA with a secondary HSM
* should use Yubico Authenticator when FIDO is not available

## Personal HSM Instructions

### Github 2FA Setup

[Link to Edit 2FA on Github](https://github.com/settings/two_factor_authentication/configure)

![Setup 2FA on Github](/img/github-2fa.gif)
