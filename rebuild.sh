#!/bin/bash

sudo mv http http-old
sudo rm -rf http-old

sudo mv magentocomposer/vendor magentocomposer/vendor-old
sudo rm -rf magentocomposer/vendor-old

sudo rm -f magentocomposer/composer.lock

cd magentocomposer
composer install --prefer-dist
cd ..
cd http
sudo rm -rfv media
sudo ln -s ../media/media .
sudo mkdir var/log
sudo chmod -R 777 var
sudo cp ../magentodocker/php/local.xml app/etc
cd ..

mv magentocomposer/vendor/composer/ http/
