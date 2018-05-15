#!/bin/bash

sudo mv http http-old
sudo rm -rf http-old
mkdir -p http

#sudo mv magentocomposer/vendor magentocomposer/vendor-old
#sudo rm -rf magentocomposer/vendor-old

#sudo rm -f magentocomposer/composer.lock


echo "Run composer update?  (only if your packages have changed, takes a long time!)"
read -p "Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  rm -rf vendor
  rm -rf bin
  rm composer.lock
  composer update --no-suggest --no-dev
fi

composer install --no-suggest --no-dev


cd http
sudo rm -rf media
sudo ln -s ../media .
sudo mkdir var/log
sudo chmod -R 777 var
sudo cp ../magentodocker/php/local.xml app/etc
cd ..
