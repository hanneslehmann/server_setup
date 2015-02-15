#!/bin/bash

wget http://zfsonlinux.org/4D5843EA.asc -O - | apt-key add -
wget http://archive.zfsonlinux.org/debian/pool/main/z/zfsonlinux/zfsonlinux_4_all.deb
dpkg -i zfsonlinux_4_all.deb
apt-get update
apt-get -q -y install parted debian-zfs
zpool status

