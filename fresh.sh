#!/bin/bash
# new arch (probably manjaro) machine setup script.
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
# switch to the unstable branch(i like living on the edge).
sudo pacman-mirrors -aB unstable
echo "updating new databases..."
sleep 2
# update the databases.
sudo pacman -Syyu pacaur 
echo "installing some common apps..."
sudo pacaur -S zsh google-chrome-dev termite spotify telegram-desktop wps-office sublime-text-dev
echo "setting default shell..."
chsh -s /bin/zsh
echo "Setting up based on dotfiles..."
#powerline fonts
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd -
rm -rf fonts

#my dotfiles
git clone https://github.com/Blacksuan19/Dotfiles.git ~/.dotfiles
cd ~/.dotfiles
ln  .tmux.conf ~/.tmux.conf
ln  .tmux.conf.local ~/.tmux.conf.local
cp config ~/.config/termite/
cp .dircolors ~/.dircolors
cp .zsh ~/.zsh
ln .zsh/config.zsh ~/.zsh/config/zsh
cp .zprezto ~/.zprezto
cp .z* ~/ # all dem zsh files
cp -
git clone https://github.com/Blacksuan19/Scripts.git
cd Scripts
sudo cp Spotify.sh /bin/sp
cp Lyrics.sh ~/.lyrics
cd -
echo "script finished"
echo "new machine setup completed."