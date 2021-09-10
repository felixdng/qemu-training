qemu-system-arm -M vexpress-a9 -m 128M -kernel zImage -dtb vexpress-v2p-ca9.dtb -sd rootfs.ext3 -nographic \
-append "init=/linuxrc root=/dev/mmcblk0 rw console=ttyAMA0 ip=192.168.131.200" \
-net nic -net tap,ifname=tap0,script=no,downscript=no
