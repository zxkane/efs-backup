#!/bin/bash
# Example would be to run this script as follows:
# Once a day; retain last 31 days
# efs-backup.sh $src $dst daily 31 efs-12345
# Once a week; retain 4 weeks of backup
# efs-backup.sh $src $dst weekly 7 efs-12345
# Once a month; retain 3 months of backups
# efs-backup.sh $src $dst monthly 3 efs-12345
#
# Snapshots will look like:
# $dst/$efsid/hourly.0-3; daily.0-30; weekly.0-3; monthly.0-2


# input arguments
export source=/mnt/efs/repos/
export dest=/mnt/efs/open-mirror/

echo "-- $(date -u +%FT%T) -- sudo yum -y install parallel"
sudo yum -y install parallel
echo "-- $(date -u +%FT%T) -- sudo yum -y install --enablerepo=epel tree"
sudo yum -y install --enablerepo=epel tree
echo "-- $(date -u +%FT%T) -- sudo yum -y groupinstall 'Development Tools'"
sudo yum -y groupinstall "Development Tools"
echo '-- $(date -u +%FT%T) -- wget https://github.com/martymac/fpart/archive/fpart-1.0.0.zip'
wget https://github.com/martymac/fpart/archive/fpart-1.0.0.zip
unzip fpart-1.0.0.zip
cd fpart-fpart-1.0.0/
autoreconf -i
./configure
make
sudo make install

# Adding PATH
PATH=$PATH:/usr/local/bin

_thread_count=$(($(nproc --all) * 16))

echo "-- $(date -u +%FT%T) --  sudo rm /tmp/efs-backup.log"
sudo rm /tmp/efs-backup.log

# start fpsync process
echo "Stating backup....."
echo "-- $(date -u +%FT%T) --  sudo \"PATH=$PATH\" /usr/local/bin/fpsync -n $_thread_count -o \"-a --stats --numeric-ids --log-file=/tmp/efs-backup.log\" $source $dest"
sudo "PATH=$PATH" /usr/local/bin/fpsync -n $_thread_count -v -o "-a --stats --numeric-ids --log-file=/tmp/efs-backup.log" $source $dest &>/tmp/efs-fpsync.log
fpsyncStatus=$?
echo "fpsyncStatus:$fpsyncStatus"

exit $fpsyncStatus
