# ============================================================
# CachyOS-style Fish config
# NixOS / Niri / Noctalia
# ============================================================


# ------------------------------------------------------------
# Welcome message
# ------------------------------------------------------------

function fish_greeting
    if command -q fastfetch
        fastfetch
    end
end


# ------------------------------------------------------------
# Man pages
# ------------------------------------------------------------

set -gx MANROFFOPT "-c"

if command -q bat
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
end


# ------------------------------------------------------------
# fish history
# ------------------------------------------------------------

# CachyOS displays timestamps when using `history`.
# Pass arguments through so native commands like:
#   history search
#   history delete
#   history clear
# continue to work.

function history
    builtin history --show-time='%F %T ' $argv
end


# ------------------------------------------------------------
# done
# ------------------------------------------------------------

if set -q __done_min_cmd_duration
    set -U __done_min_cmd_duration 10000
else
    set -U __done_min_cmd_duration 10000
end

set -U __done_notification_urgency_level low


# ------------------------------------------------------------
# Environment
# ------------------------------------------------------------

# Optional ~/.fish_profile
if test -f ~/.fish_profile
    source ~/.fish_profile
end


# ------------------------------------------------------------
# PATH
# ------------------------------------------------------------

fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/Applications


# ------------------------------------------------------------
# CachyOS-style !! and !$
# ------------------------------------------------------------

function __history_previous_command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint

        case "*"
            commandline -i !
    end
end


function __history_previous_command_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward

        case "*"
            commandline -i '$'
    end
end


if test "$fish_key_bindings" = fish_vi_key_bindings
    bind -Minsert ! __history_previous_command
    bind -Minsert '$' __history_previous_command_arguments
else
    bind ! __history_previous_command
    bind '$' __history_previous_command_arguments
end


# ------------------------------------------------------------
# Functions
# ------------------------------------------------------------

function backup --argument filename
    cp $filename $filename.bak
end


function copy
    if test (count $argv) -eq 2; and test -d "$argv[1]"
        set from (string replace -r '/$' '' -- "$argv[1]")
        set to "$argv[2]"

        command cp -r "$from" "$to"
    else
        command cp $argv
    end
end


# ------------------------------------------------------------
# eza
# ------------------------------------------------------------

if command -q eza

    # preferred listing
    alias ls='eza -al --color=always --group-directories-first --icons=always'

    # all files
    alias la='eza -a --color=always --group-directories-first --icons=always'

    # long format
    alias ll='eza -l --color=always --group-directories-first --icons=always'

    # tree
    alias lt='eza -aT --color=always --group-directories-first --icons=always'

    # dotfiles only
    alias l.='eza -a | grep -e "^\."'

end


# ------------------------------------------------------------
# Common aliases
# ------------------------------------------------------------

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'


# tar
alias tarnow='tar -acf'
alias untar='tar -zxvf'


# wget
alias wget='wget -c'


# grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'


# directory listings
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'


# memory usage
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'


# journal
alias jctl='journalctl -p 3 -xb'


# termbin
if command -q nc
    alias tb='nc termbin.com 9999'
end


# ------------------------------------------------------------
# NixOS replacements for CachyOS commands
# ------------------------------------------------------------

# CachyOS:
# alias update="sudo cachyos-rate-mirrors && sudo pacman -Syu"
#
# NixOS equivalent:
alias update='sudo nixos-rebuild switch --flake /etc/nixos'


# Search Nix packages
if command -q nh
    alias nix-search='nh search'
end


# Garbage collection
alias nix-clean='sudo nix-collect-garbage -d'


# Rebuild NixOS
alias rebuild='sudo nixos-rebuild switch --flake /etc/nixos'


# ------------------------------------------------------------
# Git shortcuts
# ------------------------------------------------------------

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --decorate --graph'


# ------------------------------------------------------------
# Useful commands
# ------------------------------------------------------------

# Open current directory in file manager
if command -q thunar
    alias fm='thunar .'
end


# Clear terminal
alias c='clear'


# Exit
alias q='exit'
