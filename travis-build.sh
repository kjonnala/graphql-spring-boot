#!/bin/bash
set -ev

saveGitCredentials() {
    cat >$HOME/.netrc <<EOL
machine github.com
login ${GITHUB_USERNAME}
password ${GITHUB_TOKEN}

machine api.github.com
login ${GITHUB_USERNAME}
password ${GITHUB_TOKEN}
EOL
    chmod 600 $HOME/.netrc
}

if [ "${TRAVIS_PULL_REQUEST}" = "false" ] && [ "${TRAVIS_BRANCH}" = "master" ]; then
  if [ "${RELEASE}" = "true" ]; then
    echo "Deploying release to Bintray"
    saveGitCredentials
    ./gradlew clean assemble && ./gradlew check --info && ./gradlew bintrayUpload -x check --info
  else
    echo "Deploying snapshot"
    saveGitCredentials
    ./gradlew artifactoryPublish -Dsnapshot=true -Dbuild.number="${TRAVIS_BUILD_NUMBER}"
  fi
else
    echo "Verify"
    ./gradlew clean assemble && ./gradlew check --info
fi
