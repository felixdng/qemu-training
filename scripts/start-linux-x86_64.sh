#!/bin/bash

NFS=$1
if [ "${NFS}" = "nfs" ]; then
qemu-system-x86_64 -M pc \
  -kernel bzImage \
  -m 256M -smp 1 -nographic \
  -append "root=/dev/nfs rw nfsroot=192.168.131.60:/opt/nfsroot init=/linuxrc console=ttyS0 ip=192.168.131.81 user_debug=31" \
  -net nic,vlan=0 -net tap,vlan=0,ifname=tap0,script=no,downscript=no
elif [ "$1" = "ramfs" ]; then
qemu-system-x86_64 -M pc \
  -kernel bzImage \
  -m 512M -smp 1 -nographic \
  -initrd initramfs.cpio.gz \
  -append "init=/init console=ttyS0"
else
qemu-system-x86_64 -M pc \
  -kernel bzImage \
  -m 512M -smp 1 -nographic \
  -hda rootfs.ext3 \
  -append "root=/dev/sda rw init=/linuxrc console=ttyS0 user_debug=31"
fi
