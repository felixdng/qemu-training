#!/bin/bash

qemu-system-arm -M vexpress-a9 \
		-m 128M \
		-kernel u-boot \
		-sd uboot.disk \
		-nographic \
		-net nic -net tap,ifname=tap0,script=no,downscript=no
