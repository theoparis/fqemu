# fqemu

Start qemu virtual machines with a simple fish shell script.

## Install QEMU

### Chimera Linux

For x86_64 host this should be enough

```console
# apk add qemu qemu-img qemu-system-x86_64 cmd:remote-viewer
```

## How to use

Clone this repo

```console
> https://github.com/denisstrizhkin/fqemu.git
> cd fqemu
```

Create directory for a new vm and copy the script

```console
> mkdir /path/to/vm/dir
> cp fqemu /path/to/vm/dir
> cd /path/to/vm/dir
```

Setup empty disk and UEFI vars

```
> ./fqemu setup
```

Start the vm with mounted iso

```
> ./fqemu run --gui --iso /path/to/iso
```

Open spice client

```
> ./fqemu spice
```
