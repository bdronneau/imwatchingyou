#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# change dir to the synced folder
cd $1

echo "Install bundler dependencies..."
bundle install

echo "Install npm dependencies..."
# we can't put symlinks on vagrant boxes under windows
# http://askubuntu.com/a/269735
npm install --no-bin-links