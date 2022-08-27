---
weight: 1
---

# Checksums

Data integrity is essential to making sure no accidental or purposeful changes
have occurred to your data. It's important to make sure that a given checksum
function consistently produces a small checksum for a given input, of a static
size, and doesn't collide with other inputs. A given checksum is then typically
transferred [out of band] to make sure the data downloaded or transferred
hasn't been tampered with.

This pattern is commonly used by package managers such as [apt]. apt, for
example, has a `Release` file that contains an md5 checksum of the
`Packages.gz` files. That file then contains the md5 checksum of downloaded
packages. The `Release` file is cryptographically signed to ensure that it came
from repository maintainers.

## Example 1: Proof of Concept

We can ensure that a file hasn't been tampered with by creating a file
containing a checksum of the file we want to ensure isn't tampered with.

```sh
$ echo "hello world" > file.txt
$ sha256sum file.txt | tee sums.txt
a948904f2f0f479b8f8197694b30184b0d2ed1c1cd2a1ec0fb85d299a192a447  file.txt
$ # Tamper with the file...
$ echo hi >> file.txt
$ sha256sum -c sums.txt
file.txt: FAILED
sha256sum: WARNING: 1 computed checksum did NOT match
```

## Example 2: Verifying Large Files

For this use case, we're going to use an OS install image. This image is very
large, but the shasum is small enough that I can include it in this document:

```sh
$ wget -q https://iso.pop-os.org/22.04/amd64/intel/12/pop-os_22.04_amd64_intel_12.iso
$ echo 4c07e24be42575787ab87c9e67c51864321774274af08478a1f87b3adae1d746 pop-os_22.04_amd64_intel_12.iso | sha256sum -c -
pop-os_22.04_amd64_intel_12.iso: OK
```

sha256 and sha512 hashes are small enough that they can easily be shared out of
band, such as IRC/Discord/Matrix channel topics, tweets, and messages. They can
also be put up on a website while the more storage-intense assets are stored by
a third party service like S3.

## Example 3: Hash-Locking Git Repositories

Git internally uses SHA-1 hashes for commits, meaning we can use hashes to
specify which commit to use when reviewing code. Despite being called a
"hash-lock", the concept is closer to a checksum, given its purpose is to
maintain data integrity.

```sh
$ git clone https://github.com/hashbang/book
[...]
$ cd book
$ git checkout d83939e7ace4c128cdbea457b9f77648294bb20e
$ [ "d83939e7ace4c128cdbea457b9f77648294bb20e" = "$(git rev-parse HEAD)" ] && echo "good!"
good!
```

**Note:** It is possible to create branches with the same name as a Git commit
ref: `git branch d83939e7ace4c128cdbea457b9f77648294bb20e`.  Despite the fact
GitHub doesn't allow branches with 40-character names, it's still possible on
other remotes, as well as GitHub if compromised or attacked, and the revision
that is actually checked out should be verified using `git rev-parse HEAD`.

---

* [out of band]: data transferred using a mechanism that is independent to the
  "in-band" stream

[out of band]: https://en.wikipedia.org/wiki/Out-of-band_data
[apt]: https://www.debian.org/doc/manuals/securing-debian-manual/deb-pack-sign.en.html
