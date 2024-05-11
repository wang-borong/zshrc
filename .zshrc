### Functions for zshrc
# Returns whether the given command is executable or aliased.
_has() { return $( whence $1 >/dev/null ) }

# Functions which modify the path given a directory, but only if the directory
# exists and is not already in the path.
_prepend_to_path() { [ -d $1 -a -z ${path[(r)$1]} ] && path=($1 $path) }

_append_to_path() { [ -d $1 -a -z ${path[(r)$1]} ] && path=($path $1) }

_force_prepend_to_path() { path=($1 ${(@)path:#$1}) }

_append_paths_if_nonexist() {
    for p in $@; do
        [[ ! -L $p ]] && _prepend_to_path $p
    done
    unset p
}

_zsource() {
    if [[ -r $1 ]]; then
        source $1
    fi
}

### End of functions


### Added by Zi's installer
if [[ ! -f $HOME/.zi/bin/zi.zsh ]]; then
    source <(curl -sL init.zshell.dev); zzinit
fi

source "$HOME/.zi/bin/zi.zsh"
autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi

PS1="READY > "

# Keep environment variables unique
typeset -U path PATH cdpath CDPATH fpath FPATH manpath MANPATH PYTHONPATH
# Initial aliases
unalias -a

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zi light-mode for \
    z-shell/z-a-rust \
    z-shell/z-a-patch-dl \
    z-shell/z-a-bin-gem-node

#zi ice from"gh-r" as"program"
#zi load junegunn/fzf-bin
zi ice from"gh-r" as"program"
zi light starship/starship
zi ice from"gh-r" as"command" mv"zoxide* -> zoxide" pick"zoxide/zoxide"
zi light ajeetdsouza/zoxide

zi from"gh-r" as"program" mv"direnv* -> direnv" \
    atclone'./direnv hook zsh > zhook.zsh' atpull'%atclone' \
    pick"direnv" src="zhook.zsh" for \
        direnv/direnv

# For GNU ls (the binaries can be gls, gdircolors, e.g. on OS X when installing the
# coreutils package from Homebrew; you can also use https://github.com/ogham/exa)
zi ice atclone"dircolors -b LS_COLORS > clrs.zsh" \
    atpull'%atclone' pick"clrs.zsh" nocompile'!' \
    atload'zstyle ":completion:*" list-colors “${(s.:.)LS_COLORS}”'
zi light trapd00r/LS_COLORS

zi wait lucid for \
    atinit"zicompinit; zicdreplay"   \
    z-shell/fast-syntax-highlighting #\
    #OMZP::colored-man-pages

## snippet files
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/lib/alias.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/lib/autocorrect.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/lib/completion.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/lib/correction.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/lib/directories.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/lib/function.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/lib/git.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/lib/help.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/lib/history.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/lib/key-bindings.zsh"
# ---
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/plugins/archlinux.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/plugins/fzf.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/plugins/git-extras.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/plugins/git-flow.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/plugins/git.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/plugins/github.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/plugins/man.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/plugins/pip.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/plugins/python.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/plugins/rsync.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/plugins/sbt.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/plugins/sudo.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/plugins/systemd.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/plugins/ubuntu.zsh"
# ---
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/custom/fzf_options.zsh"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/custom/key-bindings.zsh"

#zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/themes/soimort/soimort.zsh"

## snippet directory
zi ice svn
zi snippet "https://github.com/wang-borong/dot-zsh/trunk/plugins/tmux"
#zi ice svn
#zi snippet "https://github.com/wang-borong/dot-zsh/trunk/custom/smartcd"

## completions
zi ice as"completion"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/functions/_cargo"
zi ice as"completion"
zi snippet "https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker"
zi ice as"completion"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/functions/_cht"
zi ice as"completion"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/functions/_fd"
zi ice as"completion"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/functions/_git"
zi ice as"completion"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/functions/_pip"
zi ice as"completion"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/functions/_rg"
zi ice as"completion"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/functions/_rust"
zi ice as"completion"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/functions/_rustup"
zi ice as"completion"
zi snippet "https://github.com/wang-borong/dot-zsh/blob/main/functions/_shutdown"
zi ice as"completion"
zi snippet "https://github.com/ajeetdsouza/zoxide/blob/main/contrib/completions/_zoxide"

zi ice blockf
zi light zsh-users/zsh-completions
#zi light marlonrichert/zsh-autocomplete

### End of Zi's installer chunk


### User's configuration
setopt interactivecomments

eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd j)"

[[ ! -d $HOME/.fzf ]] && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --bin
[[ ! -L $ZPFX/bin/fzf ]] && ln -sf $HOME/.fzf/bin/{fzf,fzf-tmux} $ZPFX/bin
export FZF_BASE=$HOME/.fzf

# Initial PATH
_append_paths_if_nonexist /bin /sbin /usr/bin /usr/sbin \
    /usr/local/bin /usr/local/sbin ~/.local/bin ~/.bin

# Make LC_ALL correspond to UTF-8
[[ -z $LC_ALL || $LC_ALL = "C" ]] && export LC_ALL=en_US.UTF-8

if [[ -d ~/.zshrc.d ]]; then
    for rc in ~/.zshrc.d/*; do
        _zsource $rc
    done
fi
unset rc

if _has nvim; then
    export EDITOR=nvim VISUAL=nvim
elif _has vim; then
    export EDITOR=vim VISUAL=vim
else 
    export EDITOR=vi VISUAL=vi
fi

unset -f _has _prepend_to_path _append_to_path \
    _force_prepend_to_path _append_paths_if_nonexist \
    _zsource
### End of user's configuration
