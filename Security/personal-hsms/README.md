## Personal HSMs

Personal HSMs (Hardware Security Modules) are small hardware devices one uses
to isolate secrets like private key material and prove physical access to a
computer system in addition to traditional text credentials like a username
or a password. The larger an organization gets, or the higher the value a
given individual has access to (directly or indirectly) the higher the
motivation of a bad actor to use or buy a 0-day to compromise a laptop or
smartphone.

While adding the requirement of having to physically insert or touch a device
to a username and password may seem simple, it is something one can not do
remotely. This makes it a highly effective and simple way to greatly limit
damage and data theft from remote attackers.

## Devices

- [Yubikey](./yubikey.md)
- [GnuK FST-01](./gnuk_fst-01.md)
- [Nitrokey / Librem Key](./nitrokey.md)
- [Ledger](./ledger.md)
- [Trezor](./trezor.md)
- [VivoKey](./vivokey.md)


## Frequently Asked Questions

### Why not a smartphone app?

Smartphone apps like Google Authenticator are certainly better than nothing at
all, and great to protect personal accounts. In a larger organization however
an attacker will simply find a "low-hanging-fruit" user that has a vulnerable
smartphone, and steal codes from that at will.

### Why not SMS?

Most cell phones will blindly connect to anything that claims to be a
compatible cell phone tower, and will use any encryption methods that "tower"
says it supports. This means, in practice, that most SMS can be intercepted by
anyone. In many cases it only takes $20 in hardware and 2TB of disk space.

Even easier methods to intercept SMS may exist if you forward messages through
email, Google Voice, Google Hangouts, or a wearable device such as a Fitbit or
Pebble.

Many services offer to allow SMS as a "backup" method for a Personal HSM.
This entirely defeats the point, and such advice should be ignored.

If you would like to intercept your own SMS messages see:
[http://www.rtl-sdr.com/receiving-decoding-decrypting-gsm-signals-rtl-sdr/]

### What if I lose it?

Obviously you should try really hard not to do this, but life happens. Most
personal services allow you to print out a set of "backup codes" to put aside
as an "escape hatch". With corporate services you would simply contact a
network administrator to have your existing Personal HSM keys revoked and
new ones issued.

### What if someone steals it?

Most Personal HSMs default to a "locked" state and require a pin code to
"unlock" them until they are unplugged or manually locked again (perhaps when
you lock your computer). Much like what would happen if someone stole your ATM
card, an attacker that fails to enter the correct pin code 3 times, will
disable the device.

### What if it gets damaged?

In most cases it is possible to keep secure offline backups of the contents of
a Personal HSM at the time data is added to it. This requires considerable
additional knowledge of good cryptography practices and extra work at setup
time, but it is the best way to ensure a reliable and replaceable digital
"keychain" you can use for years to come.

It is typically not advised to keep backups of security key data around unless
it is a "master" key such as ones held by account owners or system
administrators that understand how to properly secure said backups.

In general just refer to "What if I lose it?"
