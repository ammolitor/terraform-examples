#!/bin/bash
set -ex

# backup fstab
echo "backup fstab in /etc/fstab.DEFAULT"
cat /etc/fstab > /etc/fstab.DEFAULT

# setup partitions on data disks
echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/xvdb

# create XFS filesystem and add to fstab
mkfs.xfs -L varwww -f /dev/xvdb1
test -e /var/www || mkdir -p /var/www
echo "LABEL=varwww /var/www xfs defaults,noatime 0 2" >> /etc/fstab
sync
mount /var/www

yum -y install httpd
systemctl start httpd

# create index.html
cat > /var/www/html/index.html << IDX
<html>
<p>Hello AWS World</p>
</html>
IDX

