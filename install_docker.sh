#!/bin/bash

# Instructions from https://docs.docker.com/engine/installation/linux/ubuntulinux/

version=`lsb_release -rs`

error() {
  echo "" >&2
  echo ">>> ERROR - $1" >&2
}

update_apt_sources() {
  apt-get update
  apt-get install -y apt-transport-https ca-certificates
  apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

  case "$version" in
    "14.04" ) entry="deb https://apt.dockerproject.org/repo ubuntu-trusty main";;
    "15.10" ) entry="deb https://apt.dockerproject.org/repo ubuntu-wily main";;
    "16.04" ) entry="deb https://apt.dockerproject.org/repo ubuntu-xenial main";;
    * ) error "Ubuntu $version not recognized!"; exit 1;;

  esac

  echo "$entry" > '/etc/apt/sources.list.d/docker.list'
  apt-get update
  apt-get purge lxc-docker
}

install_prereqs() {
  if [ "$version" == "14.04" ] || [ "$version" == "15.10" ] || [ "$version" == "16.04" ]; then
    apt-get update
    apt-get install -y linux-image-extra-$(uname -r)
  fi
  if [ "$version" == "14.04" ]; then
    apt-get install -y apparmor
  fi
}

install_docker() {
  apt-get update
  apt-get install -y docker-engine
  service docker start
}

if [ "$(whoami)" != "root" ]; then
  error "Please run as root"
  exit 1
fi

if [ "$version" == "14.04" ] || [ "$version" == "15.10" ] || [ "$version" == "16.04" ]; then
  update_apt_sources
  install_prereqs
  install_docker
else
  error "Ubuntu $version not supported"
  exit 1
fi