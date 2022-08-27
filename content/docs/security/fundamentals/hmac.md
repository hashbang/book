---
title: HMAC
weight: 5
---

# Hash-Based Message Authentication Code

When managing messages that can be controlled by an attacker, it's important to
be able to determine that a message hasn't been tampered with. This can be done
by using a secret key and hashing algorithms to produce an output that can't be
forged. While this doesn't prevent the data from being seen by an attacker, it
does mean that the message can't be tampered with without raising an alarm.

The algorithm is actually pretty simple and foolproof, leading to adoption in
many places, such as web frameworks (for managing session cookies) and JSON Web
Tokens (JWTs), and were previously used in OpenSSH and TLS

The usage of HMAC in web frameworks and in JWTs is mostly due to the fact only
one party needs to manage the key used for for the HMAC operations. While they
could be shared among multiple services provided by a single party, they are
still only controlled by one party and don't need public and private portions.

Signatures are a better way to determine a message has come from a specific
origin, when there are multiple parties involved.

## Example 1: `openssl mac`

```sh
$ echo "hello world" | openssl mac -digest sha256 -macopt hexkey:c6dceda958230fee551cbe2b55e2989b4512a43253132e538dcf5a2ba23fa15d -in hmac
BE17B4799688E198ACCEDC2EBC13517D787023CA7FF5AEDA9A0A37C16A18DB71
```

## Example 2: NodeJS with zero dependencies

```js
const crypto = require("crypto");
let hmac = crypto.createHmac("sha256", Buffer.from("c6dceda958230fee551cbe2b55e2989b4512a43253132e538dcf5a2ba23fa15d"));
// We know this is the content of the 
hmac.update("hello world\n");
console.log(hmac.digest("hex"));
// This will print: be17b4799688e198accedc2ebc13517d787023ca7ff5aeda9a0a37c16a18db71
```
