---
weight: 4
---

# Asymmetric Encryption

**Note:** This is a long section. It provides a lot of examples, but should
cover most practical use cases of asymmetric encryption. Most examples in this
section were made using Sequoia-OpenPGP's CLI tool `sq`.

**Note:** The term "public key" is often used in place of "certificate" mostly
for compatibility with existing documentation, but from a technical point,
the referenced file is a certificate containing public keys, user IDs, and
certifying signatures.

While symmetric encryption offers the ability to encrypt things where all
involved parties are aware of the encryption key, there is often a time when
there is no secure channel between parties and a secure channel must be
established. Asymmetric encryption typically involves two components, a public
key and a private key. The public key can and should be shared as much as
possible, but the private key should only ever be controlled by the party the
key belongs to.

The best way to distribute a public key is to share it on as many platforms as
possible. Projects such as [keyoxide] let you cryptographically link your
social media accounts and online profiles to an [OpenPGP] key. This way, people
don't need to contact you directly - while they can't reasonably be sure that
just your GitHub (for example) got hacked, they can be pretty sure that _all_
of your online presence hasn't been hacked.

OpenPGP keys are stored with User IDs attached, which may contain email
addressess. This makes it possible to look up keys by email address using
[WKD], or Web Key Directory. While it can't verify that the key belongs to the
person associated with that email, it can confirm that the owner of the email
domain trusts that the key belongs to the person associated with that email.

Keys can also be shared with [keyservers], to allow retrieval by fingerprint
if a username is not provided, or if a fingerprint for a key is known. If a key
exists on a keyserver, you can use a secure, low-bandwidth channel to transmit
the fingerprint. The recipient can then use the keyserver to retrieve the keys.
This allows for sharing keys using QR codes, messaging platforms, or other
methods of communication.

## Generating a Key

This example will create an OpenPGP asymmetric keypair and revocation
certificate. The revocation certificate, placed in the `.rev` file named
similarly to your export file, can be used to announce a revocation of the key
in case it is compromised (leaked, lost, compromised, etc.).  We will also send
the public portion of the key to a keyserver.

```sh
$ sq key generate --userid "<ryan@hashbang.sh>" --export ryan.key.pgp
$ sq keyserver send ryan.key.pgp
```

Currently, the private key and public key are stored in the same file. To make
sure we don't accidentally upload the key somewhere we don't want to, let's
extract it to a file:

```sh
$ sq key extract-cert ryan.key.pgp > ryan.pgp
```

A "cert", or "certificate", is considered the public portion of the key. We can
inspect the content of a certificate by using the `sq inspect` command:

```sh
$ sq inspect ryan.cert.pgp
ryan.cert.pgp: OpenPGP Certificate.

    Fingerprint: 2D921EF844D031888D5671EF6C20BB1F556DBBFC
Public-key algo: EdDSA
Public-key size: 256 bits
  Creation time: 2022-08-26 09:56:39 UTC
Expiration time: 2025-08-26 03:23:00 UTC (creation time + P1095DT62781S)
      Key flags: certification

         Subkey: 7F263FCCE5B1EFDADE24F46864D06788ABD29369
Public-key algo: EdDSA
Public-key size: 256 bits
  Creation time: 2022-08-26 09:56:39 UTC
Expiration time: 2025-08-26 03:23:00 UTC (creation time + P1095DT62781S)
      Key flags: signing

         Subkey: BBA71E50239AA2265A5490F6CE381BFEC1C47131
Public-key algo: EdDSA
Public-key size: 256 bits
  Creation time: 2022-08-26 09:56:39 UTC
Expiration time: 2025-08-26 03:23:00 UTC (creation time + P1095DT62781S)
      Key flags: authentication

         Subkey: 6F29D8EEA1C4267D5F79402861DA2C4164D8DCF1
Public-key algo: ECDH
Public-key size: 256 bits
  Creation time: 2022-08-26 09:56:39 UTC
Expiration time: 2025-08-26 03:23:00 UTC (creation time + P1095DT62781S)
      Key flags: transport encryption, data-at-rest encryption

         UserID: <ryan@hashbang.sh>
```

We can then share the fingerprint using trusted channels, or by creating
[keyoxide] proofs, or by using qrencode so people can scan and import your
QR code. The key can be [uploaded to GitHub] [or GitLab] (note: these services
will call it a GPG key, when the keys they are referencing can be used with any
software supporting OpenPGP), or used in whatever fashion you prefer.

## Receiving Someone Else's Public Key

This assumes that you have taken reasonable measures to ensure that the
fingerprint of the key you want to receive is correct, such as contacting them
on at least two separate forms of messaging (to avoid only needing one to
compromise) or meeting them in-person.

```sh
$ sq keyserver get 88823A75ECAA786B0FF38B148E401478A3FBEF72 > ryan.pgp
```

## Encrypting to a Public Key

This will encrypt the message "hello world" to a given PGP key. The encrypted
message can then be sent over an insecure channel (such as email), and then
be decrypted by the recipient.

```sh
$ echo "hello world" | sq encrypt --recipient-cert ryan.pgp
-----BEGIN PGP MESSAGE-----

wV4DYdosQWTY3PESAQdAin31E8xzfgTozGK9q7UOj6RcVI1JIGtuLAoYbdn+KkEw
kJpsNOGb8tojWLVv3iIyNeSJC7ziJhCgwzVluWoSBHYn6Uf9Rq/0Yyx0rNgjkljY
0kUB+b2+kSBHgegeadzm2sRQCGMbqd1OJ8QDk0YzOMlTg8/Mo5UVun00pNAwELsK
0kt0GnmuXvRoyxYyTbW2FfriQosdF2M=
=ZiVw
-----END PGP MESSAGE-----
```

## Decrypting a Message with a Private Key

The message that was previously sent can be decrypted using the private key
associated with the certificate/public key.

```sh
$ sq decrypt --recipient-key ryan.key.pgp
-----BEGIN PGP MESSAGE-----

wV4DYdosQWTY3PESAQdAin31E8xzfgTozGK9q7UOj6RcVI1JIGtuLAoYbdn+KkEw
kJpsNOGb8tojWLVv3iIyNeSJC7ziJhCgwzVluWoSBHYn6Uf9Rq/0Yyx0rNgjkljY
0kUB+b2+kSBHgegeadzm2sRQCGMbqd1OJ8QDk0YzOMlTg8/Mo5UVun00pNAwELsK
0kt0GnmuXvRoyxYyTbW2FfriQosdF2M=
=ZiVw
-----END PGP MESSAGE-----
Encrypted using AES-256
Compressed using ZIP
hello world
```


---

* [keyoxide]: a decentralized way of notating keys with online account
  references by storing account information on the certificate itself.
* [OpenPGP]: not to be confused with any specific software, OpenPGP is a set of
  standards defining message formats, acceptable algorithms, and interactions
  between cryptographic primitives.
* [WKD]: a pattern of loading keys from a web host, typically hosted by the
  owner of the domain name or email provider.
* [keyservers]: software hosted by a (usually, untrsuted) third party that
  organizes keys 

[keyoxide]: https://keyoxide.org/
[OpenPGP]: https://en.wikipedia.org/wiki/Pretty_Good_Privacy#OpenPGP
[WKD]: https://wiki.gnupg.org/WKD
[keyservers]: https://keys.openpgp.org/about
[uploaded to GitHub]: https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account
[or GitLab]: https://docs.gitlab.com/ee/user/project/repository/gpg_signed_commits/#add-a-gpg-key-to-your-account
