#mount new one
/sbin/mount.zfs mainpool/main@hourly_$hour /zfs_snapshot/main/hourly/$hour
