[[ -d ~/.fonts ]] && _zsource ~/.fonts/*.sh || true

if [[ -z "$LC_ALL" ]]; then
    export LC_ALL="en_US.UTF-8"
fi

# map nocaps key to ctrl
setxkbmap -option 'ctrl:nocaps'

# Fix garbled zsh prompt problem in emacs
[[ $TERM == "dumb"  ]] && unsetopt zle && PS1='$ '
case "$TERM" in
	"dump")
		PS1="> "
		;;
	xterm*|rxvt*|eterm*|screen*)
		PS1="$PS1"
		;;
	*)
		PS1="> "
		;;
esac

if [[ -n ${TMUX} && -n ${commands[tmux]} ]]; then
    case $(tmux showenv TERM 2>/dev/null) in
        *256color) ;&
        TERM=fbterm)
            TERM=screen-256color ;;
        *)
            TERM=screen
    esac
fi

# Don't need input password when use `sudo -A'
export SUDO_ASKPASS=~/.cache/show_passwd

# Add ripgrep config path
export RIPGREP_CONFIG_PATH=~/.rgrc

export GOROOT="/usr/lib/go"
export GOPATH="$HOME/.go"

# go proxy
export GO111MODULE=on
export GOPROXY=https://goproxy.cn

_append_to_path $HOME/.cargo/bin
_append_to_path ~/.bin
_append_to_path ~/Workspace/tools/bin

for p in \
    $(find $HOME/.opt -maxdepth 4 -type d -name "bin*" 2>/dev/null | sort -r) \
    $(find $HOME/.opt -maxdepth 4 -type f -executable 2>/dev/null | sort -r) \
    $(find $HOME/.workopt -maxdepth 4 -type d -name "bin*" 2>/dev/null | sort -r) \
    ;
do
    # get rid of hidden directories
    if [[ -d $p && $(basename $p | cut -c1)  == "." ]]; then
        continue
    elif [[ -f $p && $(dirname $p | cut -c1) == "." ]]; then
        continue
    fi

    if [[ -d $p ]]; then
        if [[ -n "$(echo $p | grep '/front/')" ]]; then
            _prepend_to_path $p
        else
            _append_to_path $p
        fi
    fi

    if [[ -f $(echo $p | grep -E -v \
        '/bin[[:digit:]]*/|/lib[[:digit:]]*/|/misc\w*/|/src\w*/|/share\w*/') ]]; then
        if [[ -n "$(echo $p | grep '/front/')" ]]; then
            _prepend_to_path $(dirname $p)
        else
            _append_to_path $(dirname $p)
        fi
    fi
done
unset p

alias top='htop'
#alias gcc='gcc -W -Wall -O2'
#alias clang='clang -W -Wall -O2'
# remote login windows desktop
#alias rlwd="rdesktop -u Wangborong -p wbr19920116 -g 1920x1052 192.168.24.11 >/dev/null 2>&1 &"
#alias kitty="kitty --session ~/.config/kitty/kitty.session >/dev/null 2>&1 &"
#alias build_oldsdk="python3 $WORKSPACE/tools/run_sdk.py $WORKSPACE/board/allwinner"
#alias build_newsdk="python3 $WORKSPACE/tools/run_sdk.py $WORKSPACE/board/newboard-h3"
#alias read_h3_ports="less ~/Documents/H3_multiplex_io"
#alias auto_c="bash $WORKSPACE/tools/create_autotools_project.sh"
alias sc='svn commit'
alias sco='svn checkout'
alias sm='svn merge --reintegrate https://10.10.1.12/svn/'
alias slg='svn log | bat'
alias slgq='svn log --quiet | bat'
alias sup='svn up'
alias st='svn st'
alias sad='svn add'
alias sinfo='svn info'
# Update all python outdated packages (make sure the dependencies)
alias upypkg='pip list --user --outdated --format=freeze | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 pip install -U; pip list --outdated --format=freeze | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 sudo pip install -U'

alias lkmg='python ~/Workspace/tools/linux_moudle_gen.py'


function gi { curl -L -s https://www.gitignore.io/api/$@ ; }

# Use it carefully
function clnsys {
    dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge
    sudo apt autoremove
    sudo apt autoclean
    sudo apt clean
}

function clnc
{
    rm -f *.o > /dev/null 2>&1
    rm -f a.out > /dev/null 2>&1
    rm -f $@ > /dev/null 2>&1
}

function rectmp { rsync -a ~/.sync/tmp/ ~/tmp/ }

function mb
{
    for i in $@; do
        mv $i $i.bak
    done
}

# Show all vim map keys
function vimap
{
    rg -N "map" ~/.vim | grep -v \" | grep -v "FileType" | grep -v "exists" |
        awk -F "vim:" '{print $2}' | rg -N "map" --trim
}

function working {
    if [[ $# == 0 ]]; then
        builtin cd $WORKSPACE/working
    elif [[ $# == 1 ]]; then
        if [[ -d $WORKSPACE/working/$1 ]]; then
            builtin cd $WORKSPACE/working/$1
        else
            print "no such project $1"
            return 1
        fi
    elif [[ $# > 1 && $1 == '-a' ]]; then
        shift
        ln -s $1 $WORKSPACE/working/
    else
        print "keep working"
    fi
}

# Cross compile openwrt rootfs applications
function owrtgcc()
{
    _SYSROOT=/opt/cross_compilers/arm_cortex-a8+vfpv3_gcc-5.4.0_musl-1.1.16_eabi/arm-openwrt-linux
    CC=arm-openwrt-linux-gcc
    PKG_CONFIG_LIBDIR=${_SYSROOT}/usr/lib/pkgconfig
    _CFLAGS=-I${_SYSROOT}/usr/include
    _LDFLAGS=-L${_SYSROOT}/usr/lib
    _CROSS_COMPILE=arm-openwrt-linux-

    if [[ -f configure.ac && -f Makefile.am ]]; then
        # autotool project
        aclocal && autoheader && autoconf && automake --add-missing
        export PKG_CONFIG_LIBDIR
        CC=arm-openwrt-linux-gcc ./configure --host=arm-openwrt-linux CFLAGS=${_CFLAGS} LDFLAGS=${_LDFLAGS} $@
        make -j 4
        return
    fi

    if [[ ! -f Makefile.am && -f Makefile ]]; then
        make CROSS_COMPILE=${_CROSS_COMPILE} all
        return
    fi

    if [[ -n $1 ]]; then
        $CC ${_CFLAGS} ${_LDFLAGS} $@
        return
    fi
}

# svn for working
function sd() { svn diff $@ | bat }

function sdr() { svn diff -r $@ | bat }

function scopy() {
    if [[ $# < 2 ]]; then
        print "usage: scopy <remote addr1> <remote addr2> [options]"
        print "  scopy dash16/trunk dash16/branches/integration"
        return 1
    fi
    p1=$1; shift
    p2=$1; shift
    svn copy $WORK_SVN/$p1 $WORK_SVN/$p2 $@
}

function sdel() {
    if [[ $# < 1 ]]; then
        print "usage: sdel <remote addr1> <remote addr2> [options]"
        print "  scopy dash16/trunk dash16/branches/integration"
        return 1
    fi
    p=$1; shift
    svn delete $WORK_SVN/$p $@
}

function smg() {
    if [[ $# < 2 ]]; then 
        print "uasage: smg <remote project> <local project> [options]"
        print "  smg dash16/trunk $WORKSPACE/working/dash16/branches/integration"
        return 1
    fi
    rp=$1; shift
    lp=$2; shift
    svn merge $@ "https://$SVN_IP/svn/$rp" "$lp"
}

# Select python env to switch
function swpython() {
    env_home="$WORKSPACE/pythonenv/"
    if [[ ! -d $env_home ]]; then
        print "No such python env path: $env_home"
        return 1
    fi
    envs=($WORKSPACE/pythonenv/*)
    pythons=$(echo $envs | sed -e "s|$env_home||g" -e 's/ /\n/g')
    sel=$(print $pythons | fzf)
    [[ $sel != "" ]] && source "$env_home/$sel/bin/activate" &&
        print "Switched to $sel"
}

function changelog() {
    echo "$(date +%F) $@" >> CHANGELOG
}

if ! _has cht.sh; then
    function cht.sh() {
        curl "cht.sh/$@"
    }
fi

function tn() {
    tmux splitw -h && tmux pipep -I -t 2 "echo cd $PWD" \
    && tmux pipep -I -t 2 "echo clear"
}

function git_archive() {
    # If we sepecify $2 which is the path of a related svn source path, this function
    # will patch the archived sources to the svn sources.
    if [[ $1 == "" ]]; then
        print "$0 <git commit> [svn source path]"
        return 1
    fi
    git archive --format=tar --prefix="$1/" "$1" | (builtin cd /tmp && tar xf -)
    # We can use archived git source to patch a related svn repository because the archived
    # git source has no ignored files that we don't want to update to svn repository.
    if [[ -d $2 ]]; then
        (cp -a /tmp/$1/* $2)
        builtin cd $2 # enter the svn source path
    else
        builtin cd /tmp/$1 # enter the archived git source path
    fi
}

function turn_proxy ()
{
    if [[ -z $1 ]]; then
        export http_proxy="socks5://$PROXY_IP:1081" \
            http_proxy="http://$PROXY_IP:1081" \
            https_proxy="http://$PROXY_IP:1081"
    else
        export http_proxy="" \
            https_proxy=""
    fi
}

alias bsu="PATH=~/Workspace/wprojs/sparc/buildroot/output/host/usr/bin:$PATH make ARCH=sparc CROSS_COMPILE=sparc-linux- uImage"
