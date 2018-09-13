# Ansible AWS Greengrass

[![Build Status](https://travis-ci.org/vmware/ansible-aws-greengrass.svg?branch=master)](https://travis-ci.org/vmware/ansible-aws-greengrass)

This is an Ansible repo to set up the server side features for an AWS
Greengrass project and deploy the IoT portions that would run in a data
center.  

## Overview

This project includes the following abilities:

* Create roles and policies necessary to run Greengrass and interact with
devices
* Generate Greengrass Groups and Cores identities at AWS
* Generate automatic devices and associated certificates necessary for
communication
* Deploy lambda functions and associate them with Greengrass Groups
* Install and configure Greengrass Cores at the target runtime location
* Deploy configuration versions to Greengrass Cores to start and upgrade their
operation

## Try it out

1. Deploy a host for the controller (this might be your development box.)
2. Connect to the controller and perform remaining steps there
3. Install Ansible (http://docs.ansible.com/ansible/)
    * Quick steps for ubuntu 14.04, as an example:
        1. `sudo apt-get install -y python-pip python-dev libssl-dev sshpass`
        1. `sudo pip install --upgrade setuptools`
        1. `sudo pip install ansible markupsafe jmespath`
4. Clone this repository and cd into it
5. Configure hosts (check values in the inventory file, e.g. ```cp inventory.sample inventory``` and edit)
6. Copy `extra_vars.yml.sample` to `extra_vars.yml`, and customize as necessary.
7. Set password and other security (optional)
   ```
   echo "$VAULT_PASSWORD" > vault_password
   # For example, AWS keys...
   ansible-vault encrypt_string --vault-id vmware@vault_password 'access-key' --name aws_access_key
   ansible-vault encrypt_string --vault-id vmware@vault_password 'secret-key' --name aws_secret_key
   # and paste the output into extra_vars
   ```
   Also ensure you have credentials or keys for ssh to all target servers.
   NOTE: You can also manually enter the vault password during execution with ```--vault-id vmware@prompt```
8. You may wish to first run the `awscli` role targeting your development box
(e.g. localhost) and perform later steps from there.
   ```
   ansible-playbook site.yml -i inventory --vault-id vmware@vault_password --extra-vars "@extra_vars.yml" -kK --tags dev
   ```
9. Run site playbook:
    ```
    ansible-playbook site.yml -i inventory --vault-id vmware@vault_password --extra-vars "@extra_vars.yml" -kK
    ```
    or
    ```
    ansible-playbook site.yml -i inventory --vault-id vmware@prompt --extra-vars "@extra_vars.yml" -kK
    ```

Running on OSX for development
------------------------------

To test basic provisioning on OSX, you have options.  You may wish to
run ansible on the OSX machine, targeting VMs launched via VMware
Fusion, VirtualBox, etc., or you can run a container (see below) on OSX for the
controller.

Local with Containers
---------------------

Installing docker is an exercise for the reader; follow best practices for your
platform.

Build the container:
```
docker build -t vmware/ansible-aws-greengrass .
```

Run the container interactively for debugging:
```
# Build a version with debug tools
docker build -t vmware/ansible-aws-greengrass:debug -f Dockerfile.debug .
# For debugging, run the container with VNC so you can debug ansible.
docker run -it -v $PWD:/code -p 5920:5920 --entrypoint /bin/bash vmware/ansible-aws-greengrass:debug /vnc/vnc.sh
# You can then connect with VNC to your docker host, port 5920 (display 20).
# Or alternatively, run no-vnc:
docker run -it -v $PWD:/code -p 6080:6080 --entrypoint /bin/bash vmware/ansible-aws-greengrass:debug /novnc/novnc.sh
# ...and then connect in a browser to your docker host, port 6080.
```

Run the container to perform ansible steps:
```
docker run -it -v $PWD:/code vmware/ansible-aws-greengrass
```

### Prerequisites

* You'll need Ansible
* Before first run, you'll need AWS credentials with at least IAM, IoT, and
Greengrass permissions, and most likely with S3 read/write
* You must ensure the current Greengrass Core distribution is available on S3
(at the time of this writing, greengrass-linux-x86-64-1.3.0.tar.gz), or host it
at some URL and supply that by setting the appropriate variable.
* AWS Greengrass Core role currently only supports Ubuntu; you'll need an
Ubuntu VM or machine, or be prepared to port.
* This role uses the json_query filter which requires jmespath on the local
machine.

### Build & Run

You can, of course, run the entire playbook to completion, which will deploy all
configured parts of Greengrass.  For a first run, it's simpler to break up into
multiple steps to verify correct configuration.

The typical end-to-end process is as follows.

1. Configure machine inventory and extra_vars for your environment.
2. Run Ansible with the dev tag to set up the host machine.
```
ansible-playbook site.yml -i inventory --extra-vars "@extra_vars.yml" -kK --tags dev
```
3. Connect to that host machine and then run Ansible with the greengrass-init
tag to make AWS console changes and setup the basic IoT items.
```
ansible-playbook site.yml -i inventory --extra-vars "@extra_vars.yml" -kK --tags greengrass-init
```
4. Run Ansible with the lambda-deploy tag to deploy lambda functions to AWS.
(Only if Lambdas are intended to run at Greengrass Cores)
```
ansible-playbook site.yml -i inventory --extra-vars "@extra_vars.yml" -kK --tags greengrass-init
```
5. Run Ansible with the greengrass-core tag to deploy
and configure the greengrass cores.
```
ansible-playbook site.yml -i inventory --extra-vars "@extra_vars.yml" -kK --tags greengrass-core
```
6. Run Ansible with the greengrass-deploy tag to deploy a version of the runtime
configuration and start IoT processing.
```
ansible-playbook site.yml -i inventory --extra-vars "@extra_vars.yml" -kK --tags greengrass-deploy
```

## Documentation

See code files for further documentation.  The ```extra_vars.yml.sample``` file
has sample settings for customization for your environment.

## Releases & Major Branches

## Contributing

The ansible-aws-greengrass project team welcomes contributions from the community. If you wish to contribute code and you have not
signed our contributor license agreement (CLA), our bot will update the issue when you open a Pull Request. For any
questions about the CLA process, please refer to our [FAQ](https://cla.vmware.com/faq). For more detailed information,
refer to [CONTRIBUTING.md](CONTRIBUTING.md).

## License
