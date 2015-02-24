#!/bin/sh
# Simple script to put the disks in standby mode
# in case they cannot be stoppped via Nas4Free settings
# It can be used as a cronjob.
# It checks if the disks are part of a pool with a scrub
# in process, or if they are already in standby mode
# source: http://forums.nas4free.org/viewtopic.php?t=6191
ZPOOL=/sbin/zpool
SMARTCTL=/usr/local/sbin/smartctl
#Get names of our pools
pools=$($ZPOOL list -H -o name)
for pool in $pools; do
        echo "*---------- $pool ----------*"
        #Get device names for this pool
        pool_devices=$($ZPOOL  iostat -v $pool| grep da |awk '{print $1}')
                #We don't want to stop a disk while the pool is scrubbing, so let's check
                if $ZPOOL status -v $pool | grep -q "scrub in progress"; then
                echo " scrub in process... skipping"
                echo ""
        else
                for device in $pool_devices; do
                                        #If a disk is already stopped, then there is no need to stop it again
                                        if $SMARTCTL --nocheck standby -i /dev/$device | grep -q "STANDBY"; then
                                        echo "Disk $device is already in standby mode"
                                        else
                                        echo "Stopping disk $device"
                                        #Stop the disks
                                        camcontrol stop $device
                                        fi
                done
                echo "done.."
                sleep 5
        fi
done
