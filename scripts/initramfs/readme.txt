
# 先编译好busybox
# 安装目录假设是_install

cd _install
touch init
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz

# qemu启动选项为：
qemu-system-x86_64 -M pc \
  -kernel bzImage \
  -m 1024M -smp 1 -nographic \
  -initrd initramfs.cpio.gz \
  -append "init=/init console=ttyS0"

