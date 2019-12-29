#!/bin/bash

echo;echo

if [ -n "$PCIT" ];then
  PCIT_USERNAME=$INPUT_USERNAME
  PCIT_TARGET_BRANCH=$INPUT_TARGET_BRANCH
  PCIT_GIT_URL=$INPUT_GIT_URL
  PCIT_LOCAL_DIR=$INPUT_LOCAL_DIR
  PCIT_EMAIL=$INPUT_EMAIL
  PCIT_KEEP_HISTORY=$INPUT_KEEP_HISTORY
  PCIT_GIT_TOKEN=$INPUT_GIT_TOKEN
  PCIT_MESSAGE=$INPUT_MESSAGE
fi

echo "==> Preparing deploy git pages"

set -ex

if ! [ -d ${PCIT_LOCAL_DIR} ];then exit; fi

rm -rf ${PCIT_LOCAL_DIR}/.git

if [ ${PCIT_KEEP_HISTORY:-'false'} = 'true' ];then
  git clone --bare -b ${PCIT_TARGET_BRANCH:-gh-pages} https://${PCIT_GIT_URL} ${PCIT_LOCAL_DIR}/.git || true
fi

set +x; echo "Deploying application"; set -x

cd ${PCIT_LOCAL_DIR}

if ! [ -d .git ];then
  new=true
fi

git init

git add .

git config user.name ${PCIT_USERNAME:-pcit-ce}

git config user.email ${PCIT_EMAIL:-ci@khs1994.com}

git commit -m "${PCIT_MESSAGE:-"Deploy Git by PCIT https://ci.khs1994.com"}" || exit 0

set +e; git remote get-url origin && git remote rm origin; set -e

set +x
echo "git remote add origin https://${PCIT_USERNAME:-pcit-ce}:PCIT_GIT_TOKEN@${PCIT_GIT_URL}.git"
git remote add origin https://${PCIT_USERNAME:-pcit-ce}:${PCIT_GIT_TOKEN}@${PCIT_GIT_URL}.git
set -x

if [ ${new:-false} == 'true' ];then git push origin master:${PCIT_TARGET_BRANCH:-gh-pages} -f ; exit 0; fi

git push origin ${PCIT_TARGET_BRANCH:-gh-pages}:${PCIT_TARGET_BRANCH:-gh-pages} -f || true
