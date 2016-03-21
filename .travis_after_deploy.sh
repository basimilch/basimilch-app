#!/bin/bash

# Immediately exit script on first error
set -e -o pipefail

# See .travis_tag.sh for more details on the Travis environment.

# TODO: if [ "${TRAVIS_BRANCH}" == "master" ]; then
if [ "${TRAVIS_BRANCH}" == "dev" ]; then

  # TODO: TARGET_APP_NAME="basimilch"
  TARGET_APP_NAME="basimilch-dev"

  echo "Setting maintenance mode 'on' on heroku's app"
  heroku maintenance:off --app "${TARGET_APP_NAME}"

  echo "Application ready again."
fi
