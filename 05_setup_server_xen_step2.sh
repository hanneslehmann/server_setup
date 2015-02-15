#!/bin/bash

DOM0_RAM=4096
DOM0_CPU_COUNT=1
XEN_NETWORK_MODE="bridge"
XEN_UTILS="$(command apt-cache pkgnames xen-utils)"

command sed -i -e 's/^MODULES=.*/MODULES=most/' '/etc/initramfs-tools/initramfs.conf'
command sed -i -e 's/^MODULES=.*/MODULES=most/' '/etc/initramfs-tools/conf.d/'*

command update-initramfs -u

command sed -i -e "s/^[# ]*\((dom0-cpus\).*\().*\)\$/\1 ${DOM0_CPU_COUNT}\2/" \
         '/etc/xen/xend-config.sxp'

if [ -e '/etc/default/grub' ]; then
  command sed -i -e "s/\(GRUB_CMDLINE_XEN_DEFAULT=.*\)\"/\1 dom0_max_vcpus=${DOM0_CPU_COUNT} dom0_vcpus_pin=1\"/" \
         '/etc/default/grub'
fi
if [ -e '/boot/grub/menu.lst' ]; then
  command sed -i -e "s/\(xenhopt=.*\)/\1 dom0_max_vcpus=${DOM0_CPU_COUNT} dom0_vcpus_pin=1/" \
         '/boot/grub/menu.lst'
fi

command update-grub

# command reboot
