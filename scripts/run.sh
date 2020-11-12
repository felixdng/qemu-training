qemu-system-arm -M vexpress-a9 -m 128M -kernel zImage -dtb vexpress-v2p-ca9.dtb -sd rootfs.ext3 -nographic -append "init=/linuxrc root=/dev/mmcblk0 rw console=ttyAMA0"
