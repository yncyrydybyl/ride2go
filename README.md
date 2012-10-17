INSTALLATION
============


## Install node.js and npm ##

* Consult package.json to determine the required version of node.js and proceed with (A) or (B)

** (A) Install nvm from https://github.com/creationix/nvm and execute

         VERSION=v`fgrep '"node"' package.json | cut -d\" -f4`
         nvm install $VERSION
         nvm use $VERSION

** (B) Install node.js manually, following the steps described at
       https://github.com/joyent/node/wiki/Installation and install npm
       by executing `curl http://npmjs.org/install.sh | sh`


## Install required node.js dependencies ##

* Install redis (>= 2.2.12) from http://redis.io/download
* Execute `npm install`. This will install a bunch of modules as required by package.json, including jade, socket.io, coffee, mocha, etc.


If you are not using nvm, you may have to add node_modules/.bin to your PATH and node_modules to your NODE_PATH
in order for the modules and their executables to be available.


## Install bower and required brower components ##

* Just for this step, install and use a second node.js with a version >= 0.8 via

    nvm install v0.8.12
    nvm use v0.8.12

* Install bower

    npm -g install bower

* Install bower components

    bower install

* Switch back to the regular node.js via `nvm use $VERSION`


## Compile coffeescript files ##

* Run `npm run-script build`


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


## Prepare the connectors you want to use

* Edit `src/connectors/index.coffee` to enable specific connectors.  Consult comments in each connector's
  top-level source file for advice on how to set them up properly. For some connectors, this is explained below

### deinbus

Execute `node_modules/.bin/node.io lib/connectors/deinbus.js`

### public-transport-enabler

* Get PTS
* Edit ConnectionController.java and LocationController.java to set the PTE NetworkProvider that should be used
* Build PTS
* Run PTS by executing in `service`: `mvn org.codehaus.cargo:cargo-maven2-plugin:run`
* Edit `connectors/pts.coffee` to match your setup


## Run Tests

Run `npm run-script test` to execute all tests (requires running production redis).

Edit `test/active-tests.js` to enable what gets tested (especially which connectors you want to test, note that
this may require connector preparation as described before).


## Setup and run ride2go service

* [OPTIONAL] Check RDS.coffee for the list of active conncectors
* Run

    npm run-script build
    npm run-script start

* Connect with your favorite http client that is not called Internet Explorer to localhost port 3000


## Development ##

* We recommend you to

    npm install -g node-inspector
    npm install -g yuidocjs
    npm install -g forever

* Awhile back, we used pivotaltracker at https://www.pivotaltracker.com/projects/130935 for planning of next steps
(use [fixes #storyid] in commit messages if you want to refer to it)


### Debugging using node-inspector ###

Let's say you need to debug a mocha test

* First, add a `debugger;` statement wherever you need a breakpoint
* Second, run `node-inspector` (perhaps using `forever $(which node-inspector)` to avoid restarting the inspector)
* Third, run mocha using

    cake build && cake -M --debug-brk -M -t -M 2000000 test

  This halts on the first line and bumps up all mocha timeouts towards infinity

* Fourth, point a webkit-based browser to the url given by node-inspector
* Fifth, hit 'continue' in the debugger
* Finally the debugger should arrive at your first breakpoint. Refresh the browser window in oder for your actual
  javascript code to be available and start debugging.



