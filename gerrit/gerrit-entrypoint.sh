#!/usr/bin/env sh
set -e

#Initialize gerrit if gerrit site dir is empty.
#This is necessary when gerrit site is in a volume.
if [ "$1" = "/gerrit-start.sh" ]; then
  # If you're mounting ${GERRIT_SITE} to your host, you this will default to root.
  # This obviously ensures the permissions are set correctly for when gerrit starts.
  #chown -R ${GERRIT_USER} "${GERRIT_SITE}"

  if [ -z "$(ls -A "$GERRIT_SITE")" ]; then
    echo "First time initialize gerrit..."
    gosu ${GERRIT_USER} java -jar "${GERRIT_WAR}" init --batch --no-auto-start -d "${GERRIT_SITE}" ${GERRIT_INIT_ARGS}
    #All git repositories must be removed when database is set as postgres or mysql
    #in order to be recreated at the secondary init below.
    #Or an execption will be thrown on secondary init.
    [ ${#DATABASE_TYPE} -gt 0 ] && rm -rf "${GERRIT_SITE}/git"
  fi
  zk get --out  "${GERRIT_SITE}/etc/gerrit.config" ${ZK_GERRIT_CONFIG}
  zk get --out  "${GERRIT_SITE}/etc/secure.config" ${ZK_SECURE_CONFIG}

  # Install external plugins
  for PLUGIN in kafka-events lfs verify-status wip zuul
  do
    gosu ${GERRIT_USER} cp -f ${GERRIT_HOME}/${PLUGIN}.jar ${GERRIT_SITE}/plugins/${PLUGIN}.jar
  done

  # Install the Bouncy Castle
  gosu ${GERRIT_USER} cp -f ${GERRIT_HOME}/bcprov-jdk15on-${BOUNCY_CASTLE_VERSION}.jar ${GERRIT_SITE}/lib/bcprov-jdk15on-${BOUNCY_CASTLE_VERSION}.jar

  echo "Upgrading gerrit..."
  gosu ${GERRIT_USER} java -jar "${GERRIT_WAR}" init --batch -d "${GERRIT_SITE}" ${GERRIT_INIT_ARGS}
  if [ $? -eq 0 ]; then
    echo "Reindexing..."
    gosu ${GERRIT_USER} java -jar "${GERRIT_WAR}" reindex -d "${GERRIT_SITE}"
    echo "Upgrading is OK."
  else
    echo "Something wrong..."
    cat "${GERRIT_SITE}/logs/error_log"
  fi
fi
exec "$@"
