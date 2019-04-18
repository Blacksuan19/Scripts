#!/bin/bash

#fix grub in case its fucked up

sudo mount /dev/sda6 /mnt # mount boot direcotry to /mnt
sudo chattr -i /mnt/boot/grub/i386-pc/core.img # unlock core image
sudo grub-install --boot-directory=/mnt/boot --force /dev/sda # install 
sudo grub-install --boot-directory=/mnt/boot --force --recheck /dev/sda # recheck 
echo "Now Update grub config manually with grub-update after chrooting..."
sudo bash chroot.sh # need to chroot in order to update grub config
reboot #we done now