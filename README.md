# Cuckoo Sandbox Full Automated Installation Script

This repository contains scripts to install cuckoo with required services/packages simply.  

Basic features are:

- Only 3 steps to installation,
- Using docker for running and monitoring databases,
- Creating linux services for cuckoo, cuckoo-web and cuckoo-api,
- Simple configuration and data locations.

Tested on;

- Debian 10.8
- Ubuntu 20.04

## Installation

### Step 1 : Run following commands as `root` user:

Make `run-as-root.sh` executable and run:

```
$ cd path/to/cuckoo-setup
$ chmod a+x run-as-root.sh
$ ./run-as-root.sh
```

This script file will make this changes:

- Update & upgrade apt packages
- Install neccessary packages for cuckoo
- Download docker & docker-compose
- Make neccessary settings
- Create `cuckoo` user and add it to groups
- Install `win7ultimate` image for using Virtualbox
- Install Virtualbox
- Setting up Virtualbox network
- Start `mongodb`, `postgesql`, `elasticsearch` with docker-compose
- Move `run-as-cuckoo.sh` file to cuckoo user home directory

Notes:

- The docker-compose file for managing `mongodb`, `postgesql`, `elasticsearch` will be at `/start-cuckoo-services.yml`. If there is something wrong with this services, please go to check docker services with this command: `docker-compose -f /start-cuckoo-services.yml logs -f`

### Step 2 : Run following commands as `cuckoo` user:

Change user to `cuckoo` and make `run-as-cuckoo.sh` run. This script file will be in `/home/cuckoo/`.  

> **Note:** There are 2 default configuration in `run-as-cuckoo.sh` file.
> 1. Default guest machines are created as 2 cpus and 2048 mb ram, if you want to change that settings, go to line `vmcloak init --verbose --win7x64 win7x64base --cpus 2 --ramsize 2048` and change values.
> 2. This script creates 4 guest machines as default. If you want more or less machines, go to line `vmcloak snapshot --count 4 win7x64cuckoo cuckoo 192.168.56.101` and change `--count` value. Beside that, **before** running script file, go to `/home/cuckoo/conf/virtualbox.conf` and change and edit machines. After running scripts, this configuration files will moved to `/home/cuckoo/.cuckoo/conf` and deleted from `/home/cuckoo/conf`.

```
$ su - cuckoo
$ cd ~
$ ./run-as-cuckoo.sh
```

### Step 3 : Restart your server.

After restarting server, all services must be started. Check for "Services" part for more information.

## Where is Cuckoo?

Cuckoo is installed in python virtualenv folder which is at `/home/cuckoo/cuckoo`. If you want to start cuckoo manually, activate virtualenv and start cuckoo:

```
$ source /home/cuckoo/cuckoo/bin/activate
$ cuckoo
```

## Services

There are 4 services which run at system startup:

1. `cuckoo.service` : Cuckoo base service, starting cuckoo on startup.
2. `cuckoo-docker.service` : Docker service which responsible for starting docker-compose on startup.
3. `cuckoo-web.service` : Web service which responsible for starting cuckoo web service on port 8000.
4. `cuckoo-api.service` : Api service which responsible for starting cuckoo api service on port 8080.

All service files are in `/etc/systemd/system/` folder.

## Data Directories

There are 3 data directory:

1. `/data-elasticsearch` : Elastic Search Data Directory
2. `/data-mongo` : Mongo Db Data Directory
3. `/data-postgres` : Postresql Data Directory

This directories binded docker containers, so even if you restart docker containers, the datas still be there.

## Configuration Directories

There is 1 configuration directory:

1. `/home/cuckoo/.cuckoo/conf` : This directory contains cuckoo configurations. [More information...](https://cuckoo.sh/docs/index.html)