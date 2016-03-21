#!/bin/bash

# Immediately exit script on first error
set -e -o pipefail

# See .travis_tag.sh for more details on the Travis environment.

# SOURCE: http://xseignard.github.io/2013/02/18/continuous-deployement-with-github-travis-and-heroku-for-node.js/

# TODO: if [ "${TRAVIS_BRANCH}" == "master" ]; then
if [ "${TRAVIS_BRANCH}" == "dev" ]; then

  # TODO: TARGET_APP_NAME="basimilch"
  TARGET_APP_NAME="basimilch-dev"

  echo "Setting up '~/.ssh/config' to work with heroku."
  cat >> ~/.ssh/config <<EOF
Host heroku.com
   StrictHostKeyChecking no
   CheckHostIP no
   UserKnownHostsFile=/dev/null
EOF

  echo "Installing heroku toolbelt"
  wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh

  echo "Configuring heroku toolbelt using HEROKU_API_KEY environment variable"
  yes | heroku keys:add

  echo "Setting maintenance mode 'on' on heroku's app"
  heroku maintenance:on --app TARGET_APP_NAME

  echo "Caturing DB backup from heroku's app"
  # DOC: -e, --expire  # if no slots are available, destroy the oldest manual backup to make room
  heroku pgbackups:capture --expire --app TARGET_APP_NAME
fi
