#!/usr/bin/env bash

asroot() { [[ $EUID -ne 0 ]] && err "Run this as root!"; }
checkdep() { which $1 > /dev/null 2>&1 || err "$1 is not installed. Please install it first!"; }
err() { echo "$(tput bold)$(tput setaf 1)==> Error:$(tput sgr0) $@" && exit 1; }
msg() { echo "$(tput bold)$(tput setaf 2)==> $@ $(tput sgr0)"; }

asroot

case $1 in
    --uninstall)
        [[ -f /usr/local/bin/archroot ]] && source /etc/archroot.conf && clear && \
        if mount | grep -E "$CHROOT/dev|$CHROOT/home|$CHROOT/usr/lib/modules|$CHROOT/proc|$CHROOT/run|$CHROOT/sys|$CHROOT/tmp|$CHROOT/var/lib/dbus" > /dev/null; then
            /usr/local/bin/archroot -s
            msg "Please unmount chroot API filesystems first to continue uninstalling!"
            err "Exiting... to anticipate damaged host system!"
        else
            [[ -f /usr/local/bin/archroot ]] && \
            clear
            /usr/local/bin/archroot -s
            while true; do
            msg "This will remove following"
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
        if [[ -f /usr/local/bin/archroot ]]; then
            while true; do
            msg "Archroot already installed"
            read -p $'\e[1;32m==> Are you sure you want to reinstall/upgrade? \e[1;33m(except archroot.conf) \e[1;35m(y/n)\e[0m ' yn
                case $yn in
                    [Yy]* ) clear
                            source /etc/archroot.conf
                            msg "Installing files..."
                            # DONT CHANGE THIS
                            install -v -D -m 755 ./archroot/archroot /usr/local/bin/archroot
                            install -v -D -m 755 ./archroot/copyresolv $INSTALL_PATH/copyresolv
                            install -v -D -m 755 ./archroot/command $INSTALL_PATH/command
                            install -v -D -m 755 ./archroot/archsetup $INSTALL_PATH/archsetup
                            msg "Installation was successful (upgraded)"
                            echo ""
                            /usr/local/bin/archroot
                            echo ""
                            break;;
                    [Nn]* ) exit;;
                    * ) err "Please answer yes or no!";;
                esac
            done
        else
            clear
            msg "The basic configuration is as follows"
            cat ./archroot/archroot.conf
            msg "First, specify the local username, etc."
            echo -n "Editor of your choice (e.g: nano): "
            read TEXT_EDITOR
            checkdep $TEXT_EDITOR
            cp ./archroot/archroot.conf ./archroot/archroot.conf_new
            $TEXT_EDITOR ./archroot/archroot.conf_new || exit 1
            source ./archroot/archroot.conf_new
            clear
            msg "Installing files..."
            # DONT CHANGE THIS
            mkdir -pv $INSTALL_PATH
            install -v -D -m 755 ./archroot/archroot /usr/local/bin/archroot
            install -v -D -m 755 ./archroot/archroot.conf_new /etc/archroot.conf
            install -v -D -m 755 ./archroot/copyresolv $INSTALL_PATH/copyresolv
            install -v -D -m 755 ./archroot/command $INSTALL_PATH/command
            install -v -D -m 755 ./archroot/archsetup $INSTALL_PATH/archsetup
            rm ./archroot/archroot.conf_new
            msg "Installation was successful"
            echo ""
            /usr/local/bin/archroot
            echo ""
        fi
    ;;
esac
