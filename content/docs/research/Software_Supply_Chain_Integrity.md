The following is totally WIP notes intended to form the basis of proper research.

Don't take anything here as gospel just yet.

Sign your commits, sign your tags, sign the merge commits when you review/merge someone elses code. Also review code and signatures on your local system! If you hit the "merge" button github will forge a signature as that person using their own key! I have spoken to the Github employees about this multiple times. They don't care about this either, but that is another rant...

Even so we must make signing so common that unverified commits become as instantly glaring as the red lock next to a "https" in a URL.

If you are interested in learning about real world tactics that could be used to carry out supply chain attacks NPM as well as potential mitigations I would first I would suggest reading up about security incidents in other package managers:

Gentoo: https://archives.gentoo.org/gentoo-announce/message/dc23d48d2258e1ed91599a8091167002
Debian: https://lists.debian.org/debian-devel-announce/2006/07/msg00003.html
PyPi: https://www.reddit.com/r/Python/comments/8hvzja/backdoor_in_sshdecorator_package/
Ubuntu Snap: canonical-web-and-design/snapcraft.io#651
Arch Linux AUR: https://lists.archlinux.org/pipermail/aur-general/2018-July/034153.html
Now back to NPM again. Here is a (rejected) proposal (which includes rejected PRs) that would of stopped most of these classes of attack for NPM back in 2013: npm/npm#4016

Later NPM added blind signing of packages via Keybase. In addition to Keybase being totally broken and lacking any useful protection of the private key (see my write up on that here: keybase/keybase-issues#1946)... NPM blindly signing packages without reviewing them does not actually address any of the real world used attack surfaces. Also this does nothing to stop downgrade attacks etc.

This initial signing effort was, to be frank, a misguided attempt that does not really solve anything.

For that particular problem (making sure your central database of packages is not corrupted after authors upload them) there are modern well researched solutions like TUF (The Update Framework) that take a
serious look at the threat model for package managers as well as providing practical steps and tools to mitigate most risks: https://theupdateframework.github.io/

Since author-level signing solutions were rejected by NPM, lets look at a couple of damning hacks they would of prevented.

https://eslint.org/blog/2018/07/postmortem-for-malicious-package-publishes
https://blog.npmjs.org/post/180565383195/details-about-the-event-stream-incident
Major e-commerce platforms, major financial firms like Paypal, several major banks, as well as most major crypto-asset exchanges rely on NPM packages for critical infrastructure where billions of dollars are on
the line. I work with many of these companies in a security capacity and the level of life-ruining theft I see at close range on regular basis due to vulnerable/hijacked packages or lack of 2FA on critical accounts is gut wrenching.

Supply chain attacks in particular are only getting easier as stupidly large dependency trees and blind trust in NPM maintainers becomes the default, thus @jnaulty and I starting a spreadsheet of NPM package maintainers with terrible security practices, etc: (Help wanted)

https://docs.google.com/spreadsheets/d/1Y-CJWelun-qSpKuOXMvkc8CxfGzTENBwI7Y2jUjTpEE/edit#gid=1315420641

You could argue "Well consumers of NPM packages should review all code themselves" and you would be right.

Trust me I have begged everyone that will listen to me more than 30 seconds to do this, but their responses are also somewhat fair. "The typical JS project demands 2000+ dependencies. We can't hope to review them all and their constant updates even with 100 engineers.".

I am convinced that problem won't be solved without crowd sourcing cryptographic code review so companies can share the code review burden and prove which others did their part. I have a lot of ideas on how that could be implemented.

Next I encourage you to read:
https://medium.com/hackernoon/im-harvesting-credit-card-numbers-and-passwords-from-your-site-here-s-how-9a8cb347c5b5

I think this is one of the best articles making very clear step by step how easy this problem is.

What that author misses are even -easier- ways to do what he proposes like the fact Github has a totally broken code signing system, a totally broken code review system, and makes it easy to spoof authorship. You can combine these tactics in creative ways with attacks like buried lockfiles to easily fool people into merging or applying a patch with malicious code:

https://snyk.io/blog/why-npm-lockfiles-can-be-a-security-blindspot-for-injecting-malicious-modules/

Our analysis so far (need much bigger sample) reveals most NPM packages can be backdoored via common tactics like phishing, a SIM port, guessing a pets name, or re-registering an expired backup email, even with current NPM "2FA" enabled!.

Every link in this supply chain is critically broken and this is a bigger issue in JS than most other languages since a dependency 20 layers deep can still inject code virtually anywhere in an application in most cases.

We as a community have created a dumpster fire together and I think we need some major changes to correct it now.
