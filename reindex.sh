#!/bin/bash

docker exec fu_stack_php php /code/n98-magerun.phar --root-dir=/code/http index:reindex:all
docker exec fu_stack_php php /code/n98-magerun.phar --root-dir=/code/http cache:clean
