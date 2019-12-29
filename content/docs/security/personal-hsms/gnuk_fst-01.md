# GnuK FST-01

<img src="/img/fst-01.jpg" width="320px" />

[Site](http://wiki.seeedstudio.com/wiki/FST-01)

The GnuK FST-01 is an STM23 based personal HSM solution available for all
typical GPG workflows such as SSH, code/binary/email signing, encryption, etc.

##### Advantages
 * 100% of source code and hardware design is public and auditable
 * Design is simple and you can make one at home with inexpensive tooling
 * Firmware can be updated

##### Disadvantages
 * Unusable for Second Factor Authentication (2FA) in most services.
   * No support for Challenge/Response, WebAuthN, U2F, TOTP, etc.
 * Information on supply chain integrity practices are not made public.
 * Does not support physical touch allowing a remote attacker unlimited uses
 * Entropy source is controlled entirely by ARM
