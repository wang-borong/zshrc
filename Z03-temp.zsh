CLASH_META_CONF=$(ps x | grep clash-meta | grep -v grep | awk -F "-f " '{print $2}')

if [[ -n $CLASH_META_CONF ]]; then
    CLASH_MIXED_PORT=$(cat $CLASH_META_CONF | grep mixed-port | awk -F ": " '{print $2}')
    export http_proxy=http://localhost:$CLASH_MIXED_PORT
    export https_proxy=$http_proxy \
        ftp_proxy=$http_proxy \
        rsync_proxy=$http_proxy
    unset CLASH_MIXED_PORT
else
    # If local clash is not running, then check router.
    # And we set 1081 as default proxy port.
    # netdev=$(ls /sys/class/net | grep -v lo)
    route_ip=$(ip route show scope global | awk -F "via " '{print $2}' | awk -F " dev" '{print $1}')
    nc -vz $route_ip 1081
    if [[ $? == 0 ]]; then
        export http_proxy=http://$route_ip:1081
        export https_proxy=$http_proxy \
            ftp_proxy=$http_proxy \
            rsync_proxy=$http_proxy
        unset route_ip
    else
        # or we check the work ip and port
        ping -W 0.5 -c 1 192.168.4.100 > /dev/null 2>&1
        if [[ $? == 0 ]]; then
            nc -vz 192.168.4.100 1081 > /dev/null 2>&1
            if [[ $? == 0 ]]; then
                export http_proxy=http://192.168.4.100:1081
                export https_proxy=$http_proxy \
                    ftp_proxy=$http_proxy \
                    rsync_proxy=$http_proxy
            fi
        fi
        # If the clash is not running in all env, then we don't set proxy.
    fi
fi
export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
unset CLASH_META_CONF
