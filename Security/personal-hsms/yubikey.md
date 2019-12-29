# YubiKey

![Yubikey 5](/assets/img/yubikey.png)

A YubiKey is an inexpensive personal HSM produced by Yubico and widely used by
large organizations such as the US Department of Defense, Facebook and Google.

#### Advantages

 * Many protocols: Challenge/Response, FIDO U2F, TOTP, HTOP, GPG, SSH, etc.
 * Configurable touch requirement for GPG operations
   * Critical for limiting the actions of a remote actor on your sytem
 * Form factor choices:
   * YubiKey 5 Nano, 5c Nano
     * NOT designed to be frequently removed (will damage it).
     * Can be used on mobile devices via USB OTG
   * YubiKey 5 NFC
     * Fits on keychain, portable and suited for use with many systems.
     * Sticks out of laptop which can be an issue for leave-in use cases.
     * Can be used on mobile devices via NFC

#### Disadvantages

 * Hardware design and Source code is not available for public auditing
 * Information on supply chain integrity practices are not made public.
 * Firmware can not be updated
 * Entropy source is controlled entirely by Infineon

## Verifying Authenticity

How do I know the YubiKey in front of me is actually a YubiKey from Yubico, and
not from EvilCo?

People have been here before, and Yubico has helped them [support
page](https://support.yubico.com/support/solutions/articles/15000009591-how-to-confirm-your-yubico-device-is-genuine)

They tell you to go to the verification page: [Verification Page](https://www.yubico.com/genuine/).

## Visual Inspection

Does it look like someone opened it up and put in a MITM microcontroller?

If so, don't use it.

## OTP Verification

### USB Way

You can use the official [Yubico OTP Verification](https://demo.yubico.com/otp/verify) page to verify your device
(although this does require you to insert an unverified HID into your computer).

### NFC Way
For the YubiKeys with NFC, there's a slightly easier solution that works
'in the box' so to speak.

You can scan the NFC with your phone through the sealed package and it will
generate an NDEF payload containing an unused AES OTP token at the end of a
verification url.

In other words, you scan one and it takes you to a yubico website saying it is
legit, which is a decent verification.

## WebAuthN Verification

You can use the Yubico WebAuthN to verify your YubiKey

Goto the WebAuthN [Yubico Demo Site](https://demo.yubico.com/webauthn-technical) and go through the flow of registering
your device.

You should see a "Registration Completed!" page and something like this image
which shows that Yubico Verified your device. Don't be afraid to be curious and
click on the "Show Technical Details" dropdown menu to learn more about what's
happening 'under the covers'.
![image](https://user-images.githubusercontent.com/6826729/71484788-12753a80-27c3-11ea-884b-d8edee6bedf5.png)

## PIV Attestation

Each YubiKey comes "pre-loaded from factory with a key and cert signed by
Yubico"[source](https://developers.yubico.com/yubico-piv-tool/Attestation.html)

You can use this to attest that the key was generated in a Yubico factory.

For a detailed guide on the inner-workings of this attestation, review this [blog
post](https://maxammann.org/posts/2019/09/verifying-yubikeys-for-genuity/)
created from the magic of CCCAmp 2019.


## Setup

### Notes

Yubikey devices are assumed as they are the most common and often the cheapest.
These steps will be mostly relevant to other devices with gpg smartcards.

If you -only- need WebAuthN support (2FA on websites) you do -not- need this
guide.

The following is mostly for power users that want to control their own keys and
use their personal hsm for encryption, decryption, code signing, screen unlock,
ssh, etc.

### Install required software

#### OSX

2FA GUI Only: https://developers.yubico.com/yubioath-desktop/Releases/

GUI + CLI Tools:
```
port install gnupg yubikey-manager yubico-piv-tool pinentry-mac
echo "pinentry-program $(which pinentry-mac)" >> $HOME/.gnupg/gpg-agent.conf
```

#### Windows

GUI Only: https://developers.yubico.com/yubioath-desktop/Releases/

GUI + CLI Tools:
```
C:\> choco install pip yubikey-personalization-tool gpg4win openssh
C:\> pip install --user yubioath-desktop
```

#### Linux

##### Arch

```
pacman -S gpg yubikey-personalization pcsc-tools pcsclite libusb-compat \
 libu2f-host swig gcc python2-pyside python2-click yubioauth-desktop
```

##### Debian

```
$ apt-get install yubikey-personalization yubikey-personalization-gui gpgv2 \
  pinentry-gtk2 swig pyside python-pip
```

##### Ubuntu

```
$ sudo add-apt-repository ppa:yubico/stable
$ sudo apt-get update
$ apt-get install yubikey-personalization yubikey-personalization-gui gpgv2 \
  pinentry-gtk2 swig pyside python-pip yubioauth-desktop
```

### Set PIN

To proceed with GPG operations you must set user/admin pin codes for your key.
It is strongly recommended these be different.

You will use the User pin day to day for things like SSH or GPG but you will
only use the Admin pin in the event you lock yourself out or to change certain
protected settings.

```
gpg2 --change-pin
> 3 # change Admin PIN
> 1 # change User PIN
```

### Set Personal Details

You can optionally set the owner details of your key. There are pros and cons
to this. Someone who finds it will know whose it is and have the ability to
return it to you. They also may have unlimited time to try to extract a key
from it.

Your choice here should depend on how confident you are in your key revocation
story and the hardware protections of your chosen HSM.

All of these are optional.

```
gpg --card-edit
> admin
> name  # your name
> url   # personal or company url
> fetch # URL to fetch public key
> login # your login
> lang  # preferred language
> sex   # your gender
```

### Set Human Interaction Flags

The following will enable security features on the Yubikey that are only
relevant to engineers/developers and are not needed for browser-only workflows.

#### Yubikey 5 Series

Require physical touch for all key operations:

```
ykman openpgp set-touch sig fixed
ykman openpgp set-touch aut fixed
ykman openpgp set-touch enc fixed
```

