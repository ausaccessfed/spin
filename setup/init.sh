#!/bin/sh

set -e

if [ ! -e /etc/redhat-release ]; then
  echo 'Only RHEL distributions are supported, sorry.'
  exit 1
fi

grep -q 'CentOS Linux release 7' /etc/redhat-release || {
  echo 'The officially supported distribution is CentOS 7, but your'
  echo '/etc/redhat-release indicates a different distribution is in use.'
  echo
  echo 'You may proceed, but support will be very limited for platform-specific'
  echo 'issues you may encounter.'
  echo
  echo -n 'Your version: '
  cat /etc/redhat-release


  echo
  echo -n 'Type "yes" to proceed: '
  read x

  if [ "$x" != "yes" ]; then exit 1; fi
}

if [ ! -e main.yml ]; then
  echo 'Must be run from the SPIN setup directory'
  exit 1
fi

yum -y install epel-release
yum -y install ansible

ansible-playbook main.yml
