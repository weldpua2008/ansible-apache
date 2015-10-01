[![Build Status](https://travis-ci.org/weldpua2008/ansible-apache.svg?branch=master)](https://travis-ci.org/weldpua2008/ansible-apache)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/weldpua2008/ansible-apache/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/weldpua2008/ansible-apache.svg)](https://github.com/weldpua2008/ansible-apache/issues)
[![GitHub forks](https://img.shields.io/github/forks/weldpua2008/ansible-apache.svg)](https://github.com/weldpua2008/ansible-apache/network)
[![GitHub stars](https://img.shields.io/github/stars/weldpua2008/ansible-apache.svg)](https://github.com/weldpua2008/ansible-apache/stargazers)
Role Name
========
Ansible apache

Install apache 2




Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
-------------------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: weldpua2008.ansible-apache, apache_listen_ports: [80, 443] }

License
-------

MIT

Author Information
------------------

Valeriy Solovyov