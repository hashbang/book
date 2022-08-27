---
weight: 6
---

# Signing

**Note:** The examples here build off of the keys that have been set up in the
Asymmetric Encryption example.

In most forms of conversation, a signature is used to demonstrate that a
document has been acknowledged by a specific person. The same terminology can
be applied cryptographically, by producing a tamper-proof and forgery-proof
cryptographic signature to a document, that can be verified using the public
key associated with the person who made the signature.

## Example: Creating a Signature

These examples will assume there's a file `file.txt`.

This creates a signature using the signing key in `ryan.key.pgp`:

```sh
$ sq sign --signer-key ryan.key.pgp file.txt | tee file.txt.asc
-----BEGIN PGP MESSAGE-----

xA0DAAoWZNBniKvSk2kByxJiAAAAAABoZWxsbyB3b3JsZArCvQQAFgoAbwWCYwix
VgkQZNBniKvSk2lHFAAAAAAAHgAgc2FsdEBub3RhdGlvbnMuc2VxdW9pYS1wZ3Au
b3JnmSu4qdvyDGeNq7A0H2Y29vhaqfxcm1WoHRb1N03CC7oWIQR/Jj/M5bHv2t4k
9Ghk0GeIq9KTaQAA4HgBAPMjOGBH11cT9EOlMiKVeIXMtt/N1WMOTDA8Ar3MaNv1
AP9HTOybtl0SsX1fxPiFrKpDE4ZaAhU/1InSiVJ/9vtJDw==
=Dhba
-----END PGP MESSAGE-----
```

Note that, in this format, the entire document including the signature is
contained within the PGP message. This means work is required to get the data
to a usable state, but does mean that it is implied you should verify the
attached signature.

## Example: Creating a Detached Signature

This creates a "detached" signature, which can be stored separately of the
file being signed:

```sh
$ sq sign --signer-key ryan.key.pgp --detached file.txt | tee file.txt-detached.asc
-----BEGIN PGP SIGNATURE-----

wr0EABYKAG8FgmMIsgAJEGTQZ4ir0pNpRxQAAAAAAB4AIHNhbHRAbm90YXRpb25z
LnNlcXVvaWEtcGdwLm9yZ5yDIK+yclFG1Wv6ybLGvPqtnoFs3EaPzHDNC749l9LN
FiEEfyY/zOWx79reJPRoZNBniKvSk2kAAJwMAQCfD3WKYS1gOe6ZOyke02LWaUdb
p7r0L4STzvSRs/DEsAD+P2OcTrssCpzashYW5rkMhniQmVp27y55an3W8fQl5A0=
=rjlE
-----END PGP SIGNATURE-----
```

The signature can then be shipped _alongside_ the original document, leaving
the original document in plaintext. While this method can be seen as more
convenient, it removes the implication that the document should be verified.


## Example: Verifying Signatures with `sq`

This verifies a document that has the signature included in the entire message,
so the `--detached` flag was not used when creating the message.

```sh
$ sq verify --signer-cert ryan.pgp file.txt.asc | tee file2.txt
Good signature from 64D06788ABD29369
hello world
1 good signature.
$ diff file.txt file2.txt
```

## Example: Verifying Detached Signatures with `sq`

This verifies a document that has a detached signature, which was created using
the `--detached` flag.

```sh
$ sq verify --signer-cert ryan.pub --detached file.txt-detached.asc file.txt
Good signature from 64D06788ABD29369
1 good signature.
```

## Example: Verifying Detached Signatures with `sqv`

The `sqv` command line, also from Sequoia, is a lighter-weight alternative to
the `sq` command, but can only verify detached signatures.

```sh
$ sqv --keyring ryan.pgp file.txt-detached.asc file.txt
2D921EF844D031888D5671EF6C20BB1F556DBBFC
```

Additionally, it prints out the fingerprints of the keys with valid signatures.
If multiple signatures are required, the `-n` or  `--signatures` parameter
can be given a number of how many signatures must be valid.

## Example: Verifying Signatures with `gpg`

**Note:** Currently, `gpg` does not allow verifying detached signatures with
a standalone public key. It expects a key to exist in a keyring, so we must
import it first.

```sh
$ gpg --import ryan.pgp
gpg: key 6C20BB1F556DBBFC: "<ryan@hashbang.sh>" not changed
gpg: Total number processed: 1
gpg:               imported: 1
$ gpg --verify file.txt.asc
gpg: Signature made Fri 26 Aug 2022 07:48:05 AM EDT
gpg:                using EDDSA key 7F263FCCE5B1EFDADE24F46864D06788ABD29369
gpg: Good signature from "<ryan@hashbang.sh>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 2D92 1EF8 44D0 3188 8D56  71EF 6C20 BB1F 556D BBFC
     Subkey fingerprint: 7F26 3FCC E5B1 EFDA DE24  F468 64D0 6788 ABD2 9369
gpg: WARNING: not a detached signature; file 'file.txt' was NOT verified!
```

## Example: Verifying Detached Signatures with `gpg`

**Note:** Currently, `gpg` does not allow verifying detached signatures with
a standalone public key. It expects a key to exist in a keyring, so we must
import it first.

```sh
$ gpg --import ryan.pgp
gpg: key 6C20BB1F556DBBFC: "<ryan@hashbang.sh>" not changed
gpg: Total number processed: 1
gpg:               imported: 1
$ gpg --verify file.txt-detached.asc file.txt
gpg: Signature made Fri 26 Aug 2022 07:52:31 AM EDT
gpg:                using EDDSA key 7F263FCCE5B1EFDADE24F46864D06788ABD29369
gpg: Good signature from "<ryan@hashbang.sh>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 2D92 1EF8 44D0 3188 8D56  71EF 6C20 BB1F 556D BBFC
     Subkey fingerprint: 7F26 3FCC E5B1 EFDA DE24  F468 64D0 6788 ABD2 9369
```
