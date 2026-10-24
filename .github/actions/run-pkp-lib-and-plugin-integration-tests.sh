#!/bin/bash

# @file actions/run-pkp-lib-and-plugin-integration-tests.sh
#
# Copyright (c) 2014-2025 Simon Fraser University
# Copyright (c) 2010-2025 John Willinsky
# Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
#
# Script to run Cypress integration tests

export CYPRESS_DBHOST='127.0.0.1' # Database hostname
export CYPRESS_BASE_URL='http://localhost:80'
export CYPRESS_DBNAME=${APPLICATION}-ci # Database name
export CYPRESS_DBUSERNAME=${APPLICATION}-ci # Database username
export CYPRESS_DBPASSWORD=${APPLICATION}-ci # Database password
export CYPRESS_FILESDIR=files

set -e # Fail on first error

if [ "${TERM:-}" = "" ]; then
  echo "Setting TERM to dumb" # makes tput happy
  TERM="dumb"
fi
echo '{ "baseUrl": "'${CYPRESS_BASE_URL}'", "DBHOST": "'${CYPRESS_DBHOST}'", "DBUSERNAME": "'$CYPRESS_DBUSERNAME'","DBPASSWORD": "'$CYPRESS_DBPASSWORD'","DBNAME": "'$CYPRESS_DBNAME'",  "FILESDIR": "'$CYPRESS_FILESDIR'"}' > cypress.env.json

if [[ "$NODE_VERSION" -gt "13"  ]]; then
  npx cypress run --headless --browser chrome --config '{"specPattern":["lib/pkp/cypress/tests/integration/**/*.cy.js"]}'
  if [ -d "cypress/tests/integration" ]; then
    npx cypress run --headless --browser chrome --config '{"specPattern":["cypress/tests/integration/**/*.cy.js"]}'
  fi
fi

# Cypress 5.6 (stable-3_3_0) breaks on Chrome 144+; use its bundled Electron instead.
if [[ "$NODE_VERSION" -lt "13"  ]]; then
    npx cypress run --headless --browser electron --config integrationFolder=lib/pkp/cypress/tests/integration
  if [ -d "cypress/tests/integration" ]; then
    npx cypress run --headless --browser electron --config integrationFolder=cypress/tests/integration
  fi
fi

