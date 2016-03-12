#!/bin/bash

# Alternative shebang line: /usr/bin/env sh
# DOC: https://docs.travis-ci.com/user/customizing-the-build/

set -ev

# Alternative set line:
# Fail fast and fail hard.
# set -eox pipefail

# - Customizing the Build - Travis CI
#   DOC: https://docs.travis-ci.com/user/customizing-the-build/

# - Environment Variables - Travis CI
#   DOC: https://docs.travis-ci.com/user/environment-variables/

# - Feature Request: automatically create (and push) Git tag after successful build · Issue #1476 · travis-ci/travis-ci
#   DOC: https://github.com/travis-ci/travis-ci/issues/1476

# - Feature Request: automatically create (and push) Git tag after successful build · Issue #1476 · travis-ci/travis-ci
#   DOC: https://github.com/travis-ci/travis-ci/issues/1476#issuecomment-55614399

# - Travis-CI Auto-Tag Build for GitHub Release - Stack Overflow
#   DOC: http://stackoverflow.com/questions/28217556/travis-ci-auto-tag-build-for-github-release

# - Heroku Deployment - Travis CI
#   DOC: https://docs.travis-ci.com/user/deployment/heroku/

# - GitHub Releases Uploading - Travis CI
#   DOC: https://docs.travis-ci.com/user/deployment/releases


# TODO: See if there is a way to skip the build (and release) on a custom condition.
#       E.g. putting a whitelist of github username in an ENV variable on travis,
#       and checking against it before the build...?
# DOC: https://docs.travis-ci.com/user/customizing-the-build/#Breaking-the-Build


# Additionally, Travis CI sets environment variables you can use in
# your build, e.g. to tag the build, or to run post-build deployments.
# DOC: https://docs.travis-ci.com/user/environment-variables/#Default-Environment-Variables

# TRAVIS_BRANCH:For builds not triggered by a pull request this is the
# name of the branch currently being built; whereas for builds
# triggered by a pull request this is the name of the branch targeted
# by the pull request (in many cases this will be master).
echo "TRAVIS_BRANCH = ${TRAVIS_BRANCH}"

# TRAVIS_BUILD_DIR: The absolute path to the directory where the
# repository being built has been copied on the worker.
echo "TRAVIS_BUILD_DIR = ${TRAVIS_BUILD_DIR}"

# TRAVIS_BUILD_ID: The id of the current build that Travis CI uses
# internally.
echo "TRAVIS_BUILD_ID = ${TRAVIS_BUILD_ID}"

# TRAVIS_BUILD_NUMBER: The number of the current build (for example,
# “4”).
echo "TRAVIS_BUILD_NUMBER = ${TRAVIS_BUILD_NUMBER}"

# TRAVIS_COMMIT: The commit that the current build is testing.
echo "TRAVIS_COMMIT = ${TRAVIS_COMMIT}"

# TRAVIS_COMMIT_RANGE: The range of commits that were included in the
# push or pull request.
echo "TRAVIS_COMMIT_RANGE = ${TRAVIS_COMMIT_RANGE}"

# TRAVIS_JOB_ID: The id of the current job that Travis CI uses
# internally.
echo "TRAVIS_JOB_ID = ${TRAVIS_JOB_ID}"

# TRAVIS_JOB_NUMBER: The number of the current job (for example,
# “4.1”).
echo "TRAVIS_JOB_NUMBER = ${TRAVIS_JOB_NUMBER}"

# TRAVIS_OS_NAME: On multi-OS builds, this value indicates the
# platform the job is running on. Values are linux and osx currently,
# to be extended in the future.
echo "TRAVIS_OS_NAME = ${TRAVIS_OS_NAME}"

# TRAVIS_PULL_REQUEST: The pull request number if the current job is a
# pull request, “false” if it’s not a pull request.
echo "TRAVIS_PULL_REQUEST = ${TRAVIS_PULL_REQUEST}"

# TRAVIS_REPO_SLUG: The slug (in form: owner_name/repo_name) of the
# repository currently being built. (for example, “travis-ci/travis-
# build”).
echo "TRAVIS_REPO_SLUG = ${TRAVIS_REPO_SLUG}"

# TRAVIS_SECURE_ENV_VARS: Whether or not encrypted environment vars
# are being used. This value is either “true” or “false”.
echo "TRAVIS_SECURE_ENV_VARS = ${TRAVIS_SECURE_ENV_VARS}"

# TRAVIS_TEST_RESULT: is set to 0 if the build is successful and 1 if
# the build is broken.
echo "TRAVIS_TEST_RESULT = ${TRAVIS_TEST_RESULT}"

# TRAVIS_TAG: If the current build for a tag, this includes the tag’s
# name.
echo "TRAVIS_TAG = ${TRAVIS_TAG}"


echo "Using $(git --version)"

# TODO: Testing with 'dev' branch. Once the tagging works, it should only be done on 'master'.
# if [ "${TRAVIS_BRANCH}" == "master" ]; then
if [ "${TRAVIS_BRANCH}" == "dev" ]; then
  git config --global user.email "builds@travis-ci.org"
  git config --global user.name "Travis CI"
  git fetch --tags
  # export GIT_TAG=build-$TRAVIS_BRANCH-$(date -u "+%Y-%m-%d")-$TRAVIS_BUILD_NUMBER
  export GIT_TAG="build-${TRAVIS_BUILD_NUMBER}"
  export GIT_TAG_MESSAGE="TravisCI build ${TRAVIS_BUILD_NUMBER} on branch '${TRAVIS_BRANCH}', from version: $(git describe --always --match 'v*')"

  # TODO: Consider using this mechanism to later retrieve the version from the app.
  # echo -n $GIT_TAG > public/version
  # git commit -m "Set build VERSION number" public/version

  git tag ${GIT_TAG} -a -m "${GIT_TAG_MESSAGE}"

  # SOURCE: http://stackoverflow.com/a/13051597
  # git push --quiet https://${GITHUBKEY}@github.com/basimilch/basimilch-app ${GIT_TAG} > /dev/null 2>&1
  git push --quiet ${GIT_TAG} > /dev/null 2>&1
fi
