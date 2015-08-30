#!/bin/bash
# needed variables:
# AEGIR_SITE
# AEGIR_EMAIL
# AEGIR_DB_PASSWORD
# AEGIR_VERSION


# Start ssh early to be able to login for debugging.
service openssh-server start

echo "Install mysql:"

MYSQL="/usr/bin/mysqld_safe"
MYSQL_ADMIN="/usr/bin/mysqladmin"
INITDB="/usr/bin/mysql_install_db"
DATADIR="/var/lib/mysql"

chown -R mysql:mysql /var/log/mysql

# test if DATADIR is existent
if [ ! -d $DATADIR ]; then
  echo "Creating MySQL data at $DATADIR"
  mkdir -p $DATADIR
fi

# test if DATADIR has content
if [ ! "$(ls -A $DATADIR)" ]; then
  echo "Initializing MySQL Database at $DATADIR"
  chown -R mysql:mysql $DATADIR
	chmod 700 $DATADIR
  $INITDB --user=mysql --ldata=$DATADIR

  echo "starting MySQL server..."
  /usr/bin/mysqld_safe &
  MYSQL_PID=$!
  sleep 6

  # Finally, grant access to off-container connections
  GRANT="GRANT ALL PRIVILEGES ON *.* to root@'%' IDENTIFIED BY '${MYSQL_ROOT_PW}' WITH GRANT OPTION;\
  		UPDATE user SET Password=PASSWORD('$MYSQL_ROOT_PW') WHERE User='root';\
       	FLUSH PRIVILEGES;"
  echo "$GRANT" | mysql -u root mysql

  echo "server running."
else
  echo "starting MySQL server..."
  /usr/bin/mysqld_safe &
  MYSQL_PID=$!
  sleep 6
fi

echo "init aegir"
if [ -e "/root/installed" ] ; then
	echo "Host already installed"
else 
	GRANT="GRANT ALL PRIVILEGES ON *.* TO 'aegir_root'@'%' IDENTIFIED BY '${AEGIR_DB_PASSWORD}' WITH GRANT OPTION;\
	       FLUSH PRIVILEGES;"
	echo "$GRANT" | mysql -u root -h localhost -p$MYSQL_ROOT_PW

	debconf-set-selections /tmp/dpkg_selection.conf
	# set installation parameters to prevent the installation script from asking
	echo "postfix postfix/relayhost string " | debconf-set-selections
	echo "postfix postfix/mailname string $POSTFIX_MAILNAME" | debconf-set-selections
	echo "postfix postfix/destinations string $POSTFIX_DESTINATION, localhost.localdomain, localhost" | debconf-set-selections
	apt-get -y install postfix
	
	adduser --system --group --home /var/aegir aegir
	adduser aegir www-data    #make aegir a user of group www-data
	chsh aegir -s /bin/bash

	chown -R www-data:www-data /var/log/apache2
	chown -R aegir:www-data /var/aegir

	phpmemory_limit=256M #or what ever you want it set to
	sed -i 's/memory_limit = .*/memory_limit = '${phpmemory_limit}'/' /etc/php5/apache2/php.ini

	a2enmod rewrite

	echo -e "Defaults:aegir  !requiretty\naegir ALL=NOPASSWD: /usr/sbin/apache2ctl" >> /etc/sudoers.d/aegir
	chmod 0440 /etc/sudoers.d/aegir

  mkdir -p /var/aegir/drush
  chown aegir:aegir /var/aegir/drush
  ln -s /usr/bin/drush /var/aegir/drush/drush
	ln -s /var/aegir/drush/drush /usr/local/bin/drush

  # some of my older drush extensions expect drush commands to be in there:
  mkdir -p /usr/share/drush/commands
  ln -s /var/aegir/.drush/provision /usr/share/drush/commands/provision

  # This is where Aegir is installed
  echo "Starting Aegir install script..."
	su -s /bin/bash aegir -c "bash /aegir_install.sh"
  echo "Aegir install script finished."

  # make sure apache knows about Aegir's config
  ln -s /var/aegir/config/apache.conf /etc/apache2/conf.d/aegir.conf

	touch /root/installed

	# Stop apache, supervisor will start it later and keep it running.
	apache2ctl stop

  echo "Installing hosting_queue_runner daemon..."
  cp /var/aegir/hosting_queue_runner.conf /etc/supervisor/conf.d/
  chown aegir:aegir /var/aegir/hosting_queue_runner.sh
  chmod 700 /var/aegir/hosting_queue_runner.sh
  echo "Hosting_queue_runner installed"
fi

# Stop these, supervisor will start them later and keep them running.
mysqladmin -p$MYSQL_ROOT_PW shutdown
/etc/init.d/postfix stop

echo "Starting supervisor..."
supervisord -c /opt/supervisor.conf -n