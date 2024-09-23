#!/bin/bash

#
# USAGE:
# runAllTests.sh [options]
#  -C Include class tests in lib/pkp.
#  -P Include plugin tests in lib/pkp.
#  -J Include job tests in lib/pkp.
#  -c Include class tests in application.
#  -p Include plugin tests in application.
#  -j Include job tests in application.
#  -d Display debug output from phpunit.
# If no options are specified, then all tests will be executed.
#
# Some tests will certain require environment variables in order to cnfigure
# Set  environment variables.
export DBHOST=localhost # Database hostname
export DBNAME=${APPLICATION}-ci # Database name
export DBUSERNAME=${APPLICATION}-ci # Database username
export DBPASSWORD=${APPLICATION}-ci # Database password
export FILESDIR=files # Files directory (relative to application directory -- do not do this in production!)
export DATABASEDUMP=database.sql.gz # Path and filename where a database dump can be created/accessed
export FILESDUMP=files.tar.gz # Path and filename where a database dump can be created/accessed


set -e # Fail on first error


### Command Line Options ###

# Run all types of tests by default, unless one or more is specified
DO_ALL=1

# Various types of tests
DO_PKP_CLASSES=0
DO_PKP_PLUGINS=0
DO_PKP_JOBS=0
DO_APP_CLASSES=0
DO_APP_PLUGINS=0
DO_APP_JOBS=0
DO_COVERAGE=0
DEBUG=""



# Versions up from 3.4+
if [[ "$NODE_VERSION" -gt "15"  ]]; then

  # Parse arguments
while getopts "CPcpdRJj" opt; do
  	case "$opt" in
		J)	DO_ALL=0
			DO_PKP_JOBS=1
			;;
  		C)	DO_ALL=0
  			DO_PKP_CLASSES=1
  			;;
  		P)	DO_ALL=0
  			DO_PKP_PLUGINS=1
  			;;
		j)	DO_ALL=0
			DO_APP_JOBS=1
			;;
  		c)	DO_ALL=0
  			DO_APP_CLASSES=1
  			;;
  		p)	DO_ALL=0
  			DO_APP_PLUGINS=1
  			;;
  		d)	DEBUG="--debug"
  			;;
  		R)	DO_COVERAGE=1
  			;;
  	esac
  done

  PHPUNIT='php lib/pkp/lib/vendor/phpunit/phpunit/phpunit --configuration lib/pkp/tests/phpunit.xml --testdox'

  # Where to look for tests
  TEST_SUITES='--testsuite '

  if [ \( "$DO_ALL" -eq 1 \) -o \( "$DO_PKP_JOBS" -eq 1 \) ]; then
	  TEST_SUITES="${TEST_SUITES}LibraryJobs,"
  fi

  if [ \( "$DO_ALL" -eq 1 \) -o \( "$DO_PKP_CLASSES" -eq 1 \) ]; then
    TEST_SUITES="${TEST_SUITES}LibraryClasses,"
  fi

  if [ \( "$DO_ALL" -eq 1 \) -o \( "$DO_PKP_PLUGINS" -eq 1 \) ]; then
    TEST_SUITES="${TEST_SUITES}LibraryPlugins,"
  fi

  if [ \( "$DO_ALL" -eq 1 \) -o \( "$DO_APP_JOBS" -eq 1 \) ]; then
    TEST_SUITES="${TEST_SUITES}ApplicationJobs,"
  fi
  if [ \( "$DO_ALL" -eq 1 \) -o \( "$DO_APP_CLASSES" -eq 1 \) ]; then
    TEST_SUITES="${TEST_SUITES}ApplicationClasses,"
  fi

  if [ \( "$DO_ALL" -eq 1 \) -o \( "$DO_APP_PLUGINS" -eq 1 \) ]; then
    TEST_SUITES="${TEST_SUITES}ApplicationPlugins,"
  fi

  if [ "$DO_COVERAGE" -eq 1 ]; then
    export XDEBUG_MODE=coverage
  fi

  $PHPUNIT $DEBUG ${TEST_SUITES%%,}

  if [ "$DO_COVERAGE" -eq 1 ]; then
    cat lib/pkp/tests/results/coverage.txt
  fi
fi

# for Version 3.3
if [[ "$NODE_VERSION" -lt "15"  ]]; then
  while getopts "bCPcpfdH" opt; do
  	case "$opt" in
  		C)	DO_ALL=0
  			DO_PKP_CLASSES=1
  			;;
  		P)	DO_ALL=0
  			DO_PKP_PLUGINS=1
  			;;
  		c)	DO_ALL=0
  			DO_APP_CLASSES=1
  			;;
  		p)	DO_ALL=0
  			DO_APP_PLUGINS=1
  			;;
  		d)	DEBUG="--debug"
  			;;
  	esac
  done
  # Identify the tests directory.
  TESTS_DIR=`readlink -f "lib/pkp/tests"`

  # Shortcuts to the test environments.
  TEST_CONF1="--configuration $TESTS_DIR/phpunit-env1.xml"
  TEST_CONF2="--configuration $TESTS_DIR/phpunit-env2.xml"
  phpunit='php lib/pkp/lib/vendor/phpunit/phpunit/phpunit'

  if [ \( "$DO_ALL" -eq 1 \) -o \( "$DO_PKP_CLASSES" -eq 1 \) ]; then
  	$phpunit $DEBUG $TEST_CONF1 lib/pkp/tests/classes
  fi

  if [ \( "$DO_ALL" -eq 1 \) -o \( "$DO_PKP_PLUGINS" -eq 1 \) ]; then
  	$phpunit $DEBUG $TEST_CONF2 lib/pkp/plugins
  fi

  if [ \( "$DO_ALL" -eq 1 \) -o \( "$DO_APP_CLASSES" -eq 1 \) ]; then
  	$phpunit $DEBUG $TEST_CONF1 tests/classes
  fi

  if [ \( "$DO_ALL" -eq 1 \) -o \( "$DO_APP_PLUGINS" -eq 1 \) ]; then
  	find plugins -maxdepth 3 -name tests -type d -exec $phpunit $DEBUG $TEST_CONF2 "{}" ";"
  fi


fi