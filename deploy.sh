#!/bin/bash

#set slackenabled=1 to enable slack notifications
slackenabled=0
webhookurl="update this with your slack url"
slackchannel="enter a slack channel here without the leading #"


repo=`git config --get remote.origin.url`
startfolder="$(pwd)"
deploymentfolder=""

echo "Enter branch to Deploy OR current:"
git branch -r | sed "s/ origin\///" | tail -n +2
echo
read branch

if [ $branch == "current" ]
then
  deploymentfolder="$(pwd)"
  #unlink media folder so we don't copy it!
  rm -rf ./http/media
else
  rebuild=1
  deploymentfolder=$startfolder/deployment/$branch/website/
  if [ -d ./deployment/$branch ]
  then
      read -p "Build already exists, rebuild?" -n 1 -r
      if [[ $REPLY =~ ^[Yy]$ ]]
      then
        rebuild=1
        rm -rf ./deployment/$branch
      else
        rebuild=0
      fi
  fi
  if [ $rebuild == 1 ]
  then
    mkdir -p deployment/$branch
    cd deployment/$branch
    git clone -b $branch --single-branch $repo ./website
    cd website
    ./rebuild.sh
    echo $branch > http/branch.txt
    cd ../../..
  fi

fi

cd $startfolder
echo

echo "Enter server to deploy to: [dev,staging,production,none]"
read config

if [ ! -f ./configs/$config/include.sh ]; then
  echo "No config found for $config, exiting"
  exit 0;
fi

source ./configs/$config/include.sh

cd $deploymentfolder
branch=$(<./http/branch.txt)

release="`date +%Y%m%d%H%M%S`"
echo "Ready to deploy $branch to $config"
read -p "Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "removing old releases..."
  ssh $host "cd $root/releases && ls -t | tail -n +3 | xargs sudo rm -rf"
  ssh $host "mkdir $root/releases/$release"
  echo "Copying files, might take a while..."
  rsync -azL -P  --exclude-from 'excludelist.txt' http $host:$root/releases/$release | python ./bin/rsyncbar.py
  echo "Making links...."
  ssh $host "ln -sfn $root/config/local.xml $root/releases/$release/http/app/etc/local.xml"
  #ssh $host "cd $root/releases/$release/http && find $root/static/ -maxdepth 1 -mindepth 1 | xargs ln -sfn"
  ssh $host "ln -sfn $root/static/media/ $root/releases/$release/http/"
  ssh $host "ln -sfn $root/static/feeds/ $root/releases/$release/http/"
  ssh $host "ln -sfn $root/static/sitemap/ $root/releases/$release/http/"
  ssh $host "ln -sfn $root/static/delivery.json $root/releases/$release/http/"
  ssh $host "sudo chown -R $user:$group $root/releases/$release"
  read -p "Make web symlink? " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    ssh $host "ln -sfn $root/releases/$release/http $root/htdocs"

    read -p "Run update scripts? " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      ssh $host "cd $root && ./n98-magerun.phar sys:setup:run"
    fi

    read -p "Clear cache?" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      ssh $host "cd $root && ./n98-magerun.phar cache:clean"
    fi
  fi
fi

if [ $slackenabled == 1 ]
then
msgTitle="Deployment"
msgBody="Deployed $branch to $config"
#post message to slack if available
read -d '' payLoad << EOF
{
        "channel": "#${slackchannel}",
        "username": "Deployment Bot",
        "icon_emoji": ":sunglasses:",
        "attachments": [
            {
                "fallback": "${msgTitle}",
                "color": "good",
                "title": "${msgTitle}",
                "fields": [{
                    "title": "message",
                    "value": "${msgBody}",
                    "short": false
                }]
            }
        ]
    }
EOF


statusCode=$(curl \
        --write-out %{http_code} \
        --silent \
        --output /dev/null \
        -X POST \
        -H 'Content-type: application/json' \
        --data "${payLoad}" ${webhookurl})

echo "posted to slack and got response $statusCode"
fi

#relink media folder just in case we removed it
cd $startfolder/http
ln -sf ../media .
