# How to install Arch Linux: The TL;DR

## Overview

This guide is meant to be an opinionated and to the point guide on installing
Arch Linux. Power users with different opinions should refer to the official
[Arch Linux installation guide][1].

[1]:https://wiki.archlinux.org/index.php/Installation_guide

## Requirements
 * These steps are best done on a Linux or OSX computer to run early steps.
   * Windows users may use WSL (Windows Subsystem for Linux)
   * Or can use an [Ubuntu live CD][1]
 * A blank flash drive, 1GB+
 * Target computer
    * Known to be compatible with Linux
    * Supports UEFI boot
    * Has wireless card
    * Does not require proprietary "out of tree" drivers

[1]: https://www.ubuntu.com/download/desktop

## Goals
 * Full disk encryption
 * Passwordless: Use GPG Smartcard for login, sudo, ssh
 * Simple partitioning scheme

## Steps

1. Download latest Arch Linux ISO image file
  1. Install torrent client such as aria2
  2. Get latest .iso.torrent URL from [Arch Linux releases][1]
  3. Download ISO with aria2.

    Example:
    ```
    aria2c --on-download-complete=exit https://YOUR_TORRENT_URL_HERE
    ```

[1]: https://mirrors.kernel.org/archlinux/iso/latest/

2. Write latest ISO to flash drive
  1. List current storage devices with `lsblk`
  2. Insert flash drive
  3. List current storage devices with `lsblk` again
  4. Take note of new drive. Example: /dev/sdX
  5. Use `dd` to write ISO image to drive

    ```
    sudo dd \
      bs=4M \
      if=archlinux-DATE-x86_64.iso \
      of=/dev/sdX \
      status=progress \
      oflag=sync
    ```
  6. Remove flash drive

3. Boot flash drive of target laptop
  1. Insert flash drive
  2. Boot laptop to BIOS screen
    * e.g. F1, F2, F10, Delete, Escape while computer starts booting
  3. Check that 'secure boot' is Disabled
  4. Ensure USB drives will boot by default
  5. Boot on installation medium

4. Adjust rotation, fonts, keyboard layout
  1. Change rotation if needed

    ```
    echo 1 > /sys/class/graphics/fbcon/rotate_all
    ```
   Note: May need to use 2 or 3 depending on starting state

  2. Increase font size if needed

    ```
    setfont /usr/share/kbd/consolefonts/latarcyrheb-sun32.psfu.gz
    ```
    Note: This is the current largest font

  3. Set desired keyboard layout (if not US standard)

    Example: German
    ```
    loadkeys de-latin1
    ```

5. Connect to the internet
  1. Select and join a wireless network with `wifi-menu`
  2. Verify connection with `ping 1.1.1.1`

6. Update system clock

   ```
   timedatectl set-ntp true
   ```

7. Set up encrypted disk
  1. Determine target root device with `lsblk`. Example: /dev/mmcblk0
  2. Create all partitions

    TL:DR;
    ```
    sgdisk -Zo -n 1:2048:+512M -t 1:EF00 -c 1:boot -N 2 -t 2:8300 -c 2:root /dev/mmcblk0
    ```

    Explanation:
    ```
    sgdisk \
       -Zo             `# zero out any existing partitions` \
       -n 1:2048:+512M `# create new 512M partition for boot` \
       -t 1:EF00       `# set type to EFI` \
       -c 1:boot       `# set comment/label to "boot"` \
       -N 2            `# create second new partition filling rest of disk` \
       -t 2:8300       `# set type Linux` \
       -c 2:root       `# set comment/label to "root"` \
       /dev/mmcblk0     # writing to your target drive
     ```

    Note: As an alternative, you can graphically partition using `cgdisk`

  3. Format the EFI boot partition as FAT32

     ```
     mkfs.vfat -F32 /dev/mmcblk0p1
     ```

  4. Encrypt and format the root partition

     ```
     # encrypt root partition with passphrase
     cryptsetup -y -v luksFormat --type luks2 /dev/mmcblk0p2

     # decrypt drive and expose as /dev/mapper/cryptroot
     cryptsetup open /dev/mmcblk0p2 cryptroot

     # make journaled ext4 partition in decrypted root device
     mkfs.ext4 -j /dev/mapper/cryptroot
     ```

8. Mount the file systems

  ```
  mount /dev/mapper/cryptroot /mnt
  mkdir /mnt/boot
  mount /dev/mmcblk0p1 /mnt/boot
  ```

9. Select the Mirrors

  ```
  pacman -Sy reflector
  reflector --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
  ```

  Note: This avoids manual mirror sorting. Native script does not yet exist.

10. Install packages
    1. Base packages

    ```
    pacstrap /mnt base
    ```
    2. Secondary, but useful and necessary packages

    TL;DR:
    ```
    pacman -S sudo dialog wpa_supplicant iw vim git pcscd libu2f-host pcsclite \
      chromium arandr compton i3 dmenu kitty nitrogen slock xorg xf86-video-intel
    ```

    Explanation:
    ```
    pacman -S \
      sudo             `# "super user do": allows user to run commands as root` \
      dialog           `# terminal menu system, needed for "wifi-menu"` \
      wpa_supplicant   `# tools for managing encrypted wireless networks` \
      iw               `# wireless management CLI utility` \
      vim              `# alternative text editor to "nano"` \
      git              `# used to download and track source code` \
      pcsclite         `# daemon for managing smartcard access` \
      libu2f-host      `# allow U2F/2FA smartcard for some applications` \
      chromium         `# open source edition of Chrome` \
      arandr           `# graphical screen/resolution management` \
      compton          `# hardware accelerated desktop layer` \
      i3-wm            `# tiling window manager` \
      dmenu            `# graphical command runner menu` \
      kitty            `# graphical terminal emulator` \
      nitrogen         `# wallpaper manager` \
      slock            `# simple lock screen` \
      xorg             `# graphical user interface infrastructure` \
      xf86-video-intel `# graphics driver for Intel chipsets`
    ```

    Note: Non-Intel graphics users, see: [Arch Driver Installation][2]


11. Configure the System
  1. Fstab: Generate 'File System TABle' of contents

  ```
  genfstab -U /mnt >> /mnt/etc/fstab
  ```

  2. Chroot: login to new arch installation by changing root

  ```
  arch-chroot /mnt
  ```
  3. Initramfs: install system initialization bundle

  ```
  # Enable encryption support in initramfs
  sed -i 's/ filesystems/ encrypt filesystems/g' /etc/mkinitcpio.conf

  # Generate new initramfs
  mkinitcpio -p linux
  ```

  4. Configure and install bootloader

  ```
  bootctl --path=/boot install
  echo "default arch" > /boot/loader/loader.conf
  echo "title Arch Linux" >> /boot/loader/entries/arch.conf
  echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
  echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
  echo "options cryptdevice=UUID=$(blkid -o value /dev/mmcblk0p2 \
    | head -n1):cryptroot root=/dev/mapper/cryptroot rw" >> \
    /boot/loader/entries/arch.conf
  ```

  5. Configure system time keeping

  ```
  timedatectl set-ntp true
  timedatectl set-timezone Region/City
  hwclock --systohc
  ```

  6. Localization: setting your preferred language

  ```
  # Uncomment preferred language in /etc/locale.gen
  sed -i 's/^#en_US/en_US/g' /etc/locale.gen

  # Create /etc/locale.conf and set default language
  echo "LANG=en_US.UTF-8" > /etc/locale.conf

  # Non-US keyboard users can set their default layout
  echo "KEYMAP=de-latin1" > /etc/vconsole.conf

  # Re-generate locales
  locale-gen
  ```

  7. Persist rotation and font as desired

    1. Rotation

    ```
    sed -i '$s/$/ fbcon=rotate:1/' /boot/loader/entries/arch.conf
    ```

    2. Font

    ```
    echo "FONT=latarcyrheb-sun32" >> /etc/vconsole.conf
    ```

  8. Name your computer!

  ```
  # Create the hostname file
  hostnamectl set-hostname computername

  # Specify new hostname for the network
  echo "127.0.0.1 computername.localdomain computername localhost" > /etc/hosts
  echo "::1 computername.localdomain computername localhost" >> /etc/hosts
  ```

  9. Create a user with super user rights

  ```
  echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
  useradd -m -G wheel -s /bin/bash janedoe
  passwd janedoe
  ```

  10. Configure graphical environment

  TL;DR:
  ```
  echo "gpg-connect-agent updatestartuptty /bye \n i3" > .xinitrc
  sed -i "s/i3-sensible-terminal/kitty/g" .config/i3/config
  mkdir -p /etc/systemd/system/getty@tty1.service.d
  echo -e "[Service]\nExecStart=\nExecStart=-/usr/bin/agetty -a janedoe -J %I $TERM" \
    > /etc/systemd/system/getty@tty1.service.d/override.conf
  echo '[[ -z $DISPLAY && ! -e /tmp/.X11-unix/X0 ]] && (( EUID )) && exec startx' \
    > /home/janedoe/.bash_profile
  chown janedoe:janedoe /home/janedoe/.bash_profile
  ```

  Explanation:
  ```
  cat <<-EOF > .xinitrc
    #!/bin/bash

    # Let GPG know about our current terminal
    gpg-connect-agent updatestartuptty /bye

    # Optional: Start compositor for faster rendering for terminals etc
    # compton &

    # Optional: Set wallpaper
    # nitrogen --set-scaled ~/.wallpaper/yourcoolwallpaper.jpg

    # Optional: Start terminal
    # kitty &

    # Optional: Set resolution and rotation
    # xrandr --output HDMI1 --off --output DP1 --off --output eDP1 --mode 1200x1920 --pos 0x0 --rotate right --output VIRTUAL1 --off
    # xinput set-prop 15 --type=float "Coordinate Transformation Matrix" 0 1 0 -1 0 1 0 0 1

    # Start Window manager
    i3
  EOF

  # Set default terminal
  sed -i "s/i3-sensible-terminal/kitty/g" .config/i3/config

  # Automatically login janedoe user on boot
  mkdir -p /etc/systemd/system/getty@tty1.service.d
  cat <<-EOF > /etc/systemd/system/getty@tty1.service.d/override.conf
    [Service]
    ExecStart=
    ExecStart=-/usr/bin/agetty --autologin janedoe --noclear %I $TERM
  EOF

  # Automatically start graphical environment if not already running
  echo '[[ -z $DISPLAY && ! -e /tmp/.X11-unix/X0 ]] && (( EUID )) && exec startx' \
    > /home/janedoe/.bash_profile
  chown janedoe:janedoe /home/janedoe/.bash_profile
  ```

  11. Boot into Arch
    1. Shutdown with

      ```
      exit
      shutdown -h now
      ```

    2. Remove flash drive

    3. Boot computer

## Recovery

If you need to resume from a broken or partial install, perform steps 3-5 then:

  ```
  cryptsetup open /dev/mmcblk0p2 cryptroot
  mount /dev/mapper/cryptroot /mnt
  mount /dev/mmcblk0p1 /mnt/boot
  arch-chroot /mnt
  ```

## References
 * [Encrypting entire system with LUKS][1]

[1]: https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#LUKS_on_a_partition

[2]: https://wiki.archlinux.org/index.php/xorg#Driver_installation
