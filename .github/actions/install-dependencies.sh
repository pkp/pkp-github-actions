#!/bin/bash

# @file actions/install_dependencies.sh
#
# Copyright (c) 2014-2025 Simon Fraser University
# Copyright (c) 2010-2025 John Willinsky
# Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
#
# Script to install the Composer and Node dependencies

php -v
composer --version
set -e

# Search for composer.json files, and run Composer to install the dependencies.
# COMPOSER_ALLOW_UNSAFE_PHAR_METADATA=1 is for PHP < 8; remove once OJS/OMP/OPS 3.3 testing is disabled.
find . -maxdepth 4 -name composer.json -exec bash -c 'COMPOSER_ALLOW_UNSAFE_PHAR_METADATA=1 composer --no-ansi --working-dir="`dirname {}`" install --optimize-autoloader' ";"


sudo npm cache clean -f
sudo npm install -g n
sudo n  $NODE_VERSION
source ~/.bashrc

# Install node modules
npm i g -npm
if [[ "$NODE_VERSION" -gt "13"  ]]; then
  npm i @vue/cli-service
  npm i cypress@12.17.4
fi
npm install
npm run build
