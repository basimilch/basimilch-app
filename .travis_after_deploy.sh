#!/bin/bash

# Immediately exit script on first error
set -e -o pipefail

# See .travis_tag.sh for more details on the Travis environment.

if [ "${TRAVIS_BRANCH}" == "master" ]; then

  TARGET_APP_NAME="basimilch"

  echo "Setting maintenance mode 'off' on heroku's app"
  heroku maintenance:off --app "${TARGET_APP_NAME}"

  echo "Application ready again. YAY!"
fi
