#!/bin/bash

# Instructions from https://docs.docker.com/engine/installation/linux/ubuntulinux/

ubuntu=`lsb_release -rs`

error() {
  echo "" >&2
  echo ">>> ERROR - $1" >&2
}

update_apt_sources() {
  apt-get update
  apt-get install -y apt-transport-https ca-certificates
  apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

  case $ubuntu in
    "14.04" ) entry="deb https://apt.dockerproject.org/repo ubuntu-trusty main";;
    "15.10" ) entry="deb https://apt.dockerproject.org/repo ubuntu-wily main";;
    "16.04" ) entry="deb https://apt.dockerproject.org/repo ubuntu-xenial main";;
    * ) error "Ubuntu $ubuntu not recognized!"; exit 1;;

  esac

  echo "$entry" > '/etc/apt/sources.list.d/docker.list'
  apt-get update
  apt-get purge lxc-docker
}

install_prereqs() {
  if [ "$ubuntu" == "14.04" ] || [ "$ubuntu" == "15.10" ] || [ "$ubuntu" == "16.04" ]; then
    apt-get update
    apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
  fi
  if [ "$ubuntu" == "14.04" ]; then
    apt-get install -y apparmor
  fi
}

install_docker() {
  apt-get update
  apt-get install -y docker-engine
  service docker start
}

install_compose() {
  curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
}

if [ "$(whoami)" != "root" ]; then
  error "Please run as root"
  exit 1
fi

# parse command line arguments
while [[ $# > 0 ]]
do
key="$1"
case $key in
  --install-compose) INSTALL_COMPOSE=1;;
  *) ;;
esac
shift
done

if [ "$ubuntu" == "14.04" ] || [ "$ubuntu" == "15.10" ] || [ "$ubuntu" == "16.04" ]; then
  update_apt_sources
  install_prereqs
  install_docker
  if [ "$INSTALL_COMPOSE" == 1 ]; then
    install_compose
  fi
else
  error "Ubuntu $ubuntu not supported"
  exit 1
fi
