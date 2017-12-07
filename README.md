# mage-tools
Magento 1.x Tooling for build and deployments on OSX (might work on linux, not tested)

This is a collection of scripts to aid developing and deploying a magento 1.x solution with zero downtime and a 
pragmatic, repeatable build system

Import.sh - grab the files from an installed instance of magento, compare them to the base install for that version
            and report on any 'hacked' files
            
magentocomposer - composer setup for magento, installs magento (and user defined packages) with no muss, no fuss

magentodocker - full docker environment for magento (redis, mysql, php7, nginx)

First create your server config (see config/staging for an example).

Starting from an existing install of magento?  

+ run 'import.sh' to grab your codebase 
+ add a database dump to magentodocker/db/import
+ run docker-compose up -d in magentodocker directory
+ add an entry to your hosts file pointing 'magento.local' at 127.0.0.1

Where does everything live?

+ /src <--- your code, in the same directory structure as magento (app,skin etc)
+ /extensions <--- third party code, in a structure like 'company/modulename/app....'
+ /configs <--- server config files
+ /deployment <--- cached deployments

How do I develop locally?

+ checkout a branch
+ run rebuild.sh to install magento / symlink everything else
+ edit files in src

How do I run a deployment? 

./deploy.sh will prompt you for:

+ a branch to deploy (you can use current, to deploy your current http folder)
+ a server to deploy to (from the configs)

the deployment process first checks out the branch and runs a build under 'deployment', then rsyncs that build to the server

Server directory stucture:

eg: web server is pointing at /var/www/vhosts/staging.lavishalice.com ($ROOT)

+ $ROOT/static/media <-- media directory for magento
+ $ROOT/releases <-- deploy script deploys under here
+ $ROOT/http <-- symlinked to releases/latest/http


