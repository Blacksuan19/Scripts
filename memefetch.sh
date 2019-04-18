#!/usr/bin/env bash

# GENERAL

# set colors
f7=$'\e[37m'
f1=$'\e[31m'

# FUNCTIONS

# check if a command exists
exists() {
    command -v "$1" > /dev/null
}

# memed
memed() {
    echo "meme"
}

# not memed
not_memed() {
    echo "not a meme"
}

# look for kwin
check_wm() {
    if exists kwin_x11 || kwin_wayland; then
        memed
    else
        not_memed
    fi
}

# look for kde plasma
check_de() {
   if exists plasmashell; then
           memed

   else
       not_memed
   fi
}

# look for spotify or vlc
check_player() {
    if exists spotify || vlc; then
        memed
    else
        not_memed
    fi
}

# look for neofetch and sysinfo script
check_fetch() {
   if exists neofetch || exists ls ~/.sysinfo.sh; then
       memed
   else
       not_memed
   fi
}

# look for konsole
check_term() {
    if exists konsole; then
        memed
    else
        not_memed
    fi
}

# look for plank or latte
check_dock() {
    if exists plank || exists latte-dock; then
        memed
    else
        not_memed
    fi
}


check_browser() {
    if exists vivaldi-snapshot || exists vivaldi || exists google-chrome-stable; then 
        memed
    else
        not_memed
    fi
}
# look for code 
check_editor() {
    if exists vim ||  exists code; then
        memed
    else
        not_memed
    fi
}

# look for arch or manjaro
check_distro() {
    if [[ -f /etc/os-release ]]; then
        if grep -qiP '(manjaro)' /etc/os-release || grep -qiP '(arch)' /etc/os-release; then
            memed
        else
            not_memed
        fi
    else
        not_memed
    fi
}

# look for zsh
check_shell() {
    if exists zsh; then
        memed
    else
        not_memed
    fi
}

# OUTPUT
clear
cat << EOF


                                ███╗   ███╗ █████╗ ███╗   ██╗     ██╗ █████╗ ██████╗  ██████╗ 
                                ████╗ ████║██╔══██╗████╗  ██║     ██║██╔══██╗██╔══██╗██╔═══██╗
                                ██╔████╔██║███████║██╔██╗ ██║     ██║███████║██████╔╝██║   ██║
                                ██║╚██╔╝██║██╔══██║██║╚██╗██║██   ██║██╔══██║██╔══██╗██║   ██║
                                ██║ ╚═╝ ██║██║  ██║██║ ╚████║╚█████╔╝██║  ██║██║  ██║╚██████╔╝
                                ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ 
                                                            
                                            ${f1}Fetch:${f7} $(check_fetch)             ${f1}Editor:${f7} $(check_editor)
                                            ${f1}DE:${f7} $(check_de)                ${f1}Term:${f7} $(check_term)
                                            ${f1}Shell:${f7} $(check_shell)             ${f1}Dock:${f7} $(check_dock)
                                            ${f1}Browser:${f7} $(check_browser)           ${f1}Distro:${f7} $(check_distro)
                                            ${f1}WM:${f7} $(check_wm)                ${f1}Player:${f7} $(check_player)
EOF
