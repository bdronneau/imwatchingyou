#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# https://github.com/creationix/nvm
NVM_DIR=/home/vagrant/.nvm; export NVM_DIR
curl -sS -o- https://raw.githubusercontent.com/creationix/nvm/v0.25.4/install.sh | bash 2>&1 > /dev/null
echo "source ~/.nvm/nvm.sh" >> /home/vagrant/.profile
source /home/vagrant/.profile

nvm install $1
nvm alias default $1

chown -R vagrant:vagrant $NVM_DIR
