#!/bin/bash

DOM0_RAM=4096
DOM0_CPU_COUNT=1
XEN_NETWORK_MODE="bridge"
XEN_UTILS="$(command apt-cache pkgnames xen-utils)"

command sed -i -e 's/^(network-script .*).*$/# \0/' \
            -e 's/^(vif-script .*).*$/# \0/' \
         "/etc/xen/xend-config.sxp"

command sed -i -e "s/^#[ ]*\\((network-script.*network-${XEN_NETWORK_MODE}).*\\)\$/\\1/" \
            -e "s/^#[ ]*\\((vif-script.*vif-${XEN_NETWORK_MODE}).*\\)\$/\\1/" \
         "/etc/xen/xend-config.sxp"

if [ ! -e '/etc/xen/scripts/hotplugpath.sh' ]; then
  command touch '/etc/xen/scripts/hotplugpath.sh'
fi

command test -x '/etc/init.d/xen' && /etc/init.d/xen restart
command test -x '/etc/init.d/xend' && /etc/init.d/xend restart

if [ -e '/etc/default/grub' ]; then
  command sed -i -e "s/\(GRUB_CMDLINE_XEN_DEFAULT=.*\)\"/\1 dom0_mem=${DOM0_RAM}M\"/" \
         '/etc/default/grub'
fi
if [ -e '/boot/grub/menu.lst' ]; then
  command sed -i -e "s/\(xenhopt=.*\)/\1 dom0_mem=${DOM0_RAM}M/" \
         '/boot/grub/menu.lst'
fi

command update-grub

command sed -i -e "s/^[# ]*\((dom0-min-mem\).*\().*\)$/\1 ${DOM0_RAM}\2/" \
         '/etc/xen/xend-config.sxp'

command reboot
