docker-aegir-mariadb
====================

This is a Dockerfile and installations scripts to get a Aegir hosting system for Drupal up and running.

Services provided:

- Apache
- MariaDB
- Solr / Tomcat
- SSH

## How to use

First checkout this branch. Then go to the directory and build the docker image.

docker build -t namespace/aegir_maria .

After the successful build we can run a container instance. We are sharing multiple volumes with our host system.

1. /var/aegir
2. /var/log/apache2
3. /var/lib/mysql
4. /etc/mysql/conf.d
5. /var/log/mysql
6. /usr/share/solr4

We are creating these volumes in a directory named with the name of our new instance und /var/docker. For example /var/docker/aegir01/var/aegir. 

### Run the container

After the container has been built we can run it. In the run command we add passwords, domain, hostname, version information, port mappings and file system volume mappings.

The full run command in scripted in docker_run.sh

The database passwords can be changed by adding a file called config-include.sh, which includes the updated config lines from docker_run.sh.


### Solr search

I added the Solr search engine to the container. In my configuration there are two running core with the latest schema version of search Search API Solr search (https://drupal.org/project/search_api_solr)

### Additional information

I wrote a little article on our website about the creation of the Dockerfile and where i failed with some expectations about Docker. The article can be found on http://inspirationlabs.com/blog/docker-and-aegir-hosting-system.
