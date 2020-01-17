# Random Red Team

## Summary

This document seeks to detail intentionally introducing security vulnerbilties
into projects to test code review processes and foster a healthy and expected
culture of distrust and higher security scrutiny during code reviews regardless
of social standing, or experience level of the author.

## Motivation

In modern organizations it is very commonplace for code to be reviewed for
suboptimal patterns, poor commenting etc. It is far less common that code
is carefully scrutinized for security, particularly around tough deadlines,
or when the code is coming from Sr. engineers that are well trusted.

Likewise third party package inclusions such as new NPM dependencies are often
not audited at all.

This culture of trust actually creates non intuitive danger for contributors
as now any of them could be coerced by an sophisticated adversary such as a
government (See Australia's Access And Assistance Bill 2018 ).

If a culture of high security scrutiny during code review is created then a
coercion or supply chain dependency attack becomes no longer as desireable or
worth the risk for an adversary, and in turn puts contributors at less risk.

This tactic might also further help to prevent subtle heartbleed style
accidents.

## Design

In short, we seek to gamify a reward system for better security practices.

A typical example of this is encouraging screen locking by using unlocked
machines as a method to social engineer the delivery of donuts by the victim
via impersonation. Another is to encourage badge checks by introducing
badgeless "secret shoppers" that hold rewards for those that challenge them.

This approach extends this idea to code review.

The scheme is as follows:

1. One engineer is picked randomly from a pool of participants every "sprint"
or similar time period to be a "bad actor"

2. During this time period, in additional to regular duties, the engineer has
a free pass to try to sneak some type of vulnerability past code review that
would allow them some ability to control a private key, execute code, or other
attack that would give an outside adversary some significant advantage in
defeating system security or privacy.

3. Security and Release engineering teams are always informed of the current
"bad actor" and knows to not actually release any code they are involved in.
  * Organizers can play a role in teaching typical red team tactics but can not
  have any direct participation in an attack.

4. Organization puts up bounty that is provided to anyone that successfully
spots a vulnerability, OR a higher one to the "bad actor" that successfully
gets a peer to approve of an exploit.

5. "Bad actor" and security/release engineering teams are all responsible for
calling out introduced vulnerability before it can get past a dev environment.

## Drawbacks

* Engineers are constantly suspicious of their peers
  * Counter: They should be! Anyone could be compromised at any time.

* Engineers may spend more time thinking about security rather than features
  * Counter: Accept that higher security slows down development for quality.

* Engineers have a motivation to leave security vulnerabilities for their turn
  * Counter: Provide rewards for security issue discovery outside of game

* Engineers have the ability to collude and split winnings
  * Counter: Terminate dishonest employees with extreme prejudice.

## Unresolved Questions

How far should this be allowed to go? Is phishing and exploitation of
unattended machines or keyloggers fair game?

## Future Work

Deploy in real world organizations and share results :)
