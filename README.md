INSTALLATION GUIDE
==================


## Install node.js ##

Consult package.json to determine the required version of node.js

    VERSION=v`fgrep '"node"' package.json | cut -d\" -f4`

Either install node.js manually, following the steps described at
https://github.com/joyent/node/wiki/Installation

Alternatively (and preferred), install nvm from https://github.com/creationix/nvm
and setup node.js via

    nvm install $VERSION
    nvm use $VERSION


## Setup ruby for using SASS to build CSS files ##

This step may be skipped in favor of using node + sass

 * install rvm (ruby version manager) https://rvm.beginrescueend.com/
 * install a suitable version of ruby (any 1.9.3 MRI should do fine)
 * optionally create a gemset for the project as you see fit
 * run `gem install bundler` for that gemset
 * run `bundle install` to get haml and sass
 * run `sass --watch sass/:public/css` to convert sass files continously


## redis ##

* Install redis (>= 2.2.12) from http://redis.io/download
* Run `src/redis-server`


## Install npm, the node package manager ##

Execute `curl http://npmjs.org/install.sh | sh`


## Install required node.js dependencies ##

Execute `npm install`

This will install a bunch of modules as required by pacakge.json, including jade, socket.io, coffee, mocha, etc.

If you are not using nvm, you may have to add node_modules/.bin to your PATH and node_modules to your NODE_PATH
in order for the modules and their executables to be available.


## Compile coffeescript files ##

* Run `npm run-script build`
* To compile the client javascript files manually, run `coffee -w -o src/public/js -c src/client/*.coffee`
  and `find . -not -path "./node_modules*" -not -path "./test*" -not -path "./client*" -name "*coffee" |xargs coffee -w -c`


## Setup alternative name list in redis ##

* Download http://download.geonames.org/export/dump/alternateNames.zip to `/tmp` *and* unzip it there
* Download http://download.geonames.org/export/dump/admin1CodesASCII.txt to `/tmp`
* Download http://download.geonames.org/export/dump/DE.zip to `/tmp` *and* unzip it there
* `mkdir redis/dumps`
* Run production redis from the ride2go directory with redis/redis.conf (edit to match your system, keep port number)
* Run `node.io src/importers/geonames.coffee` and exit the process after you read the line "OK: Job complete"
* Run `redis-cli FLUSHDB`
* Run altname redis from the ride2go directory with redis/alt.conf (edit to match your system, keep port number)
* Run `node.io src/importers/geonames.coffee` again
* Run `redis-cli SAVE`
* Shutdown the altname redis
* Yay, you are done


## Run Tests

Run `npm run-script test` to execute all tests (cf. Cakefile to enable what gets tested)


## ride2go

* [OPTIONAL] Check RDS.coffee for the list of active conncectors
* Run

    npm run-script build
    npm run-script server

* Connect with your favorite http client that is not called Internet Explorer to localhost port 3000


## Development ##

Awhile back, we used pivotaltracker at https://www.pivotaltracker.com/projects/130935 for planning of next steps
(use [fixes #storyid] in commit messages if you want to refer to it)
