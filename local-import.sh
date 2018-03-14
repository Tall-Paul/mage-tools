#!/bin/bash

SRCROOT="$PWD/src"
TARGETROOT="$PWD/base/magento-mirror"
declare -i count=0

function check_patched(){
  cat $SRCROOT/app/etc/applied.patches.list | grep "patching file $1" &> /dev/null
  if [ $? == 0 ]; then
     rm $2
     echo "file $1 is patched but unmodified :)"
  else
     echo "file $1 has been modified in your source!"
  fi
}

function recursive_check(){
  if [ $count -gt 5 ]; then
    exit 0
  fi
  #echo $PWD
  if [ "$1" == '' ]; then
    local BREADCRUMB=$1
  else
    local BREADCRUMB=$1/
  fi
  cd $SRCROOT/$BREADCRUMB

  #find directories
  local directory=''
  find . -type d -print0 -mindepth 1 -maxdepth 1 | while read -d '' -r directory; do
    local directory_recurse=${directory/.\//}
    #((count++))
    #check if directory exists in base magento install, if it doesn't we need to keep it
    local TARGET="$TARGETROOT/$BREADCRUMB$directory_recurse"
    if [ -d $TARGET ]; then
      recursive_check $BREADCRUMB$directory_recurse
    fi
    #remove empty directory
    if [ ! -n "$(ls -A $SRCROOT/$BREADCRUMB$directory_recurse)" ]; then
      rmdir $SRCROOT/$BREADCRUMB$directory_recurse
    fi
  done

  #file comparison
  find . -type f -print0 -mindepth 1 -maxdepth 1 | while read -d '' -r file; do
    file=${file/.\//}
    local TARGET="$TARGETROOT/$BREADCRUMB$file"
    if [ -f $TARGET ]; then
      #file exists in base install
      local SOURCE="$SRCROOT/$BREADCRUMB$file"
      if cmp $SOURCE $TARGET >/dev/null 2>&1; then
        #files are the same, remove it
        rm $SOURCE
        #echo "file $BREADCRUMB$file is unmodified :)"
      else
        check_patched $BREADCRUMB$file $SOURCE
      fi
    fi
  done

}




echo "WARNING!! this script will delete anything in the 'src' and 'deployment' folders, are you sure you want to do this?"
read -p "Are you sure? (y/n)" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then

  rm -rf ./deployment/*
  rm -rf ./base

  echo "running comparison...."

  version=`php getVersion.php`

  echo "Version is $version"

  mkdir base

  cd base

  git clone git@github.com:OpenMage/magento-mirror.git

  cd magento-mirror

  git fetch --all --tags --prune
  git checkout tags/$version

  cd ../..

  find . -name '.DS_Store' -type f -delete
  cd $SRCROOT
  recursive_check ''


fi
