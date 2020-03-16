#!/usr/bin/env bash

declare -a job_list
declare -i job_id=0

if [ -f ".conf" ] ; then
  source .conf
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
  echo -e $n "INFO:[$(date --rfc-3339=seconds)]: $*"
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

update() {
  log -n "updating package list... "
  sudo apt-get update &> /dev/null
  echo -e "\e[32mdone\e[39m"
}

pre_install() {
  if [ -d preinstall ] ; then
    for file in preinstall/* ; do
      source $file
      echo Return: $?
    done
  fi
}

dlg() {
  declare -a options
  category=$1
  for file in $2/* ; do
    id=$((job_id++))
    job_list[$id]=$file
    options+=($id "$(sed -n 's/^# name: //p' $file)" off)
  done

  choices=$(dialog --separate-output --checklist "$category" $((${#options[@]}/3+7)) 50 16 "${options[@]}" 2>&1 >/dev/tty)" "
  clear
}

run_install() {
  for choice in $choices ; do
    log installing $(sed -n 's/^# name: //p' ${job_list[$choice]}) ...
    source ${job_list[$choice]}
    [ $? -gt 0 ] && log ERROR: cannot run ${job_list[$choice]}
  done
}


main() {
  log Starting script

  pre_install
  #dlg "Repositories" repositories
  dlg "Core Packages" core
  dlg "System Packages" system
  run_install
}

log_setup
main
