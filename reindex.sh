#!/bin/bash

docker exec magento_stack_php php /code/n98-magerun.phar --root-dir=/code/http index:reindex:all
docker exec magento_stack_php php /code/n98-magerun.phar --root-dir=/code/http cache:clean
