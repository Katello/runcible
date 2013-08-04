#!/bin/bash


NAME="runcible"
VERSION=`cat ./lib/runcible/version.rb | grep VERSION | awk -F '"' '{print $2}'` 
RPM_VERSION=`cat *.spec | grep Version: | awk '{print $2}'`

if [ "$VERSION" != "$RPM_VERSION" ] ; then
  echo "Gem version ($VERSION) and rpm version ($RPM_VERSION) do not match"
  echo "Have you run tito tag yet?"
  exit 1
fi


read -p "Would you like to release $NAME-$VERSION (yes/no/skip)? "
if [ "$REPLY" == "yes" ]; then
  gem build runcible.gemspec || exit -1
  gem push runcible-$VERSION.gem || exit -1
elif [ "$REPLY" == "skip" ]; then
  echo "Skipping"
else 
  echo "Exiting"
  exit -1
fi


read -p "Would you like to release documentation for $NAME-$VERSION (yes/no/skip)? "
if [ "$REPLY" == "yes" ]; then
  #validate upstream remote
  git remote | grep upstream
  if [ $? -eq 0 ]; then
    REMOTE="upstream"
  fi

  git remote | grep origin
  if [ $? -eq 0 -a -z "$REMOTE" ]; then
    REMOTE="origin"
  fi

  if [ -z "$REMOTE" ]; then
    echo "Cannot find git remote named 'upstream' or 'origin'" && exit -1
  fi

  FILE_COUNT=`git ls-files --exclude-standard --others | wc -l`
  if [ "$FILE_COUNT" != "0" ]; then
    echo "Untracked files found, cannot build.  Please clean your tree before building." && exit -1
  fi

  #checkout gh-pages branch if needed
  git branch | grep gh-pages
  if [ $? -ne 0 ]; then
    git branch gh-pages $REMOTE/gh-pages || exit -1
  fi
  
  echo "Building docs"
  yard doc || exit -1
  git checkout gh-pages || exit -1
  cp -rf doc/* ./
  git add ./
  git commit -a -m "Updating docs to version $VERSION"
  echo "* To push out new docs:"
  echo "  git push $REMOTE gh-pages:gh-pages"


elif [ "$REPLY" == "skip" ]; then
  echo "Skipping"
else 
  echo "Exiting"
  exit -1
fi

echo "* To build new rpms in koji, switch back to master and: "
echo "   tito release koji"
