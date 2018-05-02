SRCROOT="$(pwd)/src"
TARGETROOT="$(pwd)/http"

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
          LASTELEMENT=$element
          TARGET=$TARGETROOT$FILEPATH
          SRC=$DEPTH$FILEPATH
          DEPTH=../$DEPTH
          if [ -L "${TARGET}" ]; then
            break;
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
                #printf "|"
                rm -f "${TARGET}"
                ln -s "${SRC}" "${TARGET}"
                break
             fi
          fi
          #if target doesn't exist, create symlink
          if [ ! -e "${TARGET}" ]; then
              if [ $2 == 'extension' ]; then #we're installing an extension so....
                if [ -d "${1}${FILEPATH}" ]; then #this is a directory so....
                  #printf "~"
                  mkdir "${TARGET}"
                  continue
                else
                  #printf ">"
                  cp -f "${1}${FILEPATH}" "${TARGET}"
                  continue
                fi
              else
                printf "-"
                ln -s "${SRC}" "${TARGET}"
                break
              fi
          fi
      done
  done
}

echo "installing $1"

install_files $(pwd)/extensions/$1 extension
