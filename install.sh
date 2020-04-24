#!/usr/bin/env bash

declare -a job_list
declare -i job_id=0

if [ -f "config" ] ; then
  source config
fi


log_setup() {
  exec > >(tee -a $LOGFILE)
  exec 2>&1
}

log() {
  if [ "$1" == "-n" ] ; then
    local n="-n"
    shift
  fi
  echo -e $n "[$(date --rfc-3339=seconds)]: $*"
}


apt_cmd() {
  log -n "installing apt package(s): $* ... "
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq $* < /dev/null > /dev/null
  if [ $? -gt 0 ] ; then 
    echo -e "\e[31mfailed\e[39m"
    return 1
  else
    echo -e "\e[32msuccess\e[39m"
  fi
}


snap_cmd() {
  log -n "installing snap package(s): $* ... "
  sudo snap install $* >/dev/null  
  if [ $? -gt 0 ] ; then 
    echo -e "\e[31mfailed\e[39m" 
    return 1
  else
    echo -e "\e[32msuccess\e[39m"
  fi
}


add_repository() {
  if [ "$1" == "-f" ] ; then
    log -n "adding $2 repository to /etc/apt/sources.list.d/${2}.list ... "
    echo "${@:3}" | sudo tee /etc/apt/sources.list.d/${2}.list > /dev/null
  else
    log -n "adding repository: $* ... "
    sudo DEBIAN_FRONTEND=noninteractive add-apt-repository "$*" > /dev/null
  fi

  if [ $? -gt 0 ] ; then 
    echo -e "\e[31mfailed\e[39m"
    return 1
  else
    echo -e "\e[32msuccess\e[39m"
  fi
  update
}


get_pkg() {
  [ -z "$1" ] && log ERROR: no package specified && return 1
  log -n "downloading package: $* ... \n" 
  TEMP_DEB="$(mktemp --suffix=.deb)" && \
    wget -q -O "$TEMP_DEB" "$*" && \
    apt_cmd "$TEMP_DEB" 
}


update() {
  log -n "updating package list... "
  sudo apt-get update &> /dev/null
  echo -e "\e[32mdone\e[39m"
}


dlg() {
  declare -a options
  category=$1
  for file in $2/* ; do
    id=$((job_id++))
    job_list[$id]=$file
    options+=($id "$(sed -n 's/^# name: //p' $file)" ${def:-off})
  done

  choices+=$(dialog --separate-output --checklist "$category" $((${#options[@]}/3+7)) 50 16 "${options[@]}" 2>&1 >/dev/tty)" "
  clear
}


install() {
  log installing $(sed -n 's/^# name: //p' $1) ...
  source "$1"
  [ $? -gt 0 ] && log ERROR: cannot run $1
}


main() {
  log Starting script
  sudo -v

  if [ ! -z $1 ] ; then
    file=$(find "$(dirname "$0")/scripts" -name "$1" -type f)
    if [ -r "$file" ] ; then
      install $file 
    else
      log ERROR: cannot find $file
      exit 1
    fi
    exit 0
  fi

  sudo apt-get update >/dev/null
  [ -a scripts/preinstall ] && log running preinstallation steps ... && source scripts/preinstall
  for dir in scripts/* ; do
    if [ -d $dir ] ; then
      dlg "$(basename $dir)" $dir
    fi
  done
  
  for choice in $choices ; do
    install ${job_list[$choice]}
  done
}

log_setup
main $*
