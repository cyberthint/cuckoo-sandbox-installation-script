# Cuckoo Sandbox Full Automated Installation Script

This repository contains scripts to install cuckoo with required services/packages simply.  

Basic features are:

- Only 3 steps to installation,
- Using docker for running and monitoring databases,
- Creating linux services for cuckoo, cuckoo-web and cuckoo-api,
- Simple configuration and data locations.

Tested on;

- Debian 10.8
- Debian 9.13 (Recommended)
- Ubuntu 20.4
- Ubuntu 18.4

## Installation

### Before started...

- Make sure your host virtualization is enabled.
- If you are using Virtualbox, make sure `VT-x/AMD-V` is enabled.
- Make sure host machine has min 2 CPU / 2gb RAM.
- Download this repo:

```
$ wget -O cuckoo-setup.zip https://github.com/cyberthint/cuckoo-sandbox-installation-script/archive/refs/heads/master.zip
$ unzip cuckoo-setup.zip
$ cd cuckoo-sandbox-installation-script-master/
```

### Step 1 : Run following commands as `root` user:

Make `run-as-root.sh` executable and run:

```
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

## Endpoints / Ports

There are 2 endpoints for `cuckoo-web` and `cuckoo-api`:

- `port:8000` : Cuckoo web interface port
- `port:8080` : Cuckoo api interface port

Check `Services` section for more information about **changing interface port** or **stopping services**.

## Services

There are 4 services which run at system startup:

1. `cuckoo.service` : Cuckoo base service, starting cuckoo on startup.
2. `cuckoo-docker.service` : Docker service which responsible for starting docker-compose on startup.
3. `cuckoo-web.service` : Web service which responsible for starting cuckoo web service on port 8000.
4. `cuckoo-api.service` : Api service which responsible for starting cuckoo api service on port 8080.

- All service files are in `/etc/systemd/system/` folder.
- For changing `cuckoo-web` or `cuckoo-api` ports, edit service file and restart service:

```
$ vim /etc/systemd/system/cuckoo-web.service
>>> Edit file
$ systemctl daemon-reload
$ systemctl restart cuckoo-web
```

- You can stop and disable unwanted services, and services will not start automatically at startup:

```
$ systemctl stop cuckoo-api
$ systemctl disable cuckoo-api
```

## Data Directories

There are 3 data directory:

1. `/data-elasticsearch` : Elastic Search Data Directory
2. `/data-mongo` : Mongo Db Data Directory
3. `/data-postgres` : Postresql Data Directory

This directories binded docker containers, so even if you restart docker containers, the datas still be there.

## Configuration Directories

There is 1 configuration directory:

1. `/home/cuckoo/.cuckoo/conf` : This directory contains cuckoo configurations. [More information...](https://cuckoo.sh/docs/index.html)

## Troubleshooting

### Getting hash error when creating virtualenv directory:

**THE ERROR:**  

While running `run-as-cuckoo.sh` file, getting following error:

```
ERROR: THESE PACKAGES DO NOT MATCH THE HASHES FROM THE REQUIREMENTS FILE. If you have updated the package versions, please update the hashes. Otherwise, examine the package contents carefully; someone may have tampered with them.
```

**SOLUTION 1:**  

If you are using Virtualbox for hosting main machine, Virtualbox version may be old. Check your Virtualbox machine version, and if the version is older than `r140270`, please upgrade your Virtualbox.

**SOLUTION 2:**  

It may be network configuration problem:

- Make sure your host machine connecting to internet directly. If you are using `NAT` network, change it to `Bridged Network`.
- After changing network settings, clear pip cache with following command:

```
$ rm -rf /home/cuckoo/.cache/pip
```

- Start `run-as-cuckoo.sh` script file again.

**SOLUTION 3:**  

If you are running host server over Windows 10, it may be because of auto-tuning level of you Windows network.

Check your network auto-tuning level by following command:

```
λ netsh int tcp show global

Querying active state...

TCP Global Parameters
----------------------------------------------
...
Receive Window Auto-Tuning Level    : normal
...
```

If you are getting result like that, turn auto-tuning level with following command:

```
λ netsh int tcp set global autotuninglevel=disabled
Ok.
```