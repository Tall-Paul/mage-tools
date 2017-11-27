#!/bin/bash

SRCROOT="$(pwd)/../src"
TARGETROOT="$(pwd)/../http"

ignoreFiles=("changelog.txt","README.md")

elementIn () {
  shopt -s nocasematch
  local e match="$1"
  shift
  for e; do [[ "$match" =~ "$e" ]] && return 0; done
  return 1
}

function install_files {

  find $1 -type f -print0 | while read -d '' -r file; do
      #remove src from filepath
      file=${file/$1/}

      #ignore files
      #if elementIn $file "${array[@]}"; then
      #  echo "ignoring $file"
      #  continue
      #fi
      unset array
      #split remaining file path into array
      IFS='/' read -r -a array <<< "$file"
      FILEPATH=''
      DEPTH=${1/$(pwd)\//}
      unset array[0] #removes rogue directory seperator
      #loop through file path
      for element in "${array[@]}"
      do
          FILEPATH=$FILEPATH/$element
          TARGET=$TARGETROOT$FILEPATH
          SRC=$DEPTH$FILEPATH
          DEPTH=../$DEPTH
          if [ -L "${TARGET}" ]; then
            break
          fi
          #if target is a directory, continue loop
          if [ -d "${TARGET}" ]; then
            #remove empty directories from source
            if [ "$(ls -A $1$FILEPATH)" ]; then
                 continue
            else
                #empty directory, remove from src
                rmdir $1$FILEPATH
                break
            fi
          fi
          #if target is a file, remove it and symlink
          if [ -f "${TARGET}" ]; then
              if [ -L "${TARGET}" ]; then
                #it's a link, continue
                break
              fi
                #it's actually a file
                #check if the target differs from the src
                file1=`md5 $1$FILEPATH`
                file2=`md5 $TARGET`
                if [ "$file1" == "$file2" ]; then
                  #files are the same, remove src
                  printf "*"
                  rm -f $1$FILEPATH
                  break
                else
                  #different file in src, create symlink
                  printf "|"
                 rm -f "${TARGET}"
                  ln -s "${SRC}" "${TARGET}"
                  break
               fi
          fi
          #if target doesn't exist, create symlink
          if [ ! -e "${TARGET}" ]; then
              printf "-"
              #echo "symlinking $SRC $TARGET"
              ln -s "${SRC}" "${TARGET}"
              break
          fi
      done
  done
}

#check if installed
if [ -e "${TARGETROOT}/installed" ]; then
  exit
fi

find "../extensions" -mindepth 2 -maxdepth 2 -type d -print0 | while read -d '' -r file; do
    install_files $(pwd)/$file
done

install_files $SRCROOT

touch "${TARGETROOT}/installed"

echo "done"
