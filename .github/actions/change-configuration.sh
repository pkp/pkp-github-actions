#!/bin/bash

# @file actions/buildjs.sh
#
# Copyright (c) 2014-2025 Simon Fraser University
# Copyright (c) 2010-2025 John Willinsky
# Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
#
# Script to adapt the configuration of OJS/OMP/OPS for test server

set -e

sed -i 's/; smtp_server = mail\.example\.com/smtp_server = localhost/' config.inc.php
sed -i 's/; smtp_port = 25/smtp_port = 1025/' config.inc.php
sed -i 's/; smtp = On/smtp = On/'  config.inc.php
sed -i 's/default = sendmail/default = smtp/' config.inc.php
sed -i -e "s/^log_channel = daily$/log_channel = errorlog/" config.inc.php
