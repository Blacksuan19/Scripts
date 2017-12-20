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
check_kwin() {
    if exists kwin_x11 || kwin_wayland; then
        memed
    else
        not_memed
    fi
}

# look for kde plasma
check_plasma() {
   if exists plasmashell; then
           memed

   else
       not_memed
   fi
}

# look for spotify
check_spotify() {
    if exists spotify; then
        memed
    else
        not_memed
    fi
}

# look for neofetch
check_fetch() {
   if exists neofetch; then
       memed
   else
       not_memed
   fi
}

# look for urxt and termite
check_term() {
    if exists urxvt || exists termite; then
        memed
    else
        not_memed
    fi
}

# look for plank
check_dock() {
    if exists plank; then
        memed
    else
        not_memed
    fi
}

# look for vivaldi or vivaldi-snapshot
check_vivaldi() {
    if exists vivaldi-snapshot || exists vivaldi; then
        memed
    else
        not_memed
    fi
}
# look for sublime
check_editor() {
    if exists vim || exists /opt/sublime_text_3; then
        not_memed
    else
        memed
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

# look for prezto
check_shell() {
    if [[ -d ${HOME}/.zprezto ]]; then
        memed
    else
        not_memed
    fi
}

# OUTPUT

cat << EOF

             me                         
         mememememe                     
       memememememem                    
      emememememememe                   ${f1}fetch:${f7} $(check_fetch)
     mememememememememememem            ${f1}editor:${f7} $(check_editor)
    emememememememememe  memem          ${f1}de:${f7} $(check_plasma)
   ememememememememememe   mememe       ${f1}term:${f7} $(check_term)
  mememememe     mememem     ememe      ${f1}shell:${f7} $(check_shell)
  memememe         mememe   mememe      ${f1}dock:${f7} $(check_dock)
 emememe            mememememememe      ${f1}browser:${f7} $(check_vivaldi)
 emememe           mememememememe       ${f1}distro:${f7} $(check_distro)
mememem       ememememememememe         ${f1}wm:${f7} $(check_kwin)
mememe    memememememememem             ${f1}spotify:${f7} $(check_spotify)
emem ememememememem    emem
memem                    em
 eme                     me

EOF
