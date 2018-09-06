#!/bin/bash
# new arch (probably manjaro) machine setup script.
echo "this script will do some stuff you do when you install a new distro (reinstall software, configure mirrors etc..."
sleep 2
echo "enabling custom repo's..."
sleep 2
# copy the lines to the end of pacman config to enable these repo's 

#some variables

HOME=/home/dark-emperor
sudo cat <<EOT >> /etc/pacman.conf 

[blackeagle-pre-community]
Server = http://repo.herecura.be/blackeagle-pre-community/x86_64

[herecura]
Server = http://repo.herecura.be/herecura/x86_64

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
pacaur -S zsh google-chrome-dev termite spotify telegram-desktop wps-office sublime-text-dev tmux redshift tmux
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
git clone https://github.com/Blacksuan19/Dotfiles.git $HOME.dotfiles
cd $HOME/.dotfiles
ln .tmux.conf $HOME
ln .tmux.conf.local $HOME
cp .zshrc $HOME/ # all dem zsh files
rm $HOME/.zprezto/runcoms/zpreztorc
cp .zpreztorc $HOME/.zprezto/runcoms/zpreztorc
rm $HOME/.zprezto/modules/prompt/external/agnoster/agnoster.zsh-theme
cp agnoster.zsh-theme $HOME/.zprezto/modules/prompt/external/agnoster
cp config $HOME/.config/termite/
cp .dircolors $HOME/.dircolors
mkdir $HOME/.zsh
ln .config.zsh $HOME/.zsh/config/zsh
cp command-time.plugin.zsh $HOME/.zsh/command-time.plugin.zsh
git clone https://github.com/zdharma/fast-syntax-highlighting.git $HOME/.zsh/fast-syntax-highlighting
cp -

git clone https://github.com/Blacksuan19/Scripts.git
cd Scripts
sudo cp Spotify.sh /bin/sp
chmod +x /bin/sp
cp Lyrics.sh $HOME/.lyrics
cd -
echo "Done setting up dotfiles"

echo " configuring themes..."
#desktop themes
git clone https://github.com/Blacksuan19/Plasma-Themes.git
cd Plasma-Themes
mkdir $HOME/.local/share/plasma/desktoptheme
cp -r * $HOME/.local/share/plasma/desktoptheme/
cd - 
rm -rf Plasma-Themes

#icon pack
git clone https://github.com/ishovkun/Dex.git
cd Dex
sudo cp -r * /usr/share/icons
cd -
rm -rf Dex
echo "script finished"
echo "new machine setup completed."