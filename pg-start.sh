#!/bin/bash

echo '--------------'
echo 'sh pg-start.sh'
echo 'Starting PostgreSQL'
echo 'NOTE: This step is necessary if you are using PostgreSQL in a'
echo 'Docker development environment.'
echo 'If you are not using PostgreSQL in the development environment,'
echo 'you can skip this step to save time.'
echo '-----------------------------'
echo 'sudo service postgresql start'
sudo service postgresql start
