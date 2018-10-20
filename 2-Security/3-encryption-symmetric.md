## Symmetric Encryption

So far, we have a way of verifying information. This solves the problem of
making sure that data hasn't changed, but even if people can't/won't manipulate
the data, perhaps you don't want them listening in. For example, you might be
talking with your friend about something, using a third party's chat service.
How could you make it so that the third party can't see what you're talking
about?

Encryption is the practice of putting data in a state where only a specific
"key" can decrypt the data, unlocking it so it's usable again. Two main forms
of encryption exist: symmetric and asymmetric. For the purpose mentioned above,
we'll be discussing and learning about symmetric encryption.

Symmetric encryption, under the hood, is typically a variation of DES, the
Data Encryption Standard; and AES, the Advanced Encryption Standard. AES is
much more powerful and secure than DES and it's "triple-DES" (3DES) variant, so
we will be using AES.

AES also can use a 256 bit key. If you recall from chapter 2, "Hashing", one
of the algorithms used _produces_ a 256 bit digest! This means that we could
use the output of sha256 as an AES key. You might also remember that we could
hash arbitrary text, and one of the possible values you might want to hash,
would be a password. This is how password-based encryption usually works.

However, just sha256 is considered insecure in this case - passwords are short
and often easily guessable.  We will instead be using an algorithm designed
specifically for this purpose: PBKDF2, or "Password Based Key Derivation
Function 2". It uses a pseudorandom number generator.

The PBKDF2 algorithm requires another algorithm to run. For this purpose, we
will be using the HMAC-SHA256 algorithm. It is still too insecure to use by
itself, but we can use it as a part of PBKDF2.

### Generating the Key

We will be generating the key using PBKDF2 with the HMAC-SHA256 PNG with a
password containing the ASCII encoded bytes `"your_password"`, a salt
containing the ASCII encoded bytes `"your_salt"`, and 1000000 (one million)
iterations. The key will be 32 bytes - 256 bits - in length.

#### Python

```py
import binascii
import hashlib
key = hashlib.pbkdf2_hmac('sha256', b'your_password', b'your_salt', 1000000)
print(binascii.hexlify(key).decode('ascii'))
```

#### Lua

Unfortunately, as of 2018-10-19, there is no PKCS#5 implementation for luaossl
as far as the author of this book can tell.

#### NodeJS

```javascript
let crypto = require("crypto");
let key_buffer;
crypto.pbkdf2('your_password', 'your_salt', 1000000, 32,
              'sha256', (err, derivedKey)=> {
	        if (err) throw err;
                key_buffer = derivedKey.toString('hex');
              });
```

#### Shell

The OpenSSL command line utilities do not provide a key generation method
using PKCS#5 PBKDF2.

#### Ruby

```ruby
require 'openssl'
key = OpenSSL::PKCS5.pbkdf2_hmac('your_password', 'your_salt', 1000000, 32, 'sha256')
puts key.unpack('H*')[0]
```

---

You should now have your key. Assuming you followed the instructions properly,
the key should look like:
`af9c07e9987e8a090ea9a15d18a0386b8de42904457f0e63f818da73151a7b92`.
If your key does not look like this... Something's gone wrong.

This key is a secret value. You should never share it online, as it's all that
is needed to decrypt and read the text. To ensure the best security possible,
you should generate a salt per-interaction, but this is not required. How you
negotiate the salt is, most times, situationally dependent.

### Block Mode Ciphers

So far, we have a 256 bit key. This is good if we want to encrypt a block of
text that is exactly 256 bits. However, we might not have that perfect size,
so instead we need pad the message to be an exact multiple of that size. To
solve this, we'll use the PKCS#7 algorithm, which pads the message with bytes
containing the size of how many 

We'll do a Python implementation; it's left to the reader to program the
algorithm for other languages.

```py
def pad_message(message, desired_length):
    # Pad a message with PKCS#7 padded bytes
    # Very important that it's _bytes_ and not _bits_
    # Takes a bytearray or bytes object
    bytes_left = len(message) % desired_len
    if len(message) % desired_len == 0:
        # Fill a whole block with the length the size of the block
	return message + bytes([desired_length] * desired_length)
    else:
        # Fill the rest of the current block with the length remaining
	return message + bytes([bytes_left] * bytes_left)

def depad_message(message):
    # Check the last byte, remove as many bytes as the numeric of last_byte
    # Takes a bytearray or bytes object
    return message[:-message[-1]]
```

### Encrypting Text

Now that you have your key made, we're ready to encrypt text. As was mentioned
before, we're using the AES algorithm with a 256 bit key. Once the data is
encrypted, you can use the same key to decrypt it.

Encrypting also involves an initialization vector. An initialization vector is
used as a random value which ensures the output from encrypting will always
be different as long as the initialization vector is different.

For the purpose of these examples, we will assume that you have made a
`pad_message(message, desired_length)` and `depad_message(message)` function.

#### Python

- https://pypi.org/project/pycrypto/

```py
# Assuming `key` from earlier...
from Crypto.Cipher import AES
import os

iv = os.urandom(16)  # This is important, must be kept per-interaction
encrypt_aes = AES.new(key, AES.MODE_CBC, iv)
decrypt_aes = AES.new(key, AES.MODE_CBC, iv)
message = pad_message(b'Hello World!')
print(depad_message(decrypt_aes.decrypt(encrypt_aes.encrypt(message))))
```
