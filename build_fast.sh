#!/bin/bash

# After you use the reset.sh script to return the Docker container to a
# fresh Ruby on Rails environment and use the "git clone" command to
# download this project's source code, running this script sets up this
# project AND runs all tests.

# Resetting the Docker container to its original state AND running this
# script ensures that you are on top of all dependencies and can avoid
# being stopped in your tracks by the infamous "works on my machine"
# problem.

# This is Joel Spolsky's one-step build process at work.

# Killing the spring server is usually not necessary, but it's better to
# include this script and not need it than to need it but not have it.

sh pg-start.sh

echo '--------------'
echo 'bundle install'
bundle install

echo '-----------------'
echo 'sh kill_spring.sh'
sh kill_spring.sh

echo '-------------------------------------'
echo 'sudo -u postgres createuser -d adopta'
sudo -u postgres createuser -d adopta

PG_VERSION="$(ls /etc/postgresql)"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"

# Change the settings in the pg_hba.conf file
# Use the original settings PostgreSQL provided at time of installation
# but give adopta user database access without password
sudo bash -c "echo '# Allow adopta user to connect to database without password' > $PG_HBA"
sudo bash -c "echo 'local   all             adopta                                  trust' >> $PG_HBA"
sudo bash -c "echo '' >> $PG_HBA"
sudo bash -c "echo '# Database administrative login by Unix domain socket' >> $PG_HBA"
sudo bash -c "echo 'local   all             postgres                                peer' >> $PG_HBA"
sudo bash -c "echo '' >> $PG_HBA"
sudo bash -c "echo '# TYPE  DATABASE        USER            ADDRESS                 METHOD' >> $PG_HBA"
sudo bash -c "echo '' >> $PG_HBA"
sudo bash -c "echo '# Unix domain socket connections only' >> $PG_HBA"
sudo bash -c "echo 'local   all             all                                     peer' >> $PG_HBA"
sudo bash -c "echo '' >> $PG_HBA"
sudo bash -c "echo '# IPv4 local connections:' >> $PG_HBA"
sudo bash -c "echo 'host    all             all             0.0.0.0/0            trust' >> $PG_HBA"
sudo bash -c "echo '' >> $PG_HBA"
sudo bash -c "echo '# IPv6 local connections:' >> $PG_HBA"
sudo bash -c "echo 'host    all             all             ::1/128                 md5' >> $PG_HBA"

echo '-------------------------------'
echo 'sudo service postgresql restart'
sudo service postgresql restart
wait

# Creating the database for the development environment
echo '-------------------------------------------------------------------------------'
echo 'sudo -u postgres psql -c"CREATE DATABASE adopta_development WITH OWNER=adopta;"'
sudo -u postgres psql -c"CREATE DATABASE adopta_development WITH OWNER=adopta;"

# Creating the database for the testing environment
echo '------------------------------------------------------------------------'
echo 'sudo -u postgres psql -c"CREATE DATABASE adopta_test WITH OWNER=adopta;"'
sudo -u postgres psql -c"CREATE DATABASE adopta_test WITH OWNER=adopta;"

echo '---------------------------'
echo 'bundle exec rake db:migrate'
bundle exec rake db:migrate

echo '-----------------'
echo 'sh kill_spring.sh'
sh kill_spring.sh

echo "\n\n\n\n\n\n\n\n\n\n"

echo '----------------'
echo 'bundle exec rake'
bundle exec rake
