#!/usr/bin/env bash

R="\e[1;31m"; G="\e[1;32m"; M="\e[1;35m"; W="\e[1;37m"; NC="\e[0m"

asroot() { [[ $EUID -ne 0 ]] && err "Run this as root!"; }
checkdep() { command -v "$1" > /dev/null 2>&1 || err "${M}$1${W} is not installed. Please install it first!${NC}"; }
err() { echo -e "${R}==> Error:${W} $@${NC}"; exit 1; }
msg() { echo -e "${G}==>${W} $@${NC}"; }
yesno() { echo -n -e "${M}(${NC}y${M}/${NC}n${M})${NC} "; }

asroot

case $1 in
    -u|--uninstall)
        if [[ "$(command -v "archroot" 2> /dev/null)" ]]; then
            source /etc/archroot.conf && printf "\ec"
            if mount | grep -E "$CHROOT/dev|$CHROOT/home|$CHROOT/usr/lib/modules|$CHROOT/proc|$CHROOT/run|$CHROOT/sys|$CHROOT/tmp|$CHROOT/var/lib/dbus" > /dev/null; then
                archroot -s 2> /dev/null
                msg "Please unmount chroot API filesystems first to continue uninstalling!"
                err "Exiting... to anticipate damaged host system!"
            else
                [[ "$(command -v "archroot" 2> /dev/null)" ]] && printf "\ec" && \
                archroot -s 2> /dev/null
                while true; do
                msg "This will remove following"
                echo -e "${G}:${NC} $(command -v "archroot" 2> /dev/null)"
                echo -e "${G}:${NC} $INSTALL_PATH/*"
                echo -e "${G}:${NC} /etc/archroot.conf"
                msg "Are you sure you want to uninstall Archroot?"; yesno
                read yn
                    case $yn in
                        [Yy]* ) msg "Uninstalling Archroot..."
                                rm -v $(command -v "archroot" 2> /dev/null)
                                rm -rv $INSTALL_PATH
                                rm -v /etc/archroot.conf
                                break;;
                        [Nn]* ) exit;;
                        * ) err "Please answer yes or no!";;
                    esac
                done
                msg "Archroot uninstalled successfully"
            fi
        else
            err "Archroot not installed!"
        fi
    ;;
    -*) err "Unknown option $1"
    ;;
    *)  if [[ -f "$(command -v "archroot" 2> /dev/null)" ]]; then
            while true; do
            msg "Archroot already installed"
            msg "Are you sure you want to reinstall/upgrade? Except archroot.conf"; yesno
            read yn
                case $yn in
                    [Yy]* ) printf "\ec"
                            source /etc/archroot.conf
                            msg "Installing files..."
                            # DONT CHANGE THIS
                            install -v -D -m 755 ./archroot/archroot $(command -v "archroot" 2> /dev/null)
                            install -v -D -m 755 ./archroot/copyresolv $INSTALL_PATH/copyresolv
                            install -v -D -m 755 ./archroot/command $INSTALL_PATH/command
                            install -v -D -m 755 ./archroot/archsetup $INSTALL_PATH/archsetup
                            msg "Installation was successful ${M}[${W}upgraded${M}]${NC}\n"; break;;
                    [Nn]* ) exit;;
                    * ) err "Please answer yes or no!";;
                esac
            done
        else
            printf "\ec"
            msg "The basic configuration is as follows"
            cat ./archroot/archroot.conf
            msg "First, specify the local username, etc."
            echo -n "Editor of your choice (e.g: nano): "
            read "TEXT_EDITOR"
            checkdep "$TEXT_EDITOR"
            cp ./archroot/archroot.conf ./archroot/archroot.conf_new &> /dev/null
            $TEXT_EDITOR ./archroot/archroot.conf_new || exit 1
            source ./archroot/archroot.conf_new && printf "\ec"
            msg "Installing files..."
            # DONT CHANGE THIS
            mkdir -p "$INSTALL_PATH" &> /dev/null
            install -v -D -m 755 ./archroot/archroot /usr/local/bin/archroot
            install -v -D -m 755 ./archroot/archroot.conf_new /etc/archroot.conf
            install -v -D -m 755 ./archroot/copyresolv $INSTALL_PATH/copyresolv
            install -v -D -m 755 ./archroot/command $INSTALL_PATH/command
            install -v -D -m 755 ./archroot/archsetup $INSTALL_PATH/archsetup
            rm -f ./archroot/archroot.conf_new &> /dev/null
            msg "Installation was successful\n"
        fi
        archroot 2> /dev/null
        echo ""
    ;;
esac

rm -f /tmp/archroot* &> /dev/null
