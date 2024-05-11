# Description:
#   * A local configuration example
#
# Author:
#   @ Jason Wang

export WORKSPACE="$HOME/Workspace"

_append_paths_if_nonexist ~/.bin
_append_paths_if_nonexist ~/.go/bin

# for rustup
#export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup

# -- Aliases for local
alias vim='nvim'
alias vi='nvim'
# Modify ~/.zshrc.local
alias ezl='vim ~/.zshrc.local'
# Only resource ~/.zshrc.local
alias szl='_zsource ~/.zshrc.local'

alias rcd_d='script -t 2> record.time -a record'
alias rcd_p='scriptreplay record.time record'

# For git
alias gt='git tag'
alias glgs="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gla='git log --oneline --all'
# Create a merge commit even when the merge resolves as a fast-forward.
alias gmn='git merge --no-ff'
# list tags
alias gtl='git tag --list'
alias git_recovery_all='git ls-files -d | xargs -i git checkout {}'

# commands written by scripts
# the trash command is more safer than rm.
#alias trd='trash -d'
#alias trr='trash -r'
#alias trc='trash -c'
#alias trl='trash -l'
# dangerous! this command will empty trash
#alias tra='trash -a'
# Backup files contained in .backup.conf
#alias bak='backup'

# for chinese man
#[[ -d /opt/share/zhman/share/man/zh_CN ]] && alias cman='man -M /opt/share/zhman/share/man/zh_CN'

# use mount with administrator
alias mount='sudo mount'
alias umount='sudo umount'
# a translator written by python3
# translate to Chinese
alias trz='trans :zh'
alias trzd='trans -v -d :zh'
# translate to English
alias tre='trans :en'

# alias dl to aria2c
# -d, --dir=DIR    The dir to store the downloaded file
# -i, --input-file=<FILE>    Downloads the URIs listed in FILE.
# -j, --max-concurrent-downloads=<N>    Set  the  maximum number of parallel downloads for every queue item.
#

# The configure file is ~/.config/aria2/aria2.conf
    #continue
    #dir=${HOME}/Downloads
    #file-allocation=none
    ##input-file=${HOME}/.aria2/input.conf
    #log-level=warn
    #max-connection-per-server=4
    #min-split-size=5M
##on-download-complete=exit
alias dl='aria2c'

alias cat='bat'

alias dfg="git --git-dir=$HOME/.dotfiles --work-tree=/ "
alias dfgi="git init --bare $HOME/.dotfiles && dfg config --local status.showUntrackedFiles no"
alias dfga="dfg add "
alias dfgc="dfg commit "
alias dfgs="dfg status "
alias dfgd="dfg diff "

if [[ $TERM == "xterm-kitty" ]]; then
    alias kkd="kitty +kitten diff"
    alias kkc="kitty +kitten clipboard"
fi

export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
# Convenient paths.
# Note:
#   * Never add a non-existing path

# Others
#_zsource $WBR_ZSH/zsh-func/_tmuxinator

#_zsource ~/.local/etc/git-extras-completion.zsh


################## FUNCTIONs #################

function cd() { builtin cd $@ && ls }

#function emacs() {
#    # fix the bug that emacs can not switch chinese input method
#    # in english system.
#    command env LC_CTYPE=zh_CN.UTF-8 emacs $@ >/dev/null 2>&1 &
#}

function mntmp() {
    if [[ -d /mnt/tmp ]]; then
        tmpoint=/mnt/tmp
    elif [[ -d ~/tmp ]]; then
        tmpoint=~/tmp
    else
        tmpoint=/mnt
    fi

    mount tmpfs $tmpoint -t tmpfs -o nosuid,remount,uid=$UID,gid=$GID,size=${1}M
    cd $tmpoint
    unset tmpoint
}

function dotfile() {
    if [[ "$#" -eq 0 ]]; then
        (cd /
        for i in $(dfg ls-files); do
            echo -n "$(dfg -c color.status=always status $i -s | sed "s#$i##")"
            echo -e "¬/$i¬\e[0;33m$(dfg -c color.ui=always log -1 --format="%s" -- $i)\e[0m"
        done
        ) | column -t --separator=¬ -T2
    else
        dfg $*
    fi
}
