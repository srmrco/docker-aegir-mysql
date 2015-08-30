FROM ubuntu:12.04
MAINTAINER Dominic Böttger "http://inspirationlabs.com" 

# set user
ENV MYSQL_USER mysql
# define database directory for start-script
ENV DATADIR /var/lib/mysql

# set installation parameters to prevent the installation script from asking
RUN echo "mysql-server-5.5 mysql-server/root_password password $MYSQL_ROOT_PW" | debconf-set-selections
RUN echo "mysql-server-5.5 mysql-server/root_password_again password $MYSQL_ROOT_PW" | debconf-set-selections

RUN apt-get update
RUN apt-get -y install wget python-software-properties software-properties-common
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -y install vim mc openssh-server supervisor apache2 php5 php5-cli php5-gd php5-mysql php-pear sudo rsync git-core unzip mysql-server-5.5 mysql-client

ADD dpkg_selection.conf /tmp/dpkg_selection.conf

# Set a suid bit on sudo, somehow this base image has it disabled.
# Required to let Aegir reload apache.
RUN chmod u+s /usr/bin/sudo

# allow access from any IP
RUN sed -i '/^bind-address*/ s/127.0.0.1/0.0.0.0/' /etc/mysql/my.cnf
RUN mkdir -p $DATADIR
RUN sed -i "/^datadir*/ s|=.*|= $DATADIR|" /etc/mysql/my.cnf

# Aegir 1.x supports Drush 4.x only
RUN pear channel-discover pear.drush.org
RUN pear install drush/drush-4.6.0
RUN pear install Console_Table

ADD run.sh /
ADD create_db.sh /
ADD aegir_install.sh /
ADD supervisor.conf /opt/supervisor.conf

EXPOSE 80
VOLUME ["/var/aegir", "/var/lib/mysql"]
CMD ["/run.sh"]