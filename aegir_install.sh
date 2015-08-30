#!/bin/bash

if drush help | grep "^ provision-install" > /dev/null ; then
  echo "INFO: Provision already seems to be installed"
else 
  drush dl --yes --destination=/var/aegir/.drush provision-$AEGIR_VERSION
fi

if [ -e "/var/aegir/.drush/hostmaster.alias.drushrc.php" ] ; then
  echo "Hostmaster already installed"
else 
  # install Aegir
  OPTIONS="--yes --debug --aegir_host=$AEGIR_SITE --aegir_db_host=localhost --aegir_db_user=aegir_root --aegir_db_pass=$AEGIR_DB_PASSWORD --version=$AEGIR_VERSION  --client_email=$AEGIR_EMAIL --script_user=aegir --http_service_type=apache $AEGIR_FRONTEND_URL"
  echo $OPTIONS
  
  drush hostmaster-install $OPTIONS

  # install Hosting queue runner as a daemon under supervisor
  drush @hostmaster dl --yes hosting_queue_runner
  drush @hostmaster pm-enable -y hosting_queue_runner
  cp /var/aegir/hostmaster-$AEGIR_VERSION/sites/all/modules/hosting_queue_runner/hosting_queue_runner.sh /var/aegir/
  cp /var/aegir/hostmaster-$AEGIR_VERSION/sites/all/modules/hosting_queue_runner/hosting_queue_runner.conf /var/aegir/

  drush @hostmaster pm-enable -y dblog
fi