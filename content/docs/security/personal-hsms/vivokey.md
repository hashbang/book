# VivoKey

<img src="/assets/img/vivokey.jpg" width="320px" />
[http://vivokey.com/]

The VivoKey is an NFC-only device designed to cover the bulk of use cases of
the YubiKey while also having space for general user-supplied applications such
as transit pass emulation via the Fidesmo platform. It is Paralyne-C coated and
on a flexible PCB intended for implantation and is currently in human trials.

For people who are not as into scalpels, it would of course be possible to
insert such a device into a watch band or bracelet.

##### Advantages
 * 100% of application code is public and auditable
 * Applications can be updated
 * Very unlikely to be lost

##### Disadvantages
 * Hardware design and JavaCard OS not available for public auditing.
 * Does not support physical touch allowing a remote attacker unlimited uses
 * Entropy source is controlled entirely by NXP
