---
weight: 3
---

# Symmetric Encryption

Encryption and decrypting are the processes of securing data that can be sent
or stored over a potentially insecure method of transport. It is commonly used
when connecting to the Internet, when storing sensitive files, and when
communicating with your friends using "end-to-end" encryption methods.

Symmetric encryption is a process that relies on a shared symmetric key. The
key can be created based off of a passphrase by using a passphrase-based key
derivation function, called "PBKDF". These examples will be using the pkcs#5v2
algorithms "pbkdf2".

Symmetric encryption is often used for encrypting data where two (or more)
parties can securely communicate a known passphrase or key. It is used when
you connect to any website using HTTPS, as once a secure channel has been
created (using asymmetric encryption), a symmetric key can be created and used
to encrypt data that will be transmitted.

Symmetric encryption is also used for encrypting large amounts of data that is
stored in a less secure manner, such as on a hard drive. Since symmetric
encryption is much faster than asymmetric encryption, it is often faster to
encrypt things to a securely generated symmetric encryption key, then encrypt
the symmetric encryption key to an asymmetric encryption key. Both the
cyphertext and the encryption key are stored together, and can be decrypted
by the owner of the asymmetric key.

## Example 1: Encrypting files with `openssl enc`

This example encrypts and decrypts a file using the passphrase "helloworld". If
you want to share a file with your friend, and have a secure way of sharing a
passphrase, you can encrypt the file using this method, send it, and then they
can decrypt it using the shared passphrase.

```sh
$ echo "hello world" > file.txt
$ openssl enc -aes128 -pbkdf2 -in file.txt -a | tee file.aes128.b64
U2FsdGVkX1+iGkOySAGdpUoCahad0Z56FvjzYddPTAI=
$ openssl dec -aes128 -pbkdf2 -in file.aes128.b64 -a -d
enter AES-128-CBC decryption password:
hello world
```

If you run this code yourself, you may notice that the output of the command
is different. This is because it uses an "Initialization Vector", which is like
a salt, but for encryption. It is essential for avoiding [known plaintext
attacks]. It is a bunch of random data equal to the size of the block (in this
case, for aes128, the block size is 128 bits) that is appended to the start of
the text that will then be encrypted.

## Example 2: Encrypting files with `sq encrypt` and OpenPGP

The following example uses the Sequoia OpenPGP command line tool `sq`, which
is designed to be more user-friendly than other OpenPGP tooling.

```sh
$ sq encrypt --symmetric file.txt | tee file.txt.pgp
Enter password: helloworld
-----BEGIN PGP MESSAGE-----

wy4ECQMIl6budlrHfJb/s9jgjGFtee8/n91iGVLWRkzfnFalOIpZN6yVxmoWSxKl
0kUBDUhMq/MZHmC39U/hd70DvM0cQ09r10JlAljlwMb5zDrhqwcmJ2fVVvXj0hgy
61T3fmKZls7oFzDZ8aQ0qZLrDCXw9vM=
=FaBZ
-----END PGP MESSAGE-----
$ sq decrypt file.txt.pgp
Enter password to decrypt message: helloworld
Encrypted using AES-256
Compressed using ZIP
hello world
```

## Example 3: Encrypting files using `gpg --symmetric` and OpenPGP

The following example uses the GnuPG command line tool `gpg`, which is more
well-proven than Sequoia but is often cited as being user-hostile. Both
commands will produce messages that are compatible with each other, so either
tool can be used to encrypt and decrypt messages.

```sh
$ gpg --symmetric file.txt
[When prompted, I used the passphrase "helloworld". It may mention that
the given passphrase is insecure.]
$ gpg --decrypt file.txt.gpg
gpg: AES256.CFB encrypted data
gpg: encrypted with 1 passphrase
hello world
```

**Note:** The `--encrypt` flag is not used as using that flag, for gnupg,
implies asymmetric encryption. Instead, only the `--symmetric` flag is used.
However, when decrypting, the `--decrypt` flag must be present, and the
`--symmetric` flag must not be. This is one of the reasons people avoid using
gnupg.

**Note:** gnupg may save the password used to encrypt the file in a session
keyring, so you might not be prompted for a password when decrypting the file.


---

* [known plaintext attack]: an attack used when both the plaintext and the
  cyphertext are known, and can be used to break the encryption of a
  separate message that contains similar plaintext.

[known plaintext attack]: https://en.wikipedia.org/wiki/Known-plaintext_attack
