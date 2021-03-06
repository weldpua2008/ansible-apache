#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
RDIR="$( dirname "$SOURCE" )"
#SUDO=`which sudo 2> /dev/null`
SUDO=""
SUDO_OPTION="--sudo"
OS_TYPE=${1:-}
OS_VERSION=${2:-}
ANSIBLE_VERSION=${3:-}
echo "============= RUN TESTS FOR: =============================="
echo "              ${OS_TYPE} ${OS_VERSION} ${ANSIBLE_VERSION}"
echo "==========================================================="

################
# there is error with docker + SystemD:
#   https://github.com/ansible/ansible-modules-core/issues/593#issuecomment-144725409
# So for now I disabled SystemD on specified OS versions
##############
DISABLED_SYSTEMD="no"

ANSIBLE_VAR=""
ANSIBLE_INVENTORY="tests/test-inventory"
ANSIBLE_PLAYBOOk="tests/test.yml"
ANSIBLE_PREPARATION_PLAYBOOk="tests/prepare.yml"
#ANSIBLE_LOG_LEVEL="-vvv"
ANSIBLE_LOG_LEVEL=""

APACHE_CTL="apache2ctl"

# if there wasn't sudo then ansible couldn't use it
if [ "x$SUDO" == "x" ];then
    SUDO_OPTION=""
fi
START_DAEMON_CMD=""

if [ "${OS_TYPE}" == "centos" ];then

    APACHE_CTL="apachectl"
    if [ "${OS_VERSION}" == "7" ];then
        DISABLED_SYSTEMD="yes"
    fi
elif [ "${OS_TYPE}" == "ubuntu" ];then
    APACHE_CTL="apache2ctl"
    if [ "${OS_VERSION}" == "14.04" ];then
        DISABLED_SYSTEMD="yes"
    fi

elif [ "${OS_TYPE}" == "fedora" ];then
    APACHE_CTL="apachectl"
    DISABLED_SYSTEMD="yes"
fi

echo "=============================================="
echo "     DISABLED_SYSTEMD:"
echo "                      $DISABLED_SYSTEMD"
echo "=============================================="

ANSIBLE_EXTRA_VARS=""

if [ "${DISABLED_SYSTEMD}" == "yes" ];then
     ANSIBLE_VAR="apache_use_service=false"
     ANSIBLE_EXTRA_VARS=" -e apache_use_service=false "
     echo -n systemd > /proc/1/comm
fi

if [ "${ANSIBLE_VAR}x" != "x" ];then
    echo "======================================================"
    echo "   ANSIBLE_EXTRA_VARS:"
    echo "                      ${ANSIBLE_EXTRA_VARS}"
    echo "======================================================"

fi


cd $RDIR/..
printf "[defaults]\nroles_path = ../" > ansible.cfg

function test_playbook_syntax(){
    echo  ">>>started: ansible playbook syntax check"
    ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} --syntax-check || (echo "ansible playbook syntax check was failed" && exit 2 )

}

function test_playbook(){
    echo  ">>>started: Idempotence test"

    # first run
    ansible-playbook -i ${ANSIBLE_INVENTORY}  --connection=local $SUDO_OPTION $ANSIBLE_EXTRA_VARS $ANSIBLE_LOG_LEVEL  ${ANSIBLE_PLAYBOOk} || ( echo "first run was failed" && exit 2 )

    # Run the role/playbook again, checking to make sure it's idempotent.
    ansible-playbook -i ${ANSIBLE_INVENTORY} --connection=local $SUDO_OPTION $ANSIBLE_EXTRA_VARS $ANSIBLE_LOG_LEVEL ${ANSIBLE_PLAYBOOk} | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' ) || (echo 'Idempotence test: fail' && exit 1)
}
function extra_tests(){
    echo "=========================="
    echo  ">>>started: extra_tests"
    echo "  >>>>${APACHE_CTL} configtest"
    echo "=========================="
    ${APACHE_CTL} configtest || (echo "${APACHE_CTL} configtest was failed" && exit 100 )
    set +e
    echo "=========================="
    echo "          preparation"
    echo "=========================="

#    ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PREPARATION_PLAYBOOk} ${ANSIBLE_LOG_LEVEL} --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS}
#    ${APACHE_CTL} stop
#    sudo ${APACHE_CTL} stop
#    service apache2 stop
#    sudo service apache2 stop
#    killall apache || pkill apache
#    killall httpd || pkill httpd
#    killall apache2 || pkill apache2
#
#    sudo killall apache || sudo pkill apache
#    sudo killall httpd || sudo pkill httpd
#    sudo killall apache2 || sudo pkill apache2
#    echo "Apache server shouldn't working"
#    wget http://localhost > /dev/null && exit 100
#
#
#    ${APACHE_CTL} start
#    sudo ${APACHE_CTL} start
#
#    set -e
#    wget http://localhost > /dev/null || (echo "Apache server doesn't work property" && exit 100 )

}


set -e
function main(){
    test_playbook_syntax
    test_playbook
    extra_tests

}

################ run #########################
main
