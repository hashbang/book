# Hierarchical Deterministic Wallets (HD Wallets)
HD wallets are in fact just a keypair called "extended keys", consisting of an extended public (`xpub`) and extended private (`xpriv`) key, derived using ECC (elliptic curve cryptography), which can be used to generate "child keypairs" in a deterministic manner. They are a convenient way to improve privacy, as they make it easy to generate new "addresses". Child keypairs can also have children, which allows you to create a tree of keys via [derivation paths](https://ethereum.stackexchange.com/questions/70017/can-someone-explain-the-meaning-of-derivation-path-in-wallet-in-plain-english-s)

Additionally, the `xpub` can be used independently of `xpriv` to generate just child public keys, without the corresponding child private key. One thing to keep in mind is that by having access to `xpub` and one child private key, **`xpriv` can be derived**. 

### Start Hardware Entropy Generator (Optional)
If you want to be extra paranoid you can use a hardware random number generator such as an Infinite Noise or a TrueRNG.

This will rule out the possibility of a flaw in the software random number generator built into your system that allows an attacker to predict it and re-create any secret keys you generate during this process.

In the case of an Infinite Noise device you can insert it and run:

```
sudo infnoise --dev-random &
```
 
## Generate 24 Word Mnemonic Seed
Mnemonic seed phrases are used to recover an HD Wallet using a set of words which can be used to deterministically reconstruct the main keypair. An example of this is [BIP 0039](https://en.bitcoin.it/wiki/BIP_0039) 

### Option 1: Symmetric Encryption (Passphrase)
```
bx seed -b 256 | bx mnemonic-new | gpg -ac > mnemonic.asc
```
### Option 2: Asymmetric Encryption (To imported public key)
You will need to copy your GPG public keys to a flash drive on another system.

Assuming the drive is is `/dev/sda` you could do:
```
mount /dev/sda1 /mnt/
gpg --import /mnt/your-pubkey.asc
bx seed -b 256 | bx mnemonic-new | gpg -aer 0xYOURKEYID > mnemonic.asc
```

### Option 3: Roll The Dice
Rolling dice is also a sufficiently random source of entropy to generate your mnemonic seed phrase, and arguably a better source of entropy than hardware at least with regards to how easy they are to trust, as long as you don't use 1 die, as it may be biased, and use a proper table of words to select your words from. The recommended method would be to use at least a dozen dice, or more if available, preferably from a few different manufacturers, using an approach such as one described [here](https://github.com/taelfrinn/Bip39-diceware)


## Backup 

### Option 1: Flash Drive #####
Identify attached flash drive:
```
lsblk
```

Format (assuming drive is /dev/sdb)

**CAREFUL: this will reformat your drive, so if you have something important on it, back it up before running the following command**
```
sudo mkfs.ext4 -j /dev/sdb
```

Mount filesystem:
```
sudo mkdir /mnt/backup
sudo mount /dev/sdb /mnt/backup
```

Copy backup file:
```
cp mnemonic.asc /mnt/backup/
```

Unmount drive:
```
unmount -l /mnt/backup
```

### Option 2: NFC Tag

#### Convert GPG to NDEF

```
ndeftool text "'$(cat mnemonic.asc)'" save mnemonic.ndef
```

#### Write NDEF

Mifare Classic tag:
```
mifare-classic-write-ndef -y -i mnemonic.ndef
```

Forum 2 tag:
```
tagtool load mnemonic.ndef
```

#### Read NDEF

Mifare Classic tag:
```
mifare-classic-read-ndef -y -o mnemonic.ndef
```

Forum 2 tag:
```
tagtool dump -o mnemonic.ndef
```

#### Convert NDEF to GPG

```
ndeftool load mnemonic.ndef print | sed 's/^[^-]\+\-/-/g' > mnemonic.asc
```

#### Decrypt GPG

```
gpg -d mnemonic.asc
```

## Initialize Hardware Wallet

### Trezor

```
trezorctl recovery_device -w 24 -t matrix
```

### Keepkey

```
keepkeyctl recovery_device -w 24
```

### Ledger
You will need to choose a pin code.

Assuming you choose PIN 12345678:
```
btchip_setup \
  "WALLET" \
  "RFC6979" \
  "" \
  "" \
  "12345678" # Your pin here \
  "" \
  "QWERTY" \
  "$(bx mnemonic-to-seed --language en $(gpg -d mnemonic.asc))" \
  "" \
  ""
```


