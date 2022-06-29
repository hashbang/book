---
title: Using the Vault Qube
---

**Note:** This section implies that you have a hardware token such as a Yubikey
that supports OpenPGP operations and have a sys-usb qube that can pass the
hardware token to a Qube. This section does not yet include functionality such
as WebAuthn, but might later in the future.

## Configuring The Vault

The vault should be configured off of a Debian 11 base with, at least, the
programs `gpg-agent` and `scdaemon`. Following steps similar to the [split-gpg]
guide, the following must be configured on your vault qube (assuming the name
of your vault qube is `vault`):

### In `dom0`:

This installs the necessary components and creates a default policy to
automatically pass any qubes.Gpg, qubes.GpgImportKey, and qubes.Ssh requests to
a specified Qube, specifying the Qube as the default target. This ensures that
every operation requires explicit approval, but may be changed to `allow` to
allow operations to go directly to the Qube.

```sh
sudo qubes-dom0-update qubes-gpg-split-dom0
# Replace `vault` with your vault VM name
echo "@anyvm vault ask,default_target=vault" | sudo tee /etc/qubes-rpc/policy/qubes.Gpg
echo "@anyvm vault ask,default_target=vault" | sudo tee /etc/qubes-rpc/policy/qubes.GpgImportKey
echo "@anyvm vault ask,default_target=vault" | sudo tee /etc/qubes-rpc/policy/qubes.Ssh"
```

### In `vault`:

It is recommended to set the `vault` qube to boot on system boot. This can be
done by going to the Qube settings and using the toggle option "Start qube
automatically on boot" and clicking "apply".

The USB must be attached to the vault Qube before operations can be performed.
This can be done by clicking on the Qubes Devices tray applet, selecting the
Yubikey or other OpenPGP device, and selecting the Vault container.

**Note:** At this point in time, there is no split WebAuthn support, and the
hardware device must be reattached to the vault every time it is attached to
another qube to be used for WebAuthn operations.

To install the necessary components to use the vault as the gpg backend domain:

```sh
sudo apt install -y qubes-gpg-split
```

A timeout (default 5 minutes) for when the requests are automatically approved
may be configured by running the following as the standard user:

```sh
echo "export QUBES_GPG_AUTOACCEPT=86400" >> ~/.profile
```

### In the Template VM for `vault`:

These changes must be made in the template used for `vault` because the files
made in this step will not persist across reboots in `vault`. This script
should be placed in the `/etc/qubes-rpc/qubes.Ssh` file:

```sh
#!/bin/sh
# Qubes Split SSH Script

export SSH_AUTH_SOCK="/run/user/1000/gnupg/S.gpg-agent.ssh"

notify-send "[$(qubesdb-read /name)] SSH access from: $QREXEC_REMOTE_DOMAIN"

socat - "UNIX-CONNECT:$SSH_AUTH_SOCK"
```

And set the executable bit:

```sh
sudo chmod +x /etc/qubes-rpc/qubes.Ssh
```

## Configuring Clients

GPG can be run using the `qubes-gpg-client` wrapper:

```
export QUBES_GPG_DOMAIN=vault
# Should print no keys
gpg -K
# Should print all keys configured in the vault
qubes-gpg-client -K
```

### Creating a Socket for SSH

**Note:** Previous attempts at writing this document attempted to make use of
the `/run/` pseudo filesystem, but discovered that `/rw/config/rc.local` is run
before the `/run/` pseudo filesystem is usable. This method should be changed
in the future to use a user systemd unit.

In any VM that you'd like to access the SSH agent, place the following into
`/rw/config/rc.local`, replacing `vault` with the name of your vault VM:

```sh
SSH_VAULT_VM=vault
USER_ID=1000
USER_NAME=`id -nu $USER_ID`
SSH_AUTH_SOCK="/home/$USER_NAME/.ssh/S.ssh-agent"

if [ ! "$SSH_VAULT_VM" = "" ]; then
  sudo -u "$USER_NAME" mkdir -p "$(dirname $SSH_AUTH_SOCK)" 2>/tmp/output
  rm -f "$SSH_AUTH_SOCK"
  sudo -u "$USER_NAME" /bin/sh -c "umask 177 && exec socat 'UNIX-LISTEN:$SSH_AUTH_SOCK,fork' 'EXEC:qrexec-client-vm $SSH_VAULT_VM qubes.SshAgent'" &
fi
```

You should also place the following in your environment files:

```sh
export SSH_AUTH_SOCK="$HOME/.ssh/S.ssh-agent"
```

### Replacing `gpg` and `gpg2` with `qubes-gpg-agent-wrapper`

The `qubes-gpg-agent-wrapper` will automatically load the GPG domain from a
persistent directory and can be used as a replacement for `gpg` and `gpg2` in
most cases.

```sh
# Will persist across reboots.
sudo ln -s /usr/bin/qubes-gpg-client /usr/local/bin/gpg
sudo ln -s /usr/bin/qubes-gpg-client /usr/local/bin/gpg2
```

[split-gpg]: https://www.qubes-os.org/doc/split-gpg/
