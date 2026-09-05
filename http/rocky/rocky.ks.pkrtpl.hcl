#version=RHEL10
text
eula --agreed
reboot

lang en_US.UTF-8
keyboard --vckeymap=us --xlayouts='us'
timezone Europe/Kyiv --utc

network --bootproto=dhcp --device=link --activate --hostname=${hostname}
rootpw --lock
user --name=${username} --groups=wheel --password='$6$rounds=4096$VAGRANTuser$FQr.uHVzF/9FGEkMLZrOkogAuidujs4RVzjTIIBemT36T8AFsOgvmp3PhuGOC.iITEmDrK504wThkl7KB2kEC0' --iscrypted
sshkey --username=${username} "${authorized_key}"

firewall --enabled --service=ssh
selinux --enforcing
bootloader --location=mbr
autopart --type=lvm
skipx
firstboot --disable

%packages
@^minimal-environment
openssh-server
sudo
curl
tar
%end

%post --log=/root/ks-post.log
echo '${username} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/${username}
chmod 440 /etc/sudoers.d/${username}
visudo -cf /etc/sudoers.d/${username}
%end
