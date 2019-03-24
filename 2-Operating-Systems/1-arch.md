# How to install Arch Linux: The TL;DR

## Overview

This guide is meant to be an opinionated and to the point guide on installing
Arch Linux. Power users with different opinions should refer to the official
[Arch Linux installation guide][1].

[1]:https://wiki.archlinux.org/index.php/Installation_guide

## Requirements
 * A Linux computer to run early steps
   * Can use an [Ubuntu live CD][1] if a Linux computer is not available
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
  1. List current storage devices with ```lsblk```
  2. Insert flash drive
  3. List current storage devices with ```lsblk``` again
  4. Take note of new drive. Example: /dev/sdX
  5. Use ```dd``` to write ISO image to drive

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
  1. Select and join a wireless network with ```wifi-menu```
  2. Verify connection with ```ping 1.1.1.1```

6. Update system clock

   ```
   timedatectl set-ntp true
   ```

7. Set up encrypted disk
  1. Determine target root device with ```lsblk```. Example: /dev/mmcblk0
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
  pacman -Sy pacman-contrib
  curl https://www.archlinux.org/mirrorlist/all/https/ \
  | sed 's/^#Server/Server/g' \
  | rankmirrors -n 0 - \
  > /etc/pacman.d/mirrorlist
  ```
  Note: This avoids manual mirror sorting. Native script does not yet exist.

10. Install the base packages

  ```
  pacstrap /mnt base
  ```

11. Configure the System
  1. Fstab: Generate 'File System TABle' of contents

  ```
  genfstab -U /mnt >> /mnt/etc/fstab
  ```

  2. Chroot: login to new arch installation by changing root

  ```
  arch-chroot /mnt
  ```

  3. Set time zone

  ```
  ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
  hwclock --systohc
  ```

  4. Localization: setting your preferred language

  ```
  # Uncomment preferred language in /etc/locale.gen
  sed -i 's/^#en_US/en_US/g' /etc/locale.gen

  # Create /etc/locale.conf and set default language
  echo "LANG=en_US.UTF-8" > /etc/locale.conf

  # Non-US keyboard users can set their default layout
  echo "KEYMAP=de-latin1" > /etc/vconsole.conf
  ```

  5. Name your computer!

  ```
  # Create the hostname file
  echo "computername" > /etc/hostname

  # Specify new hostname for the network
  echo "127.0.0.1 computername.localdomain computername localhost" > /etc/hosts
  echo "::1 computername.localdomain computername localhost" >> /etc/hosts
  ```

  6. Initramfs: install system initialization bundle

  ```
  # Enable encryption support in initramfs
  sed -i 's/ filesystems/ encrypt filesystems/g' /etc/mkinitcpio.conf

  # Generate new initramfs
  mkinitcpio -p linux
  ```

  7. Create a user with super user rights

  ```
  pacman -S sudo
  echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
  useradd -m -G wheel -s /bin/bash janedoe
  passwd janedoe
  ```

  8. Configure and install bootloader

  ```
  bootctl --path=/boot install
  echo "default arch" > /boot/loader/loader.conf
  echo "title Arch Linux" >> /boot/loader/entries/arch.conf
  echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
  echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
  echo "options cryptdevice=UUID=$(blkid -o value /dev/mmcblk0p2 | head -n1):cryptroot root=/dev/mapper/cryptroot rw" >> /boot/loader/entries/arch.conf
  ```

  9. Install critical packages

  ```
  pacman -S dialog wpa_supplicant iw
  ```

  10. Boot into Arch
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

