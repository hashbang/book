# Web of Trust
## Overview
Unlike a government issued identity, in a global society, people can identify
each other with cryptography.

In a Web of Trust system, peers validate the identity of other peers. This
forms a network of reputation. This system is modeled after real life trust
systems, such as the 5-star rating for restaurants.

Core concepts we'll be showing is how to use GnuPG to share your digital
identity, digitally sign the identities of others, and receive signatures
from others.

## Sharing your Keys
After generating your keys from either the [Simple](link) or [Advanced](link)
steps, you will want to publish your keys so others can find them.

Currently, there are 4 popular ways of sharing keys.
* OpenPGP Key servers (SKS and Hagrid)
* DNS Records
  * PKA Records
  * PGP Cert Records
  * IPGP Cert Records
* Keybase
* WKD - Web Key Directory

Most common way to share keys is publishing to key servers.

Key servers will eventually share data between each other, so generally if you
publish to one server, the rest will receive at some point. These servers are
old and not well maintained, so it may be best practice to publish to multiple
servers anyhow.


1. Obtain your pgp key fingerprint
```
gpg --list-keys youremail@domain.com
```
Note: your fingerprint will be a 40 character string

2. Share your key with a key server

### Popular Servers
* keyserver.ubuntu.com
* pgp.mit.edu
* keys.gnupg.net
* keys2.kfwebs.net

```
gpg \
  --keyserver keys.gnupg.net \
  --send-keys ABCDEF0123456789ABCDEF0123456789ABCEDF01
```

## Importing Signatures
There are different conventions for sharing signatures. Some people that sign
your key may opt to publish the signatures to key servers on your behalf. If
someone has chosen to do this, then you are all set and don't need to do
anything. That said, there are very good reasons as to why that is bad
practice, unless you know someone very well and have your permission.

When dealing with a stranger, or just to use best practices, you want to prove
they own the email address linked to their keychain as well as proving they
actually control the key they said is theirs.

A common method of doing this is signing someone's individual email addresses
in their keys (called UIDs), encrypting the signature data to the claimed
keychain, then emailing those signature "packets" to each email address listed.
These steps prove they own the email address and can decrypt data sent to that
key. These practices avoid you being tricked into signing a key owned by
someone else.

If someone has emailed you encrypted signatures, you can decrypt, import,
and publish them as follows:

1. Download any encrypted signatures from your email.
  Encrypted files will almost always ends in .asc, however, these steps will
  work regardless of how the file is named.

2. Import key of individual who signed you

```
gpg --recv-keys ABCDEF0123456789ABCDEF0123456789ABCEDF01

```

3. Decrypt and import signature file

```
gpg --decrypt encrypted.asc | gpg --import
```

4. Verify new signature

```
gpg --list-sigs youremail@domain.com
```

5. Publish new signature
```
gpg \
  --keyserver keyserver.ubuntu.com \
  --send-keys ABCDEF0123456789ABCDEF0123456789ABCEDF01
```

## Creating Signatures
To sign another person's key you will need your Master Key which is the only
one with the Certify permission on your keychain. The Certify permission allows
you to certify a change to your key or a signature added to someone else's.

If you followed our Simple steps for setting up a GPG smartcard, then your
certified key is on the card you use everyday.

If you followed the Advanced steps, your certified key is likely on another
GPG smartcard than the one you use everyday.

2. Import key to be signed

```
gpg --recv-keys ABCDEF0123456789ABCDEF0123456789ABCEDF01
```

3. Sign key

```
gpg --ask-cert-level --sign-key ABCDEF0123456789ABCDEF0123456789ABCEDF01
```

4. Encrypt signature

```
gpg --export theiremail@domain.com \
  | gpg \
    --sign \
    --encrypt \
    --armor \
    --recipient ABCDEF0123456789ABCDEF0123456789ABCEDF01 \
  > encryptedsig.asc
```

5. Email encrypted file with signature to signee

## References
https://gpg.wtf
