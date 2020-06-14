#!/bin/bash
read groupname
echo "creating a group for SFTP"
groupadd ${groupname}
read username
read directoryofsftpuser
echo "adding a username in group"
useradd -g ${groupname} -d /${directoryofsftpuser} -s /sbin/nologin ${username}
read password
echo "${username}:${password}" | sudo chpasswd
#copying the sshd conf file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config-`date +%d-%b-%y`.bak
echo "configuring sftp server subsystem in sshd_config"
sed -i '/^Subsystem/s/^/#/' /etc/ssh/sshd_config
cat <<EOF >> /etc/ssh/sshd_config
Subsystem       sftp    internal-sftp -l verbose
Match Group ${groupname}
ChrootDirectory /sftp/%u
ForceCommand internal-sftp
EOF
echo "creating sftp home directory"
mkdir /sftp
echo "creating the individual directories of user"
mkdir /sftp/${username}
echo "directory the sftpuser will see after login"
mkdir /sftp/${username}/${directoryofsftpuser}
echo "giving appropriate permssion"
chown ${username}:${groupname} /sftp/${username}/${directoryofsftpuser}
echo "restarting sshd servcie"
service sshd restart
