#!/bin/bash

# Setup a new cloud9 IDE machine with some basic config files.
# Target: Ubuntu machine

if [ -z "${C9_USER}" ]; then
  echo "Not in a C9 machine. Exiting..."
  exit 1
fi

set -eox pipefail

# Create a log file of the script output
LOG_FILENAME="$(basename $0 .sh)_$(date +"%Y%m%d_%H%M%S").log"
exec >  >(tee -a ${LOG_FILENAME})
exec 2> >(tee -a ${LOG_FILENAME} >&2)

# set timezone to CET
sudo mv /etc/localtime /etc/localtime.bak && sudo ln -s /usr/share/zoneinfo/Europe/Zurich /etc/localtime && date

# tmux
[ -f ~/.tmux.conf ] && cp -v ~/.tmux.conf ~/.tmux.conf.backup_$(date +"%Y%m%d%H%M%S")
curl -L https://gist.githubusercontent.com/rbf/3529029/raw/.tmux.conf -o ~/.tmux.conf
# Disable tmux option not valid on Cloud9. Might be related to https://github.com/tony/tmux-config/issues/26
sed -i.orig -e 's/set -g status-utf8 on/# set -g status-utf8 on/' ~/.tmux.conf
# SOURCE: https://sanctum.geek.nz/arabesque/reloading-tmux-config/
# NOTE: tmux path found with 'ps -u | grep tmux'
# SOURCE: http://stackoverflow.com/a/26705778
/mnt/shared/sbin/tmux source-file ~/.tmux.conf

# gitconfig
[ -f ~/.gitconfig ] && cp -v ~/.gitconfig ~/.gitconfig.backup_$(date +"%Y%m%d%H%M%S")
curl -L https://gist.githubusercontent.com/raw/1845578/.gitconfig -o ~/.gitconfig

# git ignore
if [ -f ~/.gitignore_global ]; then cp -v ~/.gitignore_global ~/.gitignore_global.backup; fi;
curl -L https://gist.githubusercontent.com/rbf/2224744/raw/.gitignore_global -o ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global

# Update PostgreSQL to 9.4 (default version on Cloud9 as of this writing is 9.3.13)
# SOURCE: https://community.c9.io/t/can-we-upgrade-to-postgres-9-4/3897/4
psql --version
sudo service postgresql stop
sudo apt-get -y --purge remove postgresql\*
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get -y update
sudo apt-get -y install postgresql-9.4
psql --version

# Create a DB with UTF8 encoding.

# SOURCE: http://serverfault.com/a/544243
# SOURCE: http://stackoverflow.com/a/20815770
sudo service postgresql stop
sudo pg_dropcluster 9.4 main
# SOURCE: http://dba.stackexchange.com/a/19585
sudo pg_createcluster 9.4 main -e UTF8
# Allow DB users to connect without password.
# SOURCE: https://community.c9.io/t/can-we-upgrade-to-postgres-9-4/3897/4
# SOURCE: http://stackoverflow.com/a/9630739
sudo sed -i.orig -e 's/peer$/trust/' -e 's/md5$/trust/' /etc/postgresql/9.4/main/pg_hba.conf
sudo service postgresql start
# Create the DB user defined in /config/database.yml
# SOURCE: http://dba.stackexchange.com/a/19573
sudo su - postgres -c 'createuser --superuser basimilchdbuser'

# Clean up apt-get files
sudo apt-get -y update
sudo apt-get -y autoremove

# SOURCE: https://github.com/rvm/rvm/issues/3270
# NOTE: This is necessary at least with the current version of tmux on Cloud9 (1.8 as of this writing).
#       It might not be necessary with tmux v2+.
echo '# Force rvm to load the right ruby version from the Gemfile on each new tmux pane creation' >> ~/.tmux.conf
echo 'cd ${PWD}' >> ~/.bashrc
cd ${PWD}

# Prepare the rails dev environment.

# Install the required ruby version.
# SOURCE: https://github.com/rvm/rvm/issues/3158#issuecomment-72029755
${rvm_recommended_ruby}
gem install bundler
bundle install
bundle exec rake db:setup
bundle exec rake test

cat << EOF >> ~/.bashrc
echo
echo 'To launch the application:    rails server -b $IP -p $PORT'
echo 'To launch the console:        rails console'
echo 'To run tests on file changes: bundle exec guard'
echo 'Other useful commands:        bundle exec rake db:reset'
echo '                              bundle exec rake db:seed'
echo '                              bundle exec rake db:rollback STEP=3'
echo '                              bundle exec rake db:schema:load RAILS_ENV=test'
echo '                              bundle exec rake db:migrate'
echo
EOF
source ~/.bashrc
