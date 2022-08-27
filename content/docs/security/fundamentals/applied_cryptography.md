---
weight: 10
---

# Applied Cryptography

This section will be a set of continuous examples making use of the previously
described cryptographic primitives.

## Sending a Secure, Authenticated Message

Incorporates: Asymmetric (and symmetric!) encryption and signing

For this example, Alice would like to send a message to Bob. They each have
their own private key and have previously shared copies of their public key
with each other. Alice will then sign and encrypt the message:

```sh
# As Alice
echo "Hi, Bob!" | sq encrypt --recipient-cert bob.pgp --signer-key alice.key.pgp > message.asc
```

Let's assume that Alice has sent Bob the contents of `message.asc` using their
preferred method of insecure communication, such as email. Now that Bob has his
copy of `message.asc`:

```sh
# As Bob
sq decrypt --recipient-key bob.key.pgp --signer-cert alice.pgp message.asc
Encrypted using AES-256
Compressed using ZIP
Good signature from 64D06788ABD29369
Hi, Bob!
1 good signature.
```

You may note the "Encrypted using AES-256" message in the command output. AES,
or "Advanced Encryption Standard", is a symmetric algorithm. It uses symmetric
encryption, since the message itself isn't actually encrypted using your key's
asymmetric encryption algorithm. A separate *symmetric* key, often called a
"session key", is generated for the message and encrypted to the asymmetric
public key. Since symmetric encryption and decryption is much faster than
asymmetric encryption and decryption, this offers the benefits of both a secure
asymmetric transaction and a fast symmetric session.

## Sending A Bunch of Files

Incorporates: Checksums and signing

Since Alice and Bob are using email, they've come up against an issue where the
email provider limits the size of the email. Bob wants to send Alice some
pictures, but doing so requires using a third party service to host the images.
While the content of the images isn't critical -- he's also put them on his
social media pages -- he'd like to make sure they're not tampered with.

First, Bob can generate a checksum file for the pictures:

```sh
find pictures -type f -exec sha256sum {} \; | sponge sha256sum.txt
```

**Note:** The `sponge` utility is useful as it doesn't write to a file until
all the input has been received. This means the `find` utility won't notice the
sum file. If using a shell redirection (the `>` character), the file will be
created while `find` is still finding files to verify. This is only important
when running `find` in the directory that will contain the checksum file. `

Let's assume at this point that Bob has uploaded his pictures to a service,
and can share a link to those pictures with Alice.

Next, Bob sign the checksum file, upload the files and checksum file, and send
an email to Alice telling her the pictures and checksum file has been uploaded:

```sh
sq sign --signer-key bob.key.pgp sha256sum.txt > message.asc
```

Alice can then verify that the checksum file came from Bob, and verify that the
pictures she's downloaded match the ones Bob uploaded:

```sh
sq verify --signer-cert bob.pgp message.asc > sha256sum.txt
sha256sum -c sha256sum.txt
```

**Note:** The directory name used when generating the `sha256sum.txt` file is
significant, so it may be ideal to upload the checksum file and the pictures
in a way that preserves names, such as a zip file or tar archive.


## Building an Interactive Website

Incorporates: Hashing and HMACs

**Note:** We're going to build a *very* simple website that stores everything
in memory, using the web framework [Flask]. Ideally, you'd structure things
better, use a proper database, and actually implement functionality beyond a
register and login screen.
