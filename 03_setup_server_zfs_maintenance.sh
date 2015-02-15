#!/bin/bash

parted /dev/disk/by-id/ata-WDC_WD30EFRX-68EUZN0_WD-WCC4N1DY435T mklabel gpt # -> ../../sdb
parted /dev/disk/by-id/ata-WDC_WD30EFRX-68EUZN0_WD-WCC4N5TST177 mklabel gpt # -> ../../sda

# Install zfs-auto-snapshot
wget -O /usr/local/sbin/zfs-auto-snapshot.sh https://raw.github.com/zfsonlinux/zfs-auto-snapshot/master/src/zfs-auto-snapshot.sh
chmod +x /usr/local/sbin/zfs-auto-snapshot.sh


# create script for daily snapshots
cat > /etc/cron.daily/zfs-snapshot-daily << EOL
#!/bin/bash

# set PATH
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# set filesystem name
ZFS_FS1="naspool/data"
ZFS_FS2="naspool/vol"

# run snapshot
zfs-auto-snapshot.sh --quiet --syslog --label=daily --keep=31 "$ZFS_FS1" 
zfs-auto-snapshot.sh --quiet --syslog --label=daily --keep=31 "$ZFS_FS2"
EOL

chmod +x /etc/cron.daily/zfs-snapshot-daily

echo "edit /usr/local/sbin/zfs-auto-snapshot.sh !"
echo "you can set opt_prefix='backup'"
echo "and"
zfs set com.sun:auto-snapshot=true naspool/data
# zfs get all naspool/data | grep auto-snapshot
echo "Output: naspool/data com.sun:auto-snapshot true local?"
zfs set snapdir=visible naspool/data
echo

# create autoscrub

cat > /etc/cron.weekly/zfs-scrub-weekly << EOL
#!/bin/bash

# set PATH
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# set pool name
ZFS_POOL="naspool"

# start scrub
zpool scrub "$ZFS_POOL" 
EOL
chmod +x /etc/cron.weekly/zfs-scrub-weekly
