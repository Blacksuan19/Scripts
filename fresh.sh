#! /usr/bin/bash
# new arch (probably manjaro)machine setup script.
echo "this script will do some stuff you do when you install a new distro (reinstall software, configure mirrors etc..."
sleep 2
echo "enabling custom repo's..."
sleep 2
# copy the lines to the end of pacman config to enable these repo's 
cat <<EOT >> /etc/pacman.conf 

[blackeagle-pre-community]
Server = http://repo.herecura.be/$repo/$arch

[herecura]
Server = http://repo.herecura.be/$repo/$arch

[herecura-testing]
Server = https://repo.herecura.be/herecura-testing/x86_64
EOT
echo "switching to unstable branch (this might take a while)..."
sleep 2
# switch to the unstable branch.
sudo pacman-mirrors -b unstable
echo "updating new databases..."
sleep 2
# update the databases.
sudo pacman -Syyu 
echo "the old packages list should be named as old.txt"
sleep 2
# get list of installed packages for comparison.
pacman -Q > new.txt
# get the difference between the two files and also delete the trailing package version numbers and the small sign and output it to a file.
diff new.txt old.txt | grep '^[<]' | sed 's/1234567890.//g' | sed 's/<//g' > diff.txt 
# install only the packages available on the pacman repo's and not already installed.
sudo pacman -S --needed $(comm -12 <(pacman -Slq | sort) <(sort diff.txt))  
# install aur packages after filtering them. 
sudo yaourt -S --needed $(comm -12 <(yaourt -Slq | sort) <(sort diff.txt)) 
echo "script finished"
echo "new machine setup completed."