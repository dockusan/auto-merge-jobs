#!/bin/bash

REPO=$1
SOURCE_BRANCH=$2
DES_BRANCH=$3
if [[ -z $REPO ]] || [[ -z $SOURCE_BRANCH ]] || [[ -z $DES_BRANCH ]]
then
    echo "Missing input param."
    exit 1
fi

DIR="$(basename $REPO .git)-temp"
if [ -d "$DIR" ]; then
    echo "Project exist. Move to folder and checkout develop branch..."
else
    # clone project
    # TODO: need improve by fetch develop and develop_test branch only
    git clone --verbose $REPO $DIR || exit 1
fi

cd $DIR
printf "Starting merge from %s to %s ...\n" "${SOURCE_BRANCH}" "${DES_BRANCH}"    
# delete local develop-test branch
git checkout $SOURCE_BRANCH
# reset to top of develop-test branch
git reset --hard origin/$SOURCE_BRANCH
git pull origin $SOURCE_BRANCH

# checkout develop branch
git checkout $DES_BRANCH
git reset --hard origin/$DES_BRANCH
git pull origin $DES_BRANCH

#merge develop-test to develop
git merge $SOURCE_BRANCH

if [ $? -eq 0 ]; then
  git push origin $DES_BRANCH
  if [ $? -eq 0 ]; then
    echo "Merge successful"
  else
    echo "Merge failed"
    exit 1
  fi
else
  echo "Merge failed"
  exit 1
fi

