# Lifesize security audit

## Lifesize Icon 450

Firmware Audited:
   Build date: Mon Aug 28 07:08:05 CDT 2017
   Build host: ausbuildlifesizecodecicon02 (127.0.1.1)
   Build location: 
   http://artifacts.lifesize.com/artifactory/lifesize.icon.production/lifesize.icon.production.master.sequoia.full-3.4.0.2268.tar.gz
   Build version: LS_RM3_3.4.0 (2268)
   Build type: PRODUCTION
   Build target: sequoia
   SVN; SVN%  

Findings:
* Exposed ssh out of the box
  * Username admin, password admin
  * Ssh host private key was easily extracted from firmware update dump
* Exposes an sftp server with public key access only
  * Private key was easily extracted from firmware dump
  * Access filtered only by local ip address
* Running linux kernel 2.6.37
  * 6 years old
  * 100+ known vulns http://www.cvedetails.com/version/123871/Linux-Linux-Kernel-2.6.37.html
* Glibc 2.9
  * 13+ known vulns https://www.cvedetails.com/vulnerability-list/vendor_id-72/product_id-767/version_id-92270/GNU-Glibc-2.9.html
* Firmware Signing
  * Bootloader image verification pubkey in unsigned/unsecured bootloader
  * Firmware signature verification is not enforced via fuse array or other immutable measure. Can be easily bypassed allowing installation of a malicious payload.

## Lifesize Screen Sharing And Scheduling - Chrome Plugin

Version: Chrome Web Store release as of 09/0/17

Findings:
* Full access to browser history and *.lifesize.com domains
* Jquery 2.1.4
  * 3 years old
  * Not needed at all in chrome which provides all the needed APIs in native javascript
  * Known XSS and DoS vulns https://snyk.io/test/npm/jquery/2.1.4
* NPM dependencies are locked using only fuzzy versions and no hash locking. Dependency attacks are on the table if no other mitigations are present.
