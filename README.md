<p align="center"><a name="top" href="#octocat-why-chroot-"><img width="60%" src="https://i.ibb.co/DgDn47J/archroot.png"></a></p>
<p align="center">Install Arch Linux inside chroot environment using same user environment</p>
<p align="center">Systemctl isn't working inside chroot environment, so it will use <a href="https://github.com/lemniskett/servicectl">this</a> instead</p>
<p align="center">Pulseaudio, d-bus, and service work like a charm</p>
<p align="center"><b>EXPERIMENTAL</b></p>

##  

### :octocat: Why chroot? <img alt="Visits" align="right" src="https://badges.pufler.dev/visits/owl4ce/archroot?style=flat-square&label=&color=success&logo=GitHub&logoColor=white&labelColor=373e4d"/>

<img src="https://i.ibb.co/s59mrC4/preview.png" alt="preview" align="right" width="400px">

Ever since I'm running some niche distros like Void, Solus, I had a problem finding softwares I need in their not-so-large repositories, also I don't like how flatpak and snap works. so i decided to create an Arch Linux chroot environment everytime I distrohop. Why Arch Linux? They have a really, really good repositories, oh and don't mention how big AUR is. [@lemniskett](https://github.com/lemniskett)

Since I'm using a complex Linux distribution like Gentoo, there are several reasons why I should also use Arch Linux in a chrooted environment. First, I had a hard time (oh actually not being comfortable) with installing wine on Gentoo, and using wine in Archroot instead. The second reason is of course Gentoo's repositories are lacking even though has overlay and I miss AUR. [@owl4ce](https://github.com/owl4ce)

> **Note**: The screenshot for neofetch above/beside is a modification of this script, because I still have an Artix Linux partition with same user but with different homedir. That's why the packages are so much more.

## :syringe: Installation 
Easy, just clone and run `install.sh` as **root**. Next, you are asked to configure **local username** in `archroot.conf`.
```bash
git clone https://github.com/owl4ce/archroot.git && sudo ./archroot/install.sh
```
> - Arch Linux root directory will be installed to `/opt/archroot/root.x86_64/` after extracting tarball.
> - `archroot.conf` will be installed to `/etc/archroot.conf`.

### Adding environment variables
Here is an example of `ENV_VAR` using qt5ct as qt themer and enable [gtk3-nocsd](https://github.com/PCMan/gtk3-nocsd) in `archroot.conf`:
```cfg
# Put your desired environment variable here, for example
# ENV_VAR="QT_QPA_PLATFORMTHEME=qt5ct"
ENV_VAR="QT_QPA_PLATFORMTHEME=qt5ct GTK_CSD=0 LD_PRELOAD=/home/violet/.themes/libgtk3-nocsd.so.0"
```

## :anchor: Usage
```bash
USAGE: archroot --option

OPTIONS:
  -c, --create URL      Creates a chroot environment.
  -m, --mount           Mount chroot (API filesystems) directory.
  -u, --unmount         Unmount chroot (API filesystems) directory.
  -e, --enter           Enters chroot environment.
  -h, --help            Displays this help message.

https://github.com/owl4ce/archroot
https://github.com/lemniskett/archbox

```
### Installing chroot environment
Download link see [here](https://www.archlinux.org/download/). Then do,
```bash
sudo archroot -c archlinux-bootstrap-tarball-download-link.tar.gz
```
**Example link**: http://mirrors.evowise.com/archlinux/iso/2020.11.01/archlinux-bootstrap-2020.11.01-x86_64.tar.gz  
**Tips**: Skip tarball download process, just put the downloaded tarball file to `/opt/archroot/`. Then do,
```bash
sudo archroot -c fill-anything-hahah
```

### Mounting chroot directory (ᴀᴘɪ ꜰɪʟᴇꜱʏꜱᴛᴇᴍꜱ)
> Skip this if you have just finished installing the chrooted environment for the first time.
```bash
archroot -m
```
> You will be automatically asked for root password.

### Unmounting chroot directory (ᴀᴘɪ ꜰɪʟᴇꜱʏꜱᴛᴇᴍꜱ)
```bash
archroot -u
```
> You will be automatically asked for root password.

### Entering chroot environment
> Make sure you have mounted chroot directory before entering chroot, otherwise it will cause chroot system malfunction.
```bash
archroot --enter
```
> You will be automatically asked for root password.

### Executing commands chroot environment directly
```bash
archroot command
```
**Example command**: neofetch
> You will be automatically asked for root password.

## :bulb: Tips
### Bypass root password question
**SUDO**  
```bash
sudo visudo
```
Then add this to the bottom line (`/etc/sudoers`):
```cfg
%wheel  ALL=(root) NOPASSWD: /opt/archroot/copyresolv,/opt/archroot/command
```

**DOAS**  
Add this to `/etc/doas.conf`:
```cfg
permit nopass keepenv :wheel as root cmd /opt/archroot/copyresolv
permit nopass keepenv :wheel as root cmd /opt/archroot/command
```

### Include pacman package manager from Archroot into neofetch host
```bash
sudo $EDITOR `which neofetch`
```
Then edit this section:
```cfg
1305     case "$os" in
1306         "Linux" | "BSD" | "iPhone OS" | "Solaris")
1307             # Package Manager Programs.
1308             has "pacman-key" && tot pacman -Qq --color never
1309             has "dpkg"       && tot dpkg-query -f '.\n' -W
1310             has "rpm"        && tot rpm -qa
1311             has "xbps-query" && tot xbps-query -l
1312             has "apk"        && tot apk info
1313             has "opkg"	  && tot opkg list-installed
1314          	 has "pacman-g2"  && tot pacman-g2 -Q
1315             has "lvu"        && tot lvu installed
1316             has "tce-status" && tot tce-status -i
1317             has "pkg_info"   && tot pkg_info
1318             has "tazpkg"     && tot tazpkg list && ((packages-=6))
1319             has "sorcery"    && tot gaze installed
1320             has "alps"	  && tot alps showinstalled
1321             has "butch"	  && tot butch list
```
into:
```cfg
1305     case "$os" in
1306         "Linux" | "BSD" | "iPhone OS" | "Solaris")
1307             # Package Manager Programs.
1308             has "pacman-key" && tot pacman -Qq --color never
1309             has "dpkg"       && tot dpkg-query -f '.\n' -W
1310             has "rpm"        && tot rpm -qa
1311             has "xbps-query" && tot xbps-query -l
1312             has "apk"        && tot apk info
1313             has "opkg"	  && tot opkg list-installed
1314           	 has "pacman-g2"  && tot pacman-g2 -Q
1315             has "lvu"        && tot lvu installed
1316             has "tce-status" && tot tce-status -i
1317             has "pkg_info"   && tot pkg_info
1318             has "tazpkg"     && tot tazpkg list && ((packages-=6))
1319             has "sorcery"    && tot gaze installed
1320             has "alps"	  && tot alps showinstalled
1321             has "butch"	  && tot butch list
1322             pacman(){
1323                archroot pacman -Q
1324             }
1325             has "pacman" && tot pacman
```

### Shared fonts, themes, and icons
Archroot will not read fonts, themes, and icons from the host `/usr/share` directory. Because to avoid conflict, Archroot must have its own `/usr/share` directory. If you want to share from the host, you can use `/home/username/.fonts` (also .themes and .icons) instead.

### Installing yay AUR Helper
Just run this in chroot environment (`--enter`), instead of executing commands directly:
```bash
~/installyay
```

## :confetti_ball: Improving usage
### Using rofi as application launcher
First, install rofi in the Archroot.
```bash
archroot sudo pacman -S rofi
```
Basic usage:
```bash
archroot rofi -show drun
```

Then you can add it as a DE/WM keybind (e.g: openbox window manager):
> Need bypass root password question.
```bash
bash -c 'archroot rofi -show drun'
```

**If you use my [dotfiles](https://github.com/owl4ce/dotfiles), I suggest following this.**

Edit `~/.config/openbox/rc.xml`, then add this to keyboard tag:
```cfg
<!-- ARCHROOT -->
    <keybind key="A-r">
      <action name="Execute">
        <command>bash -c 'archroot ~/.config/rofi/scripts/appsmenu.sh'</command>
      </action>
    </keybind>
    <keybind key="W-S-Return">
      <action name="Execute">
        <command>bash -c 'urxvt -e archroot --enter'</command>
      </action>
    </keybind>
```
It will use rofi apps configuration as Archroot launcher, press <kbd>Alt + R</kbd> and launch the Archroot terminal by pressing <kbd>Super + Shift + Enter</kbd>.

Arch Linux|Gentoo/Linux
|--|--|
![Arch](https://i.ibb.co/NFkVBG8/artix.png)|![Gentoo](https://i.ibb.co/N1CcPPZ/gentoo.png)

## :gun: Uninstall Archroot completely
The most important thing here is don't forget to unmount the chroot environment directory, otherwise the host system will be deleted in the same shared directory (API filesystems). If you forget it, you will be notified by a `install.sh` script when you run `install.sh --uninstall`. This is why I don't like automount when the host system is booting, it will help when I want to remove Archroot which just simply reboots the host system to avoid serious problems.
```bash
sudo install.sh --uninstall
```
