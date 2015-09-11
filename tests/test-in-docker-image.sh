#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
RDIR="$( dirname "$SOURCE" )"
SUDO=`which sudo 2> /dev/null`
SUDO_OPTION="--sudo"
OS_TYPE=${1:-}
OS_VERSION=${2:-}
ANSIBLE_VERSION=${3:-}

ANSIBLE_VAR=""

# if there wasn't sudo then ansible couldn't use it
if [ "x$SUDO" == "x" ];then
    SUDO_OPTION=""
fi

#if [ "${OS_TYPE}" == "centos" ];then
#    if [ "${OS_VERSION}" == "7" ];then
#        ANSIBLE_VAR="apache_use_service=False"
#    fi
#
#fi
ANSIBLE_EXTRA_VARS=" -e \"${ANSIBLE_VAR}\" "

cd $RDIR/..

printf "[defaults]\nroles_path = ../" > ansible.cfg
ansible-playbook -i tests/test-inventory tests/test.yml --syntax-check
#ANSIBLE_SHORT_VERSION=`ansible-playbook --version 2> /dev/null|cut -d " " -f2|cut -d "." -f1,2`
ansible-playbook -i tests/test-inventory tests/test.yml -vvv --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS}

# Run the role/playbook again, checking to make sure it's idempotent.
ansible-playbook -i tests/test-inventory tests/test.yml -vvv --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS} | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' && exit 0) || (echo 'Idempotence test: fail' && exit 1)

