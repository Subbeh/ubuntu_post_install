#!/usr/bin/env bash

LOGFILE=~/install.txt
REL_NO=$(lsb_release -sr)
REL_NAME=$(lsb_release -sc)
def=on # default install toggle (on/off)

# restore
SYSTEM_BACKUP=~/data/backup/system/
FIREFOX_BACKUP=/data/backup/firefox-browser-profile.tar.bz2

# sources
JAVA_SE_URL="https://download.oracle.com/otn/java/jdk/11.0.6+8/90eb79fb590d45c8971362673c5ab495/jdk-11.0.6_linux-x64_bin.deb"
DOCKER_URL="https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)"
DROPBOX_URL="https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2019.02.14_amd64.deb"
CHROME_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
EXPR_VPN_URL="https://download.expressvpn.xyz/clients/linux/expressvpn_2.4.2-1_amd64.deb"

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

logsetup() {
    exec > >(tee -a $LOGFILE)
    exec 2>&1
}


log() {
    echo "INFO:[$(date --rfc-3339=seconds)]: $*"
}


apt_install() {
  log "Apt: Installing $*"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq $* < /dev/null > /dev/null
}


snap_install() {
  log "Snap: Installing $*"
  sudo snap install $* >/dev/null
}


pre_install() {
  # install essential packages
  apt_install dialog \
              snapd \
              curl \
              software-properties-common \
              gcc \
              make \
              perl

  # set def to 'off' if undefined
  def={def:-off}
}


dlg_repos() {
  # Repositories dialog
  cmd=(dialog --separate-output --checklist "Add repositories:" 22 76 16)
  options=(
    100 "Partner" $def
    101 "Multiverse" $def
    102 "universe" $def
  )

  choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear
}


dlg_core() {
  # Core packages
  cmd=(dialog --separate-output --checklist "Install core packages:" 22 76 16)
  options=(
    200 "HWE kernel" $def
    201 "Build tools" $def
    202 "Linux headers" $def
    203 "Ubuntu restricted extras" $def
    204 "TLP" $def
    205 "Microsoft TrueType core fonts" $def
    206 "Java JRE & JDK" $def
    207 "Oracle Java SE" $def
    208 "Python 3" $def
  )

  choices+=" "$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear
}


dlg_system() {
  # System applications
  cmd=(dialog --separate-output --checklist "Install system packages:" 22 76 16)
  options=(
    300 "Synaptic Package Manager" $def
    302 "Flatpak" $def
    303 "Git" $def
    304 "Docker" $def
    305 "Wine" $def
    306 "VirtualBox" $def
    307 "DropBox" $def
    308 "Bleachbit" $def
    309 "Stacer" $def
    310 "Asbru" $def
    311 "Terminator" $def
    312 "Kupfer" $def
  )

  choices+=" "$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear
}


dlg_browsers() {
  # Browsers
  cmd=(dialog --separate-output --checklist "Install browsers:" 22 76 16)
  options=(
    400 "Chrome" $def
    401 "Chromium" $def
    402 "Firefox" $def
  )

  choices+=" "$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear
}


dlg_editors() {
  # Editors
  cmd=(dialog --separate-output --checklist "Install editors:" 22 76 16)
  options=(
    500 "Gedit" $def
    501 "PyCharm" $def
    502 "IntelliJ" $def
    503 "Atom" $def
    504 "Visual Studio Code" $def
    505 "KWrite" $def
  )

  choices+=" "$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear
}


dlg_media() {
  # Media
  cmd=(dialog --separate-output --checklist "Install media packages:" 22 76 16)
  options=(
    600 "VLC" $def
    601 "Cheese" $def
    602 "Popcorn Time" $def
    603 "Flameshot" $def
  )

  choices+=" "$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear
}


dlg_various() {
  # Various
  cmd=(dialog --separate-output --checklist "Install various packages:" 22 76 16)
  options=(
    700 "GNOME Tweaks (GNOME)" $def
    701 "Dolphin plugins (KDE)" $def
    702 "Transmission" $def
    703 "Steam" $def
    704 "Caffeine" $def
    705 "FileZilla" $def
    706 "Spotify" $def
    707 "Gnome-calculator" $def
    708 "Tusk" $def
  )

  choices+=" "$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear
}


dlg_post_install() {
  # Post installation configuration
  cmd=(dialog --separate-output --checklist "Post installation configuration:" 22 76 16)
  options=(
    800 "Restore system backup" $def
    801 "Restore Firefox" $def
    802 "ExpressVPN" $def
    803 "Dell fan control" $def
    804 "Remove KDE PIM packages" $def
    805 "Clean up installation files" $def
  )

  choices+=" "$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear
}


install_repos() {
  for choice in $choices ; do
    case $choice in
        100) # Adding Partner repository
          log "adding partner repository"
          sudo add-apt-repository "deb http://archive.canonical.com/ubuntu ${REL_NAME:?not set} partner"
          ;;
        101) # Adding Multiverse repository
          log "adding multiverse repository"
          sudo add-apt-repository multiverse
          ;;
        102) # Adding Universe repository
          log "adding universe repository"
          sudo add-apt-repository universe
          ;;
    esac
  done
}


install_core() {
  for choice in $choices ; do
    case $choice in
      200) # Installing Hardware Enabled kernel
        apt_install --install-recommends linux-generic-hwe-${REL_NO:?not set} \
                                         xserver-xorg-hwe-${REL_NO:?not set}
        ;;
      201) # Installing build packages
        apt_install build-essential \
                    dkms \
                    libssl-dev \
                    libffi-dev 
        ;;
      202) # Installing Linux Headers
        apt_install linux-headers-$(uname -r)
        ;;
      203) # Installing Ubuntu Restricted Extras
        apt_install ubuntu-restricted-extras
        ;;
      204) # Installing TLP
        apt_install tlp \
                    tlp-rdw
        ;;
      205) # Installing Microsoft TrueType core fonts
        apt_install ttf-mscorefonts-installer
        ;;
      206) # Installing Java JRE & JDK
        apt_install default-jre \
                    default-jdk
        ;;
      207) # Installing Oracle Java SE
        log "Installing Oracle Java SE"
        TEMP_DEB="$(mktemp)" && 
          wget -q -O "$TEMP_DEB" -c --no-cookies --no-check-certificate \
               --header "Cookie: oraclelicense=accept-securebackup-cookie"
               "${JAVA_SE_URL:?not set}" && \
          sudo dpkg -i "$TEMP_DEB"
        [ $? -gt 0 ] && sudo apt --fix-broken install -y
        ;;
      208) # Installing Python 3 packages
        apt_install python3 \
                    python3-pip
        ;;
    esac
  done
}


install_system() {
  for choice in $choices ; do
    case $choice in
      300) # Installing Synaptic Package Manager
        apt_install synaptic
        ;;
      302) # Installing Flatpak
        apt_install flatpak
        ;;
      303) # Installing Git
        apt_install git
        ;;
      304) # Installing Docker
        log "Installing Docker"
        apt_install apt-transport-https \
                    ca-certificates \
                    gnupg-agent
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${REL_NAME:?not set} stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
        sudo apt-get update &> /dev/null
        apt_install docker-ce docker-ce-cli containerd.io
        # download docker compose
        sudo curl -sL "${DOCKER_URL:?not set}" -o /usr/local/bin/docker-compose
        # add current user to group
        sudo groupadd docker
        sudo usermod -aG docker $USER
        ;;
      305) # Installing Wine"
        apt_install wine-stable
        ;;
      306) # Installing VirtualBox
        wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
        echo "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian ${REL_NAME:?not set} contrib" | \
          sudo tee /etc/apt/sources.list.d/virtualbox.list >/dev/null
        sudo apt-get update &> /dev/null
        apt_install $(sudo apt-cache search virtualbox | grep -o ^virtualbox-[0-9]\.[0-9] | tail -1)
        ;;
      307) # Installing DropBox
        log "Installing DropBox"
        apt_install libpango1.0-0 \
                    libpangox-1.0-0
        TEMP_DEB="$(mktemp)" && \
          wget -q -O "$TEMP_DEB" "${DROPBOX_URL:?not set}" && \
          sudo dpkg -i "$TEMP_DEB"
        [ $? -gt 0 ] && sudo apt --fix-broken install -y
        ;;
      308) # Installing BleachBit
        apt_install bleachbit
        ;;
      309) # Installing Stacer
        echo "deb http://ppa.launchpad.net/oguzhaninan/stacer/ubuntu bionic main" | \
          sudo tee /etc/apt/sources.list.d/stacer.list >/dev/null
        sudo apt-get update &> /dev/null
        apt_install stacer
        ;;
      310) # Installing Asbru
        curl -s https://packagecloud.io/install/repositories/asbru-cm/asbru-cm/script.deb.sh | sudo bash
        apt_install asbru-cm
        ;;
      311) # Installing Terminator
        apt_install terminator
        ;;
      312) # Installing Kupfer
        apt_install kupfer
        ;;
    esac
  done
}


install_browsers() {
  for choice in $choices ; do
    case $choice in
      400) # Installing Chrome
        log "Installing Chrome"
        TEMP_DEB="$(mktemp)" && \
          wget -q -O "$TEMP_DEB" ${CHROME_URL:?not set} && \
          sudo dpkg -i "$TEMP_DEB" >/dev/null
        [ $? -gt 0 ] && sudo apt --fix-broken install -y >/dev/null
        ;;
      401) # Installing Chromium
        apt_install chromium-browser
        ;;
      402) # Installing Firefox
        log "Installing Firefox"
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A6DCF7707EBC211F >/dev/null
        echo "deb http://ppa.launchpad.net/ubuntu-mozilla-security/ppa/ubuntu bionic main" | \
          sudo tee /etc/apt/sources.list.d/firefox.list >/dev/null
        sudo apt-get update &> /dev/null
        apt_install firefox
        ;;
    esac
  done
}


install_editors() {
  for choice in $choices ; do
    case $choice in
      500) # Installing Gedit
        apt_install gedit
        ;;
      501) # Installing PyCharm
        snap_install pycharm-community --classic
        ;;
      502) # Installing IntelliJ
        snap_install intellij-idea-community --classic
        ;;
      503) # Installing Atom
        snap_install atom --classic
        ;;
      504) # Installing Visual Studio Code"
        snap_install --classic code
        ;;
      505) # Installing KWrite"
        apt_install kwrite
        ;;
    esac
  done
}


install_media() {
  for choice in $choices ; do
    case $choice in
      600) # Installing VLC
        snap_install vlc
        ;;
      601) # Installing Cheese
        apt_install cheese
        ;;
      602) # Installing Popcorn Time
        log "Installing Popcorn Time"
        apt_install libgconf-2.4
        sudo mkdir /opt/popcorntime
        TEMP_DEB="$(mktemp)" && \
          wget -q -O "$TEMP_DEB" https://get.popcorntime.app/build/Popcorn-Time-0.3.10-Linux-64.tar.xz && \
            sudo tar Jxf "$TEMP_DEB" -C /opt/popcorntime
        sudo ln -sf /opt/popcorntime/Popcorn-Time /usr/bin/popcorntime
        ;;
      603) # Installing Flameshot
        apt_install flameshot
        ;;
    esac
  done
}


install_various() {
  for choice in $choices ; do
    case $choice in
      700) # Installing GNOME Tweaks (GNOME)
        apt_install gnome-tweaks
        ;;
      701) # Installing Dolphin plugins (KDE)
        apt_install dolphin-plugins
        ;;
      702) # Installing Transmission
        echo "deb http://ppa.launchpad.net/transmissionbt/ppa/ubuntu bionic main" | \
          sudo tee /etc/apt/sources.list.d/transmission.list >/dev/null
        sudo apt-get update &> /dev/null
        apt_install transmission-cli \
                    transmission-common \
                    transmission-daemon
        ;;
      703) # Installing Steam
        apt_install steam-installer
        ;;
      704) # Installing Caffeine
        apt_install caffeine
        ;;
      705) # Installing FileZilla
        apt_install filezilla
        ;;
      706) # Installing Spotify
        snap_install spotify
        ;;
      707) # Installing Gnome-calculator
        snap_install gnome-calculator
        ;;
      708) # Installing Tusk
        snap_install tusk
        ;;
    esac
  done
}


post_install() {
  log TEST $choices
  for choice in $choices ; do
    case $choice in
        800) # Restoring system backup
          log "Restoring system backup"
          if [ -d "${SYSTEM_BACKUP:?not set}" ] ; then
            mkdir -p ~/backup && \
              sudo rsync -vr --exclude '.git' --stats --backup-dir=/home/$USER/backup "${SYSTEM_BACKUP}" / && \
              sudo chown -R $USER:$USER /home/$USER/
          fi
          ;;
        801) # Restoring Firefox profile
          log "Restoring Firefox profile"
          # backup using "tar -jcvf /data/backup/firefox-browser-profile.tar.bz2 ~/.mozilla"
          if [ -r "${FIREFOX_BACKUP:?not set}" ] ; then
            rm -rf ~/.mozilla
            tar xf "$FIREFOX_BACKUP" --strip-components=2 -C ~/
          fi
          ;;
        802) # Setting up ExpressVPN
          log "Setting up ExpressVPN"
          TEMP_DEB="$(mktemp)" && \
            wget -q -O "$TEMP_DEB" ${EXPR_VPN_URL:?not set} && \
            sudo dpkg -i "$TEMP_DEB" >/dev/null
            expressvpn activate
          ;;
        803) # Setting up Dell fan control
          #apt_install i8kutils
          # TODO
          ;;
        804) # Purge KDE PIM packages
          log "Purging KDE PIM packages"
          sudo apt-get purge -y accountwizard \
                                akonadi-backend-mysql \
                                akonadi-server \
                                akregator \
                                kaddressbook \
                                kdepim-addons \
                                kdepim-runtime \
                                kdepim-themeeditors \
                                kleopatra \
                                kmail \
                                knotes \
                                kontact \
                                korganizer \
                                ktnef \
                                mbox-importer \
                                pim-data-exporter \
                                pim-sieve-editor > /dev/null
        ;;
        805) # Cleaning up installation files
          log "Cleaning up installation files"
          sudo apt-get autoclean
          sudo apt-get clean
          sudo apt-get autoremove
        ;;
    esac
  done
}

main() {
  log Starting script

  pre_install

  dlg_repos
  dlg_core
  dlg_system
  dlg_browsers
  dlg_editors
  dlg_media
  dlg_various
  dlg_post_install

  install_repos
  install_core
  install_system
  install_browsers
  install_editors
  install_media
  install_various

  post_install
}

logsetup
main