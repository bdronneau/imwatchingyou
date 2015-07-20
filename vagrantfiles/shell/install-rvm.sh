#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# see https://rvm.io/integration/vagrant
#
curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
curl -sSL https://get.rvm.io | bash -s $1