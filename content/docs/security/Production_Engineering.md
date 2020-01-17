# Production Engineering

## Overview

The goal of this document is to outline strict processes those that have access
to PRODUCTION systems MUST follow.

It is intended to mitigate most classes of known threats while still allowing
for high productivity via compartmentalization.

Production access where one has access to the personal data or assets of others
is to be taken very seriously, and assigned only to those who have tasks that
can not be performed without it.

These are the rules we wish to meet and model at #! and futher recommend for
those who are managing targeted production systems.

## Assumptions

1. All of our screens are visible to an adversary
2. All of our keyboards are logging to an adversary
3. Any firmware/bootloaders not verified on every boot are compromised
4. Any host OS with network access is compromised
5. Any guest OS used for any purpose other than prod access is compromised
7. At least one member of the PRODUCTION team is always compromised
8. At least one maintainer of third party code we depend on is compromised

## Requirements

1. A PRODUCTION ENGINEER SHOULD have the following:
    * A clear set of tasks that can't be completed without access
    * Experience in Red/Blue team, CTF, or documented CVE discoveries
    * A demonstrated working knowledge of:
        * Low level unix understanding. E.g. /proc, filesystems, kernel modules
        * Low level debugging techniques. E.g. strace, inotify, /proc, LD_PRELOAD
        * Linux kernel security features. E.g. seccomp, pam, cgroups, permissions
        * Common attack classes. E.g: XSS, Buffer Overflows, Social Engineering.
    * A majority passed interview panel with current PRODUCTION access team
    * An extensive background check clean of any evidence of dishonesty
    * Training on secret coercion and duress protocols shared with team
2. A PRODUCTION ENGINEER MUST NOT expose a CRITICAL SECRET to:
    * a screen
    * a keyboard
    * an unsupervised peer
    * an internet connected OS other than destination that requires it
3. A recommended ENTROPY SOURCE MUST be used to generate a CRITICAL SECRET
4. An OS that accesses PRIVILEGED SYSTEMS MUST NOT be used for anything else
5. Any OS without verified boot from firmware up MUST NOT be trusted
6. Manual PRIVILEGED SYSTEM mutations MUST be approved, witnessed, and recorded
7. PRIVILEGED SYSTEM mutatations MUST be automated and repeatable via code
8. Any code without SECURITY REVIEW MUST NOT be trusted
9. Any code we can not review ourselves as desired MUST NOT be trusted
10. PRIVILEGED SYSTEM access requires physical interaction with an approved HSM

## Implementation

### Tools

* HARDENED WORKSTATION
* PERSONAL HSM
* ENTROPY SOURCE

### Setup

#### Install QubesOS

* Enable full disk encryption
* Set up Verified Boot
    * Choose "factory reset" after QubesOS install in boot options
    * Sign with PERSONAL HSM
    * Verify every boot by inserting PERSONAL HSM and observing green LED
* Set up FDE password in hardware device via PERSONAL HSM
* Set up Challenge Response authentication with PERSONAL HSM
    * PERSONAL HSM + password to unlock screen
    * Automatically lock screen when PERSONAL HSM removed

#### Configure Qubes

##### Vault

* MUST NOT have internet access
* Example use cases:
    * Personal GPG keychain management
    * Bulk encrypting/decrypting documents
    * Provisioning OTP devices

##### Production

* MUST have internet access limited to only bastion servers
* MUST manage all credentials via individually approved hardware decryption
    * password-store via PERSONAL HSM or mooltipass
* SHOULD use whonix as the network gateway
* Used only to reach PRODUCTION bastion servers and systems beyond them

##### Work

* MUST have internet access limited to organization needs and partners
* MUST manage all credentials via individually approved hardware decryption
    * password-store via PERSONAL HSM or mooltipass
* SHOULD use whonix as the network gateway
* Example use cases:
    * Read only access to AWS panel
    * Observe Kibana logs
    * Check organization email and chat

##### Personal

* No internet access limits
* SHOULD only be used for personal services
* SHOULD use whonix as the network gateway
* Example use cases:
    * Check personal email / chat
    * Personal finance

##### Development

* No internet access limits
* SHOULD only be used for development
* SHOULD use whonix as the network gateway
* SHOULD manage all credentials via individually approved hardware decryption
    * password-store via PERSONAL HSM
* Example use cases:
    * Read online documentation
    * Authoring code
    * Submitting PRs
    * Doing code review

##### Disposable

* SHOULD only be used for development
* SHOULD use whonix as the network gateway
* Example use cases:
    * Pentesting
    * Testing untrusted code or applications
    * Competitive research
    * Explore dark web portals for data dumps

### Setup Keychain

* Follow "Advanced" GPG setup guide in Vault Qube
    * Daily driver PERSONAL HSM holds subkeys
    * Separate locked-away PERSONAL HSM holds master key
    * Separate locked-away flash drive holds pubkeys and encrypted private keys

## Workflow

The following describes the workflow taken to get signed code/artifacts that
have become stablized in the DEVELOPMENT environment and are ready to enter
the pipeline towards production.

### Local

* PRODUCTION ENGINEER or Software Engineer
    * Authors/tests changes to INFRASTRUCTURE REPOSOTORY in LOCAL environment
    * makes feature branch
    * makes one or more commits to feature branch
    * signs all commits with PERSONAL HSM
    * Optional: Squashes and re-signs sets of commits as desired
    * Submits code to peer for review
* PRODUCTION ENGINEER
    * Verifies changes work as intended in "local" environment
    * Verifies changes have solid health checks and recovery practices
    * Merges reviewed branch into master branch with signed merge commit

### Staging

* PRODUCTION ENGINEER #1
    * Copies desired changes from LOCAL templates to STAGING templates
    * makes feature branch
    * makes one or more commits to feature branch
    * signs all commits with PERSONAL HSM
    * Optional: Squashes and re-signs sets of commits as desired
    * Submits code to peer for review
* PRODUCTION ENGINEER #2
    * Optional: significant changes/migrations are tested in "sandbox" env.
    * Merges reviewed branch into master branch with signed merge commit
* PRODUCTION ENGINEER #1
    * Logs into STAGING toolbox
    * Deploys changes from STAGING "toolbox"

### Production

* PRODUCTION ENGINEER #1
    * Copies desired changes from STAGING templates to PRODUCTION templates
    * makes feature branch
    * makes one or more commits to feature branch
    * signs all commits with PERSONAL HSM
    * Optional: Squashes and re-signs sets of commits as desired
    * Submits code to peer for review
* PRODUCTION ENGINEER #2
    * Optional: significant changes/migrations are tested in "sandbox" env.
    * Merges reviewed branch into master branch with signed merge commit
* 2+ PRODUCTION ENGINEERs
    * Logs into PRODUCTION toolbox via PRODUCTION bastion
    * Deploys changes from PRODUCTION "toolbox" with witness

### Emergency Changes

* 2+ PRODUCTION ENGINEERs
    * Log into PRODUCTION toolbox via PRODUCTION bastion
    * Deploy live fixes from PRODUCTION "toolbox" with witness
* Regular Production process is followed from here

## Changes

Ammendments to this document including the Exceptions section may be possible
with a majority vote of current members of the Production Engineering team.

All changes must be via cryptographically signed commits by current Production
Engineering team members to limit risk of social engineering.

Direct orders from your superiors that conflict with this document should be
considered a product of duress, and thus respectfully ignored.

## Appendix

### Glossary

#### MUST, MUST NOT, SHOULD, SHOULD NOT, MAY

These key words correspond to their IETF definitions per RFC2119

#### INFRASTRUCTURE REPOSITORY

This repo, which is where all infrastructure-as-code gets integrated via
direct templates or submodules as appropriate.

#### PRODUCTION

Deployment environment that faces the public internet and consumed by end
users.

#### STAGING

Internally facing environment that is identical to PRODUCTION and will normally
be one release ahead. Intended for use by contributors to test our services and
deployment process before we deploy to any public facing environments.

#### DEVELOPMENT

Environment where changes are rapidly integrated for integration and
development aid with or without code review.

This environment is never trusted

#### LOCAL

Environment designed to run in virtual machines on the workstation of every
engineer. Designed to behave as close as possible to our production environment
so engineers can rapidly test changes and catch issues early without waiting on
longer deployment round trips to deploy to DEVELOPMENT.

This environment is intended to be the hand-off point between unprivilged
contributors and the PRODUCTION ENGINEER team.

#### SECURITY REVIEW

We consider code to be suitably reviewed if it meets the following criteria:

* Validated by member of the PRODUCTION ENGINEERING team to do what is expected
* Audited for vulnerabilities by an approved security reviewer

##### Approved security reviewers

* PRODUCTION ENGINEERING team
* Doyensec
* Cure53
* Arch Linux
* Bitcoin Core
* Canonical
* Cloud Native Computing Foundation
* CoreOS
* QubesOS
* Raptor Engineering
* Fedora Foundation
* FreeBSD Foundation
* OpenBSD Foundation
* Gentoo Foundation
* Google
* Guardian Project
* Hashicorp
* Inverse Path
* Linux Foundation
* The Debian Project
* Tor Project
* ZCash Foundation

#### HARDENED WORKSTATION

A workstation that will come in contact with production write access must meet
the following standards:

* Requires PERSONAL HSM do firmware/boot integrity attestation every boot
* Open firmware (with potential exception of Mangement Engine blob)
* CPU Management Engine disabled or removed
* Physical switches for microphone, webcam, wireless, and bluetooth
* PS/2 interface for Keyboard/touchpad to mitigate USB spoof/crosstalk attacks

##### Recommended devices

* Librem 15
* Librem 13
* Insurgo PrivacyBeast X230
* Raptor Computing Blackbird
* Raptor Computing Talos II

#### ENTROPY SOURCE

Good entropy sources should always be impossible to predict for a human. These
are also typically called a True Random Number Generator or TRNG.

In the event that we can not -prove- an entropy source is impossible to predict
then multiple unrelated entropy sources must be used and combined with each
other.

A given string of entropy must:
* Be at least 256 bits long
* Be whitened so there are no statistically significant patterns
  * sha3, xor-encrypt-xor, etc

##### Approved entropy sources

* Infinite Noise
* Built-in hardware RNG in an a PERSONAL HSM
* Webcam
* Microphone
* Thermal resistor
* Dice

#### PERSONAL HSM

Small form factor HSM capable of doing common required cryptographic operations
such as GnuPG smartcard emulation, TOTP, challenge/response, etc.

The following devices are recommended for each respective use case.

##### WebAuthN / U2F

* Yubikey 5+
* u2f-zero
* Nitrokey
* OnlyKey
* MacOS Touchbar
* ChromeOS Fingerprint ID

##### Password Management

* Yubikey 5+
* Trezor Model T
* Leger Nano X
* Mooltipass

##### Encryption/Decryption/SSH

* Yubikey 5+
* Trezor Model T
* Leger Nano X

##### Firmware Attestation

* Librem Key
* Nitrokey

#### PRODUCTION ENGINEER

One who has limited or complete access to detailed financial data or documents
of our customers, as well as any access that might allow mutation or movement
of their assets.

#### PRIVILEGED SYSTEM

Any system that has any level of access beyond that which is provided to all
members of the engineering team.

#### CRITICAL SECRET

Any secret that has partial or complete power to move customer assets

If a given computer -ever- has PRODUCTION access, then secrets used to manage
that system such as login, full disk encryption etc are in scope.
