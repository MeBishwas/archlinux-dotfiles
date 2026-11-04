#
# ~/.bashrc
#

export TERM=xterm-kitty
export EDITOR=vim
export VISUAL=vim

##loading my png images into fastfetch
if [[ $- == *i* && "$TERM" == "xterm-kitty" ]]; then
    fastfetch --logo "$HOME/Pictures/biswas.png" \
        --logo-type kitty-icat \
        --logo-width 40 \
        --logo-height 60
fi









# Bash completion
if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
fi

# Better history
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
shopt -s checkwinsize

# Case-insensitive Tab completion
bind 'set completion-ignore-case on'

#Interactive vim like command editing
#set -o vimi

# Show matching completions immediately
bind 'set show-all-if-ambiguous on'
bind 'set completion-display-width -1'

source /usr/share/blesh/ble.sh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
