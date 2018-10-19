## Hashing

How do you know that your 1.5 GB folder of.... "stuff", hasn't changed when you
copied it from one computer to the other? How do you know that when you take a
file on the internet and download it, that it's really the file you expect?

Perhaps you've gone to a website and seen a "SHA-1" or "MD5" value. These are
called a "hash", and are used for checking data integrity. They are what are
known as a "trapdoor" function: easy to get into, but hard to break out of.

A hash value is, quite simply, a reproducible value generated based off of a
certain input. It is very hard to find two hash collisions in something that is
government-grade, such as the SHA-1, SHA-2, and SHA-3 sets of algorithms. It
would take many years to find two values that produce the same hash.

**So, where would you use a hash?** If you have any data that you have to
ensure has not changed, you should use a hash stored on a trusted medium - this
can be a pen and paper if it has to be, as long as you're sure no one can
change it.

A significant factor about a hash is that you should never fully trust a hash
from the same source you received a file from - if you get a hash
from the same place you got a file, you can't trust that the remote source is
valid. However, this setup allows for a somewhat effective trust system to be
created. If you don't trust your ISP, you can call up your friends - who might
be using a different ISP - and ask them to see if **they** see the same hash
that **you** see. If even one person has a differing hash, it is likely that
someone is attempting an attack.

---

We will not be looking at algorithms, as people tend to click off when complex
math is brought in. Instead, we will be looking at examples from different
languages, to see how easy it is to create hash values.

For all these examples, we will be using the bytes `['t', 'e', 's', 't']` and
as many builtin libraries as possible.

#### Python

```py
# If using a native string, use .decode() to turn into bytes; hashlib will only
# accept bytes-like objects.
import hashlib
hash = hashlib.sha256(b"test").hexdigest()
```

#### Lua

- https://github.com/aiq/basexx
- https://github.com/wahern/luaossl

```lua
local basexx = require("basexx")
local digest = require("openssl.digest")
local hash = basexx.to_hex(digest.new("sha256"):final("test"))
```

#### NodeJS

```javascript
let crypto = require("crypto");
let hash = crypto.createHash('sha256').update('test', 'ascii').digest();
```

#### Shell

```sh
command -v gsha256sum >/dev/null && SHA256SUM=gsha256sum || SHA256SUM=sha256sum
command -v $SHA256SUM >/dev/null || { echo "$SHA256SUM not found"; exit 1 }

hash=$(printf test | $SHA256SUM | awk '{ print $1 }') 
```

#### Ruby

```ruby
require 'digest'

hash = Digest::SHA256.hexdigest 'test'
```
