---
weight: 2
---

# Hashing

The most common use for hashing is to take a given input, producing a
deterministic output of a static size, with no ability to reproduce the input
from just the hash itself. It is very similar to checksums, with a specific
difference: hashes are typically used on sensitive data (such as passwords) and
are more expensive to compute.

Hashes are commonly used for comparing passwords. By storing the hash of a
password in a database, it is not possible to retrieve the password based on
the hash without [brute forcing] every possible password. This becomes harder
as algorithms grow in computational complexity.

Hash functions typically incorporate a salt. Salts are important because they
avoid issues where multiple people use the same password. Since most hash
function primitives are deterministic, if we didn't use a salt, all the hash
results would look the same. This means that we could see who reused passwords,
leaving us vulnerable to a [rainbow table] attack.

It is ideal to find a program or library specifically designed for hashing
and verifying passwords, as there are numerous attacks that can happen when
building your own implementation. Look for a solution that's already built for
your environment.

## Example 1: `openssl passwd` for Linux password creation

This example creates an entry that could be used in `/etc/shadow`. This example
is for demonstration purposes, to change the password of a user on a system,
the `passwd` utility should be used instead.

**Note:** The `openssl passwd` utility uses [md5] by default which is
considered cryptographically broken and should not be used.

```sh
$ openssl passwd -6 -salt deadbeef
Password: helloworld
$6$deadbeef$UxFXRpOAonp7.EWCV9sl5vqmlwrPqoiaugLAfXIkRFDAYKkM5sUBwx26GjX3UNKLzA7Taj9eiOAvtAXYqVA2f.
```

We use the salt `deadbeef` as otherwise it would be random every time the
command was run. This is useful for demonstration purposes, but should never be
done in production. Further examples will not be reproducible unless the same
salt is used.

The hash was created using the sha512 function, which was mentioned in the
previous guide about checksums. The sha512 function is considered relatively
fast compared to the next examples, which is not ideal given a faster algorithm
can be brute-force attacked faster.

## Example 2: `argon2`

Argon2 is the winner of the 2015 Password Hashing Competition, and offers
minimal customization, which may be ideal from a security perspective as there
is no chance to weaken the algorithm. However, the algorithm is not considered
"battle tested" yet and could possibly be vulnerable to issues currently
unknown.

```sh
$ argon2 `pwgen 16 1`
helloworld
[ Press ctrl-d to signal you're done typing ]
Type:           Argon2i
Iterations:     3
Memory:         4096 KiB
Parallelism:    1
Hash:           103e17680798f6f5a8aad5d8958ef69791d26e2f1b528b5024a0fd28385fcd0c
Encoded:        $argon2i$v=19$m=4096,t=3,p=1$YWh3ZW94aWU2Y2hlaUQ5bw$ED4XaAeY9vWoqtXYlY72l5HSbi8bUotQJKD9KDhfzQw
0.008 seconds
Verification ok
```

The salt can be replicated by running "YWh3ZW94aWU2Y2hlaUQ5bw" through a base64
decoder, but for production use cases, a unique salt should be used.

---

* [brute forcing]: going through each potential value to find a valid value,
  such as trying each possible combination on a padlock, or each possible
  password combination.
* [md5]: a cryptographically broken but formerly widely-used hashing function,
  which should not be used for new projects, and replaced in existing projects.
* [rainbow table]: a utility often used to help retrieve passwords from hashes.

[brute forcing]: https://en.wikipedia.org/wiki/Brute-force_attack
[md5]: https://en.wikipedia.org/wiki/MD5#Security
[rainbow table]: https://en.wikipedia.org/wiki/Rainbow_table
