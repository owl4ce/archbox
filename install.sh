#!/usr/bin/env bash

asroot(){
    [[ $EUID -ne 0 ]] && err "Run this as root!"
}

checkdep(){
    which $1 >/dev/null 2>&1 || err "$1 is not installed. Please install it first!"
}

err(){
    echo "$(tput bold)$(tput setaf 1)==> $@ $(tput sgr0)"
    exit 1
}

msg(){
    echo "$(tput bold)$(tput setaf 2)==> $@ $(tput sgr0)"
}

asroot
case $1 in
    --uninstall)
    [[ -f /usr/local/bin/archroot ]] && source /etc/archroot.conf && clear && \
    if mount | grep -E "$CHROOT/dev|$CHROOT/home|$CHROOT/usr/lib/modules|$CHROOT/proc|$CHROOT/run|$CHROOT/sys|$CHROOT/tmp|$CHROOT/var/lib/dbus" > /dev/null; then
        msg "Please unmount chroot directory first to continue uninstalling"
        if mount | grep "$CHROOT/dev" > /dev/null; then
            echo "Mounted: $CHROOT/dev"
        else
            echo "Not mounted: $CHROOT/dev"
        fi
        if mount | grep "$CHROOT/home" > /dev/null; then
            echo "Mounted: $CHROOT/home"
        else
            echo "Not mounted: $CHROOT/home"
        fi
        if mount | grep "$CHROOT/usr/lib/modules" > /dev/null; then
            echo "Mounted: $CHROOT/lib/modules"
        else
            echo "Not mounted: $CHROOT/lib/modules"
        fi
        if mount | grep "$CHROOT/proc" > /dev/null; then
            echo "Mounted: $CHROOT/proc"
        else
            echo "Not mounted: $CHROOT/proc"
        fi
        if mount | grep "$CHROOT/run" > /dev/null; then
            echo "Mounted: $CHROOT/run"
        else
            echo "Not mounted: $CHROOT/run"
        fi
        if mount | grep "$CHROOT/sys" > /dev/null; then
            echo "Mounted: $CHROOT/sys"
        else
            echo "Not mounted: $CHROOT/sys"
        fi
        if mount | grep "$CHROOT/tmp" > /dev/null; then
            echo "Mounted: $CHROOT/tmp"
        else
            echo "Not mounted: $CHROOT/tmp"
        fi
        if mount | grep "$CHROOT/var/lib/dbus" > /dev/null; then
            echo "Mounted: $CHROOT/var/lib/dbus"
        else
            echo "Not mounted: $CHROOT/var/lib/dbus"
        fi
        err "Exiting... to anticipate damaged host system"
    else
        [[ -f /usr/local/bin/archroot ]] && \
        clear
        while true; do
        msg "This will remove the following:"
        echo "/usr/local/bin/archroot"
        echo "$INSTALL_PATH/*"
        echo "/etc/archroot.conf"
        read -p $'\e[1;32m==> Are you sure you want to uninstall Archroot? \e[1;35m(y/n)\e[0m ' yn
            case $yn in
                [Yy]* ) msg "Uninstalling Archroot..."
                        rm -v /usr/local/bin/archroot
                        rm -rv $INSTALL_PATH
                        rm -v /etc/archroot.conf
                        break;;
                [Nn]* ) exit;;
                * ) err "Please answer yes or no!";;
            esac
        done
    fi
    ;;
    *)
    [[ -f /usr/local/bin/archroot ]] && err "Archroot already installed. Exiting..."
    clear
    msg "The basic configuration is as follows:"
    cat ./archroot/archroot.conf
    msg "First, specify the local username, etc."
    echo -n "Editor of your choice (e.g: nano): "
	read TEXT_EDITOR
    checkdep $TEXT_EDITOR
    cp ./archroot/archroot.conf ./archroot/archroot.conf_new
    $TEXT_EDITOR ./archroot/archroot.conf_new || exit 1
    source ./archroot/archroot.conf
    clear
    msg "Installing files..."
    # DONT CHANGE THIS
    mkdir -pv $INSTALL_PATH
    install -v -D -m 755 ./archroot/archroot /usr/local/bin/archroot
    install -v -D -m 755 ./archroot/archroot.conf_new /etc/archroot.conf
    install -v -D -m 755 ./archroot/copyresolv $INSTALL_PATH/copyresolv
    install -v -D -m 755 ./archroot/command $INSTALL_PATH/command
    install -v -D -m 755 ./archroot/archsetup $INSTALL_PATH/archsetup
    install -v -D -m 755 ./archroot/installyay $INSTALL_PATH/installyay
    rm ./archroot/archroot.conf_new
    echo ""
    msg "Installation was successful"
    archroot
    ;;
esac
