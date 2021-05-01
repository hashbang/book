# Security Strategy

At #! we have some clear preferences when it comes to managing sevices to
maximize flexibility, reliability, and security.

This document aims to be an explicit policy of things to do and not do as well
as the rationale for these rules so as to inform decisions not yet explicitly
covered by this document.

## Principles

### Principle of Least Privilege

Do not give any service or system more rights and resources required to carry
out its well defined legitimate purpose. This is of course for security but
also for reliability.

#### Examples

##### A credential manager
  * Should encrypt all assets at rest
  * Should only decrypt the specific assets needed when they are needed
  * Should give out limited credentials to requesting services
    * Vault for instance can issue one-time-use mongodb credentials to services
      when they are starting up.
  * Should provision ephemeral (with an expiry time) credentials when possible

##### A recurring job that compiles static assets
  * Should only need write access to one directory
    * Use filesystem namespacing, and only mount the specific path needed
  * Should use minimal resources required to complete the job
    * Use cgroups to set worst-case upper bounds for cpu/threads/memory, etc.
  * Should -not- need to see other processes on the system
    * Use process namespacing
  * Should only have access to minimal filesystem write calls

##### An ssh bastion host
  * Does not need a package manager or many packages
    * Use packer or similar to build a bare minimum image.
  * Does not need write access to the disk
    * Boot with fsprotect or similar
  * Does not need to offer shell access
    * /bin/true is all that should be required for ssh passthrough

#### Resources

 * [Principle Of Least Privilege - Wikipedia](https://en.wikipedia.org/wiki/Principle_of_least_privilege)
 * [Containers vs Zones vs Jails vs VMs - Jessie Frazelle](https://blog.jessfraz.com/post/containers-zones-jails-vms/)
 * [How to use Docker seccomp profiles](https://blog.jessfraz.com/post/how-to-use-new-docker-seccomp-profiles/)
 * [Bane: AppArmor profile generator for Docker](https://github.com/genuinetools/bane)
 * [Isolate containers with a user namespace - Docker Docs](https://docs.docker.com/engine/security/userns-remap/)
 * [Role Based Access Control in K8s](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
 * [Security: OpenBSD vs FreeBSD](https://networkfilter.blogspot.com/2014/12/security-openbsd-vs-freebsd.html)
 * [Managing compute resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/)
 * [Package: fsprotect](https://packages.debian.org/sid/admin/fsprotect)

### Fault Tolerance

It should be possible to destroy any single server at any time with minimal
user facing disruption. The Netflix idea of "chaos monkey" testing should be
something we strive to replicate.

#### Examples

##### Amazon terminates our bastion host without warning
  * Should be contained in an autoscale group on a fixed template.
  * Should fail TCP:22 health checks so an identical server will be started
  * Will automatically update DNS, load balancer, or recycle an IP.

##### A bug causes widespread MongoDB database corruption
  * We should have a continued streaming backup of our oplog
  * We should be able to detach all mongo instances to trigger replacements
  * We should be able to oplogReplay to restore to last known-good timestamp

#### Resources

 * [The Netflix Simian Army](https://medium.com/netflix-techblog/the-netflix-simian-army-16e57fbab116)
 * [Chaos Monkey](https://github.com/netflix/chaosmonkey)
 * [Pumba: Chaos testing and network latency generator for Docker](https://github.com/alexei-led/pumba)
 * [Incremental backup/restore via Oplog Replay in MongoDB](https://dba.stackexchange.com/questions/73146/how-we-can-take-backup-oplog-on-every-hour-and-apply-on-top-on-full-backup-for-m)

### Kerckhoffs's Pinciple

"A cryptosystem should be secure even if everything about the system, except
the key, is public knowledge."

Assume our adversaries are patient and have all of our documentation,
including this document.

Design everything so that if sales chooses to disclose details as a point of 
pride or promotion, when talking to clients, this can't hurt us.

Also when designing things, do it with the same level of care and abstraction
you would if we were making it open source, even if we are not.

#### Examples

##### Our adversary has all of our documentation
* They should learn they can't modify our systems without 2 yubikeys with pins.
* They should learn our barrier is very high, and move on to easier targets.

##### Our adversary gains read/write access to our database
* All private keys are encrypted with a key only stored in an HSM
* HSM should only decrypt private keys inside itself, without revealing them
* Tampering with a transaction will be rejected by the HSM due to a bad signature

#### Resources

 * [Kerckhoffs's Pinciple - Wikipedia](https://en.wikipedia.org/wiki/Kerckhoffs%27s_principle)
 * [A note about Kerckhoffs's Principle](https://blog.cloudflare.com/a-note-about-kerckhoffs-principle/)

### Distrust, then verify.

Assume any system or software we use can be compromised at any time. Assume our
attackers have 0-days they are willing to burn on us.

Security is hard enough with open source code where anyone can audit it. A
closed solution should always be highly distrusted, and given the minimal
amount of access to allow the business to function.

If there is an open source solution with wide community auditing, we should
always favor that as time allows.

We must always maintain ways to verify the integrity of systems at any time,
especially those that grant untrusted third parties access to our systems, such
as a janitor at a data center.

#### Examples

##### We don't have time to run our own VCS in the short term
* Third party systems that allow us to -prove- their integrity are preferred
* Use Github, but sign all commits and verify externally before builds

##### We recently patched a remote code execution vulnerability
* Rebuild every system impacted - this easily proves there are no backdoors

#### Resources

 * [Open Source Security - RedHat](http://www.redhat.com/whitepapers/services/Open_Source_Security5.pdf)
 * [Rootkit / Evil Maid Attack](https://en.wikipedia.org/wiki/Rootkit#bootkit)
 * [Keystone Metrics in DevOps: The 30 Day project](https://maori.geek.nz/keystone-metrics-in-devops-the-30-day-project-coinbase-b6c4e0109016)

### Avoid Lock-In

As a organization with limited resources, we must sometimes employ the help of
third party services in the short term.

This should always be treated as technical debt, and we should do so with a
clear plan of escape when said vendor has an unacceptable change in their
availability, rules, or pricing.

#### Examples

##### We need Redis nodes but don't have the resources to self-host today
* AWS provides ElastiCache which is turn-key vanilla Redis
* We can easily port the data to our own servers at any time if forced

##### We need a system to manage credentials/rights for servers
* IAM and KMS are powerful, but not portable
* Favor rights management via pub/sub and open tools like Vault where possible

##### We need to reliably scale custom applications
* Favor cloud-agnostic deployment tools like Helm, Docker, and Kubernetes.
* Ensure applications have no awareness of what cloud provider they run in

#### Resources

 * [Vault - Infrastructure secret/key management](https://www.vaultproject.io/)
 * [Kubernetes - Container orchestration](https://kubernetes.io/)
 * [Helm - Kubernetes package manager](https://helm.sh/)
 * [Docker/Kubernetes Hello world](https://kubernetes.io/docs/tutorials/hello-minikube/)

## Recommendations

The following will detail specific implementations of the above principles as
recommended by the #! team.

### Vendors

The following vendors have security practices we consider to be equal to or
greater than ours and are generally trusted.

#### Acceptance

* We must be able to cryptographically prove all changes and reviews made
* All code must be public and open source
* Must be active in OSS community and transparent about security practices.
* Authors individually sign code and binaries
* All code is reviewed by at least one engineer other than author
* Package management system automatically verifies signatures/hashes
* Must do reproducible builds and avoid SPOF where possible

#### Trusted

* The Debian Project
* Fedora Foundation
* Gentoo Foundation
* OpenBSD Foundation
* FreeBSD Foundation
* Arch Linux
* Canonical
* Google
* Apple
* Guardian Project
* Tor Project
* Bitcoin Core
* ZCash Foundation
* Cloud Native Computing Foundation
* Inverse Path
* Linux Foundation
* Hashicorp
* CoreOS

#### Untrusted

Obviously anything not on the Trusted list is untrusted but we will spell out
some commonly trusted entities we explicitly -never- trust, due to poor
security practices.

* nixpkg
* pypi
* npm
* maven
* luarocks
* snap
* chocolatey
* brew
* macports
* cargo
* cabal
* Google play store
* Chrome Store
* Apple App Store

#### Exceptions

* You can run/evaluate untrusted code but only in dedicated VMs/hardware
* Untrusted environments must never be able to interact with production systems

### Operating Systems

#### Criteria

* Package manager must verify all packages for integrity/signatures by default
* Signing must be distributed and be totally transparent
* Public reproducible build systems
* Historically fast response to critical security issues
* Mostly or totally open source and auditable

#### Trusted

* Arch Core
* Ubuntu
* Gentoo
* Debian
* OpenBSD
* FreeBSD
* ChromiumOS
* ChromeOS
* HashbangOS
* F-Droid

#### Untrusted

* Blackberry
* Windows
* Windows Mobile
* MacOS *
* Google Android *
* iOS *

### Secrets

In this section "Secrets" are defined as private keys or passwords that would allow
manipulation of customer wallets/policies or that would allow viewing and must
never be exposed to system memory of any device except an approved HSM.

#### Required

* FIDO hardware authentication must be exclusively used for supporting services
  * DockerHub, Github, AWS, etc
* All keys with the ability to -write- to a VCS -must- be on HSM devices

#### Exceptions

* Services that lack hardware U2F support may be used with Yubico Authenticator
  * because it allows storage of totp secrets on a yubikey
* Passwords which -must- be directly visible to an application in order for it
to function, such as websites. These secrets may be maintained by a password
manager that only decrypts the exact secret being requested with explicit
approval by user(s) with an HSM.
* Secrets can be made available to automatically managed applications on
security hardened systems that humans lack direct access to, and only when use
of an HSM is not practical.

### Coding Practices

* Third party libraries must be reviewed and hash-locked
* A new version of a third party library requires explicit review/approval
* Automated CVE assessments on third party libraries must be present
* Favor custom implementation instead of libraries where possible
* Avoid packages that depend on low-quality dependencies like "is-even"
* All project dependencies must be hash-locked with a package manager manifest
* All code must be reviewed by an approved vendor
