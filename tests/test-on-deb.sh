#!/usr/bin/env bash
#################################################
#
# Valeriy Solovyov <weldpua2008@gmail.com>
# Copyright(c) 2015
###############################################

SOURCE="${BASH_SOURCE[0]}"
RDIR="$( dirname "$SOURCE" )"
ANSIBLE_VERSION=${1:-latest}
OS_VERSION=`cat /etc/*release | grep -oE '[0-9]+\.[0-9]+'|cut -d "." -f1 |head -n 1`
SUDO=`which sudo 2> /dev/null`
SUDO_OPTION="--sudo"
# if there wasn't sudo then ansible couldn't use it
if [ "x$SUDO" == "x" ];then
    SUDO_OPTION=""
fi


apt-get update
apt-get install python-pip python-dev -y
if [ "${OS_VERSION}" == "12" ];then
    apt-get install python-setuptools -y
    apt-get install    build-essential -y
    apt-get install ansible -y
    apt-get remove ansible --purge  -y
    apt-get install python-dev python2.7-dev python-pip -y
    apt-get install --reinstall python-pkg-resources -y
    easy_install --upgrade pip
    easy_install --upgrade ansible

fi

set -e

if [ "$ANSIBLE_VERSION" = "latest" ]; then

    pip install --upgrade ansible;
else
    pip install --upgrade ansible==$ANSIBLE_VERSION;
fi


cd $RDIR/..

printf "[defaults]\nroles_path = ../" > ansible.cfg
ansible-playbook -i tests/test-inventory tests/test.yml --syntax-check
ANSIBLE_SHORT_VERSION=`ansible-playbook --version 2> /dev/null|cut -d " " -f2|cut -d "." -f1,2` ansible-playbook -i tests/test-inventory tests/test.yml --connection=local ${SUDO_OPTION}

# Run the role/playbook again, checking to make sure it's idempotent.
ANSIBLE_SHORT_VERSION=`ansible-playbook --version 2> /dev/null|cut -d " " -f2|cut -d "." -f1,2` ansible-playbook -i tests/test-inventory tests/test.yml --connection=local ${SUDO_OPTION} | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' && exit 0) || (echo 'Idempotence test: fail' && exit 1)


exit 0
