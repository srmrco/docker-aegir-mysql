docker-aegir-mysql
====================

This is a Dockerfile and installation scripts to get an Aegir hosting system for Drupal up and running.

Services provided:

- Apache
- MySQL
- SSH

## How to use

- First checkout this repository. Go to the checked out repositpory and build the docker image:

```bash
$ docker build -t namespace/aegir .
```

- Customize config options from `docker_run.sh` into a new file called `config-include.sh`. 
  - Pay attention at MOUNT_POINT variable - it specifies where Docker should put shared volumes, by default it will be `/var/docker`. 
  - Also make sure to put the correct value into variables: IMAGE_NAME and INSTANCE_NAME - these names you will be using when interacting with your Aegir container in future.

- Create and run new container using:

```bash
$ ./docker_run.sh
```

If the container is executed successfully, it will configre and install Aegir and then execute all needed services under Supervisor. You can see what's happenning in the container in realtime using `docker logs -f aegir`.


## Using container

```bash
$ docker run -ti namespace/aegir bash
```

