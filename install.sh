#!/usr/bin/env bash

asroot() { [[ $EUID -ne 0 ]] && err "Run this as root!"; }
checkdep() { which $1 > /dev/null 2>&1 || err "$1 is not installed. Please install it first!"; }
err() { echo -e "\033[1;31m==> Error:\033[0m $@" && exit 1; }
msg() { echo -e "\033[1;32m==> $@ \033[0m"; }

asroot

case $1 in
    -u|--uninstall)
        [[ -f "$(which archroot 2> /dev/null)" ]] && source /etc/archroot.conf && clear && \
        if mount | grep -E "$CHROOT/dev|$CHROOT/home|$CHROOT/usr/lib/modules|$CHROOT/proc|$CHROOT/run|$CHROOT/sys|$CHROOT/tmp|$CHROOT/var/lib/dbus" > /dev/null; then
            $(which archroot) -s 2> /dev/null
            msg "Please unmount chroot API filesystems first to continue uninstalling!"
            err "Exiting... to anticipate damaged host system!"
        else
            [[ -f "$(which archroot 2> /dev/null)" ]] && clear && \
            $(which archroot) -s 2> /dev/null
            while true; do
            msg "This will remove following"
            echo "$(which archroot 2> /dev/null)"
            echo "$INSTALL_PATH/*"
            echo "/etc/archroot.conf"
            read -p $'\e[1;32m==> Are you sure you want to uninstall Archroot? \e[1;35m(y/n)\e[0m ' yn
                case $yn in
                    [Yy]* ) msg "Uninstalling Archroot..."
                            rm -v $(which archroot 2> /dev/null)
                            rm -rv $INSTALL_PATH
                            rm -v /etc/archroot.conf
                            break;;
                    [Nn]* ) exit;;
                    * ) err "Please answer yes or no!";;
                esac
            done
            msg "Archroot uninstalled successfully"
        fi
    ;;
    *)  if [[ -f "$(which archroot 2> /dev/null)" ]]; then
            while true; do
            msg "Archroot already installed"
            read -p $'\e[1;32m==> Are you sure you want to reinstall/upgrade? \e[1;33m(except archroot.conf) \e[1;35m(y/n)\e[0m ' yn
                case $yn in
                    [Yy]* ) clear
                            source /etc/archroot.conf
                            msg "Installing files..."
                            # DONT CHANGE THIS
                            install -v -D -m 755 ./archroot/archroot $(which archroot 2> /dev/null)
                            install -v -D -m 755 ./archroot/copyresolv $INSTALL_PATH/copyresolv
                            install -v -D -m 755 ./archroot/command $INSTALL_PATH/command
                            install -v -D -m 755 ./archroot/archsetup $INSTALL_PATH/archsetup
                            msg "Installation was successful (upgraded)"
                            echo ""
                            $(which archroot) 2> /dev/null
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
            cp ./archroot/archroot.conf ./archroot/archroot.conf_new &> /dev/null
            $TEXT_EDITOR ./archroot/archroot.conf_new || exit 1
            source ./archroot/archroot.conf_new && clear
            msg "Installing files..."
            # DONT CHANGE THIS
            mkdir -p $INSTALL_PATH &> /dev/null
            install -v -D -m 755 ./archroot/archroot /usr/local/bin/archroot
            install -v -D -m 755 ./archroot/archroot.conf_new /etc/archroot.conf
            install -v -D -m 755 ./archroot/copyresolv $INSTALL_PATH/copyresolv
            install -v -D -m 755 ./archroot/command $INSTALL_PATH/command
            install -v -D -m 755 ./archroot/archsetup $INSTALL_PATH/archsetup
            rm ./archroot/archroot.conf_new &> /dev/null
            msg "Installation was successful"
            echo ""
            $(which archroot) 2> /dev/null
            echo ""
        fi
    ;;
esac

rm -f /tmp/archroot* &> /dev/null
