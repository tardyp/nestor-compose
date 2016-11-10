# Nestor in one(ish) command

This is docker compose config which deploy the whole Nestor stack in a docker development environment.

This is meant as an easy development environment as well as a working reference on how components are bound together.

Note that you need `docker-compose` 1.6.0 or newer:

* https://github.com/docker/compose

## Mesos Compatibility

Mesos containers requires host networking to work, so docker for mac won't work for mesos.
As Nestor can use docker latent workers, this is fine.

If you have docker built dynamically, which is the case on most distros,
you should download and bind-mount statically linked docker client:

```
curl -sL https://get.docker.com/builds/Linux/x86_64/docker-1.11.1.tgz | \
  tar xv --strip-components 1 -C /usr/local/bin
```

This downloads docker 1.11.1 and installs binaries into `/usr/local/bin`.

## ZKIE requirement

zkie is a zookeeper commandline utility to manage the zookeeper configuration

    sudo pip install zkie ansible

## Usage

Services are linked together so that you only need to start the service you need, and the other should also start.
This is not true yet for the zookeeper, as there is no way yet to automatically provision the zookeper configuration.
So we need to start and configure zookeeper first

### Start and provision Zookeper:

    ./provision.py


### Start Gerrit:

    docker compose up -d gerrit

### Go the various UI

* Logtrail: <http://localhost:5601/app/logtrail>

* Gerrit: <http://localhost:8022/#/dashboard/self>
