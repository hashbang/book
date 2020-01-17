# Zoom Company Audit #

## People

### Eric S Yuan
* Email: ericsyuan2011@gmail.com
   * Password leaks:
      * "Data Enrichment Records" leak (2016)
      * Dropbox (2012)
      * Experian (2015)
      * Kickstarter (2014)
      * LinkedIn (2012)
   * SMS 2FA
      * Bypass allowed with security questions
   * Security Question #1: "What is your hometown?"
      * Answer: Shandong
   * Security Question #2: "What is the phone number registered with your account?"
      * Answer: 1.4084838813

## Domains

### Zoom.us
* Registrar: Godaddy
* Registrant email: ericsyuan2011@gmail.com
* HPKP: Disabled
  * Enabling with a false certificate could be used for a long term DoS
* HSTS: Broken
  * Preloading is not enabled
     * Enabling preloading with a false cert could cause long term DoS
  * max-age is invalid
  * No includeSubDomains directive

#### Conclusion

Complete takeover of DNS is probably possible due to weak registrant email security.

# Zoom Controller Audit #

## Access

```
wget http://hybridupdate.zoom.us/latest/controller/system.vmdk
qemu-img convert -f vmdk -O raw system.vmdk zoom.img
mount -o loop zoom.img /mnt/zoom
mkdir /mnt/zoom
sudo mount -o loop,offset=1209008128 zoom.img /mnt/zoom
sudo mount -o loop,offset=135266304 zoom.img /mnt/zoom/boot
```

## Evaluation

### General Observations

* OS image is http downloaded by default
* No OS image signing/verification
    * Potential to MITM inject malicious firmware
* Linux 2.6.2 kernel
    * Released in 2004
    * 493 Published Vulnerabilities
    * https://www.cvedetails.com/vulnerability-list/vendor_id-33/product_id-47/version_id-12834/Linux-Linux-Kernel-2.6.2.html
* No bootloader protection
    * Can easily walk up to machine and add init=/bin/bash to grub for root shell
* root password is set to a default /etc/passwd
* AWS/GPG credentials in /opt/s3/s3cfg
* SSH Host private keys in /etc/ssh
* SSB Private keys/certs in /opt/zoom/conf
* Cached copies of image provisioning scripts in /tmp
    * Contains details about internal Zoom network resources
* Login portal served from /mnt/zoom/opt/vmware/share/htdocs
* Web portal served with vami-lighttpd 1.4.29
    * TLS key is randomly generated, with no pinning
    * TLS 1.0 and known weak ciphers via CVE-2013-4508

### Interesting Binaries

#### /opt/zoom/bin/mmr

```
DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             ELF, 32-bit LSB executable, Intel 80386, version 1 (SYSV)
5428764       0x52D61C        Unix path: /usr/local/ssl/private
17438464      0x10A1700       Unix path: /App/nydus/source/fec
17464125      0x10A7B3D       Unix path: /App/nydus/source/utilities
20058184      0x1321048       Unix path: /home/official/zoomdm/Common/platform/tp/src
31247778      0x1DCCDA2       mcrypt 2.2 encrypted data, algorithm: blowfish-448, mode: CBC, keymode: 8bit
31330762      0x1DE11CA       mcrypt 2.2 encrypted data, algorithm: blowfish-448, mode: CBC, keymode: 8bit
31330786      0x1DE11E2       mcrypt 2.2 encrypted data, algorithm: blowfish-448, mode: CBC, keymode: 8bit
```

#### /opt/zoom/bin/zctrl
```
DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             ELF, 32-bit LSB executable, Intel 80386, version 1 (SYSV)
2283          0x8EB           mcrypt 2.2 encrypted data, algorithm: blowfish-448, mode: CBC, keymode: 8bit
4325334       0x41FFD6        Unix path: /../Common/platform/util/h/stream.h
4329700       0x4210E4        Unix path: /../Common/web/meeting.pb.h
4361314       0x428C62        Unix path: /../Common/web/meeting.pb.cc
4377110       0x42CA16        Unix path: /../Common/platform/conf/zc_pdu.cpp
4393898       0x430BAA        Unix path: /../../platform/util/h/defer_op.hpp
15312206      0xE9A54E        Unix path: /home/official/zoomdm/Platform/zc
17048860      0x104251C       Unix path: /home/official/zoomdm/Common/platform/util/src
16341448      0xF959C8        Unix path: /../Common/web/meeting.pb.cc
```

Other paths from strings:

* /home/official/zoomdm/Common/awssdk
* /home/official/zoomdm/Common/platform/tp/src
* /home/official/zoomdm/Common/platform/util/src

#### /opt/zoom/bin/mlar
```
DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             ELF, 32-bit LSB executable, Intel 80386, version 1 (SYSV)
2207452       0x21AEDC        Unix path: /usr/local/ssl/private
5316039       0x511DC7        Unix path: /home/rola/svn/trunk/Platform/mlar
```

# Browser Plugin

* Full access to browser history and *.zoom.com and calendar.google.com domains
* Unrestricted TCP access on 0.0.0.0 (Should only need localhost and a single port or two at most.)
* Jquery 2.1.4
  * 3 years old
  * Not needed at all in chrome which provides all the needed APIs in native javascript
  * Known XSS and DoS vulns https://snyk.io/test/npm/jquery/2.1.4
