#!/bin/bash

DOM0_RAM=4096
DOM0_CPU_COUNT=1
XEN_NETWORK_MODE="bridge"
XEN_UTILS="$(command apt-cache pkgnames xen-utils)"

if [ "$(command uname --machine)" = "x86_64" ]; then
  if [ -n "$(command apt-cache pkgnames 'xen-linux-system-amd64')" ]; then
    command apt-get -y install xen-linux-system-amd64
  else
    command apt-get -y install xen-hypervisor-amd64 linux-image-2.6-xen-amd64 \
        linux-headers-2.6-xen-amd64 ${XEN_UTILS} bridge-utils
  fi
else
  if [ -n "$(command apt-cache pkgnames 'xen-linux-system-686-pae')" ]; then
    command apt-get install xen-linux-system-686-pae
  else
    command apt-get -y install xen-hypervisor-i386 linux-image-2.6-xen-686 \
        linux-headers-2.6-xen-686 ${XEN_UTILS} bridge-utils
  fi
fi


command dpkg-divert --divert '/etc/grub.d/05_linux_xen' --rename '/etc/grub.d/20_linux_xen'
echo '# Disable OS probing.
GRUB_DISABLE_OS_PROBER=true' >> '/etc/default/grub'

if [ -e '/etc/default/grub' ]; then
  if [ -z "$(command grep 'GRUB_CMDLINE_XEN' '/etc/default/grub')" ]; then
    echo '
# Xen kernels configuration
GRUB_CMDLINE_XEN_DEFAULT=""
GRUB_CMDLINE_XEN=""' >> '/etc/default/grub'
  fi
fi

# command update-grub
