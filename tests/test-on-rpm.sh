#!/usr/bin/env bash
#################################################
#
# Valeriy Solovyov <weldpua2008@gmail.com>
# Copyright(c) 2015
###############################################

SOURCE="${BASH_SOURCE[0]}"
RDIR="$( dirname "$SOURCE" )"
ANSIBLE_VERSION=${1:-latest}
OS_VERSION=`cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+'|cut -d "." -f1 |head -n 1`
SUDO=`which sudo 2> /dev/null`
SUDO_OPTION="--sudo"
# if there wasn't sudo then ansible couldn't use it
if [ "x$SUDO" == "x" ];then
    SUDO_OPTION=""
fi

set -e
if [ "${OS_VERSION}" == "7" ];then
    set +e
    yum -y install epel-release
    yum -y update  
    yum remove iputils-20121221-6.el7.x86_64 -y
    yum -y update
    yum -y groupinstall  "Development Tools" 
    yum -y update

    yum install -y PyYAML libyaml python-babel python-crypto python-simplejson python-paramiko python-pip python-crypto python-httplib2  python-jinja2  python-keyczar python-pyasn1 python-devel 

    set -e
    pip install --upgrade pip 
else
    set +e
    yum -y update
    yum -y install epel-release
    yum -y update
    yum install gcc glibc glibc-common  -y
    yum -y groupinstall  "Development Tools"
    yum install -y PyYAML libyaml python-babel python-crypto python-simplejson python-paramiko python-pip python-crypto python-httplib2  python-jinja2  python-keyczar python-pyasn1 python-devel
    set -e
    pip install --upgrade pip
fi


if [ "$ANSIBLE_VERSION" = "latest" ]; then
    pip install --upgrade ansible
    yum erase -y python-paramiko python-crypto;yum install -y python-paramiko python-crypto
    pip install --upgrade ansible

else
    pip install --upgrade ansible==$ANSIBLE_VERSION;
    yum erase -y python-paramiko python-crypto;yum install -y python-paramiko python-crypto
    pip install --upgrade ansible==$ANSIBLE_VERSION;

fi

cd $RDIR/..

printf "[defaults]\nroles_path = ../" > ansible.cfg
ansible-playbook -i tests/test-inventory tests/test.yml --syntax-check
ANSIBLE_SHORT_VERSION=`ansible-playbook --version 2> /dev/null|cut -d " " -f2|cut -d "." -f1,2` ansible-playbook -i tests/test-inventory tests/test.yml --connection=local ${SUDO_OPTION}

# Run the role/playbook again, checking to make sure it's idempotent.
ANSIBLE_SHORT_VERSION=`ansible-playbook --version 2> /dev/null|cut -d " " -f2|cut -d "." -f1,2` ansible-playbook -i tests/test-inventory tests/test.yml --connection=local ${SUDO_OPTION} | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' && exit 0) || (echo 'Idempotence test: fail' && exit 1)


exit 0
