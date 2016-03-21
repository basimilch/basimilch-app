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

  # DOC: https://devcenter.heroku.com/articles/authentication#usage-examples
  cat >> ~/.netrc <<EOF
machine api.heroku.com
  login ${HEROKU_API_LOGIN}
  password ${HEROKU_API_KEY}
EOF
chmod 600 ~/.netrc

  echo "Installing heroku toolbelt"
  wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh

  echo "Setting maintenance mode 'on' on heroku's app"
  heroku maintenance:on --app "${TARGET_APP_NAME}"

  echo "Caturing DB backup from heroku's app"
  # DOC: https://devcenter.heroku.com/articles/heroku-postgres-backups#creating-a-backup
  heroku pg:backups capture --app "${TARGET_APP_NAME}"
fi
