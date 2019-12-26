# Nitrokey / Librem Key

The Librem Key, Nitrokey, Nitrokey Pro are STM32 based personal
HSMs that boast full compatibility with all YubiKey 5 features with the
exception of physical touch while additionally being fully open software and
hardware.

![Nitrokey](assets/img/nitrokey-pro.png)
[https://www.nitrokey.com/]

##### Advantages
 * 100% of source code and hardware design is public and auditable
 * Information on supply chain integrity practices are public for Librem Key
 * Can do remote attestation of the integrity of another device via Chal/resp
 * Design is simple and you can make one at home with inexpensive tooling
 * Firmware can be updated
 * Has RGB LED to indicate various status messages visually
   * red can mean "error", green for "success" etc.

##### Disadvantages
 * Information on supply chain integrity practices are not made public.
 * Does not support physical touch allowing a remote attacker unlimited uses
 * Entropy source is controlled entirely by ARM

