## Security

**Note:** This section of the book is for education purposes only for
understanding how the underlying systems for security work. It is incredibly
easy to mess up a custom security implementation. Do not use these solutions
in a noneducational environment.

Now that you (probably) know some stuff about the internet, it's valuable to
learn the algorithms used to protect yourself from people who want to attack
you and your services.

A long time ago, people used protocols across local networks to access files.
Assuming no one could intercept traffic, there was no reason to worry about
whether or not someone could replace the files with a malicious version.
Obviously, this is no longer the case, and more and more cases continue to rise
up about how people end up getting hacked and your personal data ends up thrown
out onto the internet.

Software nowadays goes through a very long process to make it from the entity
who made the software until it's installed on your computer. During this
process, it is often possible for someone to slip up and make a mistake,
leading to the entire system being insecure and untrustable.

There are certain security measures that you should understand in order to make
sure that your data is as secure as possible. Throughout this chapter, we'll
take a look at possible ways to attack and prevent attacks against a source
that you can't trust.

Fundamentally, trust is a problem that is hard to solve. How do you know that
your computer is really your computer, if you leave it out of sight for a few
minutes? How do you know that, when you go to Facebook, your ISP (internet
service provider) is not hijacking that domain? Even if you can look at a file
on one computer and copy it over to another computer, how do you know that your
flash drive didn't strip out a security measure?

---

In other chapters, we explain things in a format listing "the hard way" and
"the easy way". We will not be doing that in this chapter. Security is a very
difficult field to get right, and can be off-putting for many people.

We will list multiple solutions instead, as security is something that should
extend into all aspects of technology. Security is a complicated problem to
solve, however, and sometimes a language might not have a solution to a
particular problem yet.

At the end of this chapter, we will be putting these skills to the ultimate
test: building a package manager. It will need to be secure in all aspects, to
where nothing short of forcing the author can cause a bad package to be
published.
