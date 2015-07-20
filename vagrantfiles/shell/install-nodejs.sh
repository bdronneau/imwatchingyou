#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# see https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager#debian-and-ubuntu-based-linux-distributions
apt-get install curl
curl --silent --location https://deb.nodesource.com/setup_0.12 | bash -

apt-get install --yes nodejs