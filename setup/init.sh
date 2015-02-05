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

expect_file() {
  [ -e $1 ] || {
    echo "Missing file: $1"
    echo
    echo 'Please ensure you have followed the installation instructions.'
    exit 1
  }
}

expect_file '/opt/spin/app/setup/spin.config'
expect_file '/opt/spin/app/setup/assets/app/support.md'
expect_file '/opt/spin/app/setup/assets/app/consent.md'
expect_file '/opt/spin/app/setup/assets/app/welcome.md'
expect_file '/opt/spin/app/setup/assets/app/logo.png'
expect_file '/opt/spin/app/setup/assets/app/favicon.png'
expect_file '/opt/spin/app/setup/assets/apache/server.key'
expect_file '/opt/spin/app/setup/assets/apache/server.crt'
expect_file '/opt/spin/app/setup/assets/apache/intermediate.crt'

yum -y install epel-release
yum -y install ansible

# This is written to /etc/environment, but not available in the current session
# which was logged in before the file was written.
export RBENV_ROOT=/opt/spin/rbenv

ansible-playbook main.yml -i inventory
