#!/bin/fish

set fish_trace 1

# Path to your system's OVMF folder
set -g OVMF_PATH /usr/share/edk2-ovmf
# Set OVFM firmware file for your arch
set -g OVMF_FIRMWARE $OVMF_PATH/edk2-x86_64-code.fd
# Set OVFM vars file for your arch
set -g DEFAULT_OVMF_VARS $OVMF_PATH/edk2-i386-vars.fd
# Set path to localy stored vars
set -g OVMF_VARS ./vars.fd
# Path to vm's disk
set -g DISK_IMG ./disk.img
# Spice server port
set -g SPICE_PORT 5901
# Path to install iso
set -g ISO_ARGS -cdrom /mnt/data-0/linux/chimera/chimera-linux-x86_64-LIVE-20240707-base.iso

# Check if gui option is enabled
# TODO make it les retarde
set -g is_gui 0
if test $argv[2] = gui
    set is_gui 1
end

# Base run function
# TODO different network devices
function run_base
    qemu-system-x86_64 -enable-kvm \
        -drive if=pflash,format=raw,file=$OVMF_FIRMWARE,readonly=yes \
        -drive if=pflash,format=raw,file=$OVMF_VARS \
        -drive file=$DISK_IMG,if=virtio \
        -cpu host \
        -nic bridge,br=br0,model=virtio \
        -device virtio-rng-pci \
        -m 8G -smp 12 \
        $argv
end

# Start base run function with additional options
# TODO a bug with args order
function run
    if test $is_gui = 1
        run_base -vga qxl -spice port=$SPICE_PORT,addr=127.0.0.1,disable-ticketing=on \
            -audio driver=spice,model=virtio \
            -monitor stdio \
            $argv[..-2]
    else
        run_base -nographic \
            $argv
    end
end

# Start a spice client
function spice
    remote-viewer --hotkeys=toggle-fullscreen=shift+f11,release-cursor=ctrl+alt \
        spice://localhost:$SPICE_PORT
end

# Reset vm's disk file and OVMF vars
function reset
    cp $DEFAULT_OVMF_VARS $OVMF_VARS
    qemu-img create -f qcow2 $DISK_IMG 15G
end

# Display help message
function usage
    echo "usage fqemu: run/iso/reset/spice/help [gui]"
    echo "  - reset: reset vm's disk image and OVMF vars"
    echo "  - iso: run the vm with install iso attched"
    echo "  - run: run the vm"
    echo "  - spice: start spice client"
    echo "  - help: show this message"
end

switch $argv[1]
    case reset
        reset
    case run
        run $argv[2..]
    case iso
        run $ISO_ARGS $argv[2..]
    case spice
        spice
    case help
        usage
    case '*'
        usage
        return 1
end
