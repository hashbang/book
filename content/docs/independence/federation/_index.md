---
title: Independence/Federation
type: docs
---

# Federation

If all of your data or services are located in one, centralized location, you offer a single point of failure to Murphy's Law. [Federation](https://en.wikipedia.org/wiki/Federation_\(information_technology\)) allows you to inter-connect like services between one-another. Basically, we're talking about __decentralizaion__.

## Examples

### Usenet

A well-known, early (1980) example of this kind of network is/was [Usenet](https://en.wikipedia.org/wiki/Usenet), where a computer, often in the users' homes, runs/ran software architected in a manner that connects over the same protocol with other, remote machines. Messages attached to "news servers" are sent to other servers, effectively [replicating](Replication.md) information, which can also be considered a [limitation](Limitations.md) when considering the potential `O(nm)` growth of the same bytes across the network. While the service is technically still "alive," its practical usage has declined due to other competing protocols and issues with user-directed mass-spam increasing year-over-year. But the fact that it remains at all, even in a ghost-like state speaks to the [resiliency](Resiliency.md) of a federated network. If it were an unprofitable service offered by Google, for example, they would not hesitate to shut it down.

### NextCloud

## Index

- [Replication](Replication.md)
- [Limitations](Limitations.md)
- [Resiliency](Resiliency.md)
