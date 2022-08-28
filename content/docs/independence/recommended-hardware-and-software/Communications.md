---
title: Independence/Recommended Hardware and Software/Communications
type: docs
---

# Communications

You've got many chat apps that you use commonly, don't you?

> I can't get rid of my **Facebook** account because that's how I talk to my family.

> All of my international friends are on **WhatsApp**.

> I only know people that use **iMessage** on iPhones.

> I have to use **Slack** for work.

> What about all of my **Discord** servers?

Besides the proprietary nature of each of the clients you'd install on your devices, what's wrong with each of these and the _many_ other ways to get in touch with those you care about (and maybe some people you don't)? Well, they're all fragmented. You need to have each individual app to use its features and access their user base. They also track you and read your messages for the purposes of pushing ads on you.

Besides that, main problem with any chat platform is you need to have someone to talk to. What's the point if there's no sense of community?

Introducing the [Matrix](https://matrix.org/docs/guides/introduction) protocol, an Apache-licensed project that's seeing rapid adoption correlated with the evolution of fully-featured client apps that integrate with federated servers. What makes it special? It encrypts messages end-to-end by default on the client(s). Each client shares keys and message history between one another. As long as the authenticated sessions are "verified" through a simple process requiring a previously-verified login, it can be assumed that all user sessions are trusted.

What's even more interesting about Matrix is the concept of "bridging" existing platforms together. At the time of writing, the following services have published [bridges](https://matrix.org/bridges/).

- IRC
- Slack
- RSS
- Discord
- RocketChat
- iMessage
- Facebook Messenger
- Email
- SMS
- Mastodon
- libpurple
- GroupMe
- Skype
- WeChat
- Gitter
- Tox
- Twitter
- Mumble
- Mattermost
- Keybase
- Google Hangouts
- Instagram
- Signal
- Telegram
- WhatsApp
- Tencent QQ

### Hardware

#### Server

Spinning up your own home server is not necessary, but following [Matrix's installation guide](https://github.com/matrix-org/synapse#synapse-installation) will get you on track if you're interested in [federation](../federation/). If you're reading this, you're probably in that crowd. Required specs for a server will be modest.

#### Client

- Android phone
- GNU/Linux-based computer

### Software

#### Server

- Matrix's [Synapse](https://github.com/matrix-org/synapse) server

#### Client

- [Element](https://app.element.io/)
