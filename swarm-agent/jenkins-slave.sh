#!/bin/bash

set -e
echo "==> Launching the Docker daemon..."
dind docker daemon --host=unix:///var/run/docker.sock &
echo "==> Waiting for the Docker daemon to come online..."
while(! docker info > /dev/null 2>&1); do
    sleep 1
done
echo "==> Docker Daemon is up and running!"
apk add make

# if `docker run` first argument start with `-` the user is passing jenkins swarm launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "-"* ]]; then
  # jenkins swarm slave
  JAR=`ls -1 /usr/share/jenkins/swarm-client-*.jar | tail -n 1`
  # if -master is not provided and using --link jenkins:jenkins
  if [[ "$@" != *"-master "* ]] && [ ! -z "$JENKINS_TCP_ADDR" ]; then
    PARAMS="-master http://$JENKINS_TCP_ADDR:$JENKINS_TCP_PORT"
  fi
  echo "==> Running java $JAVA_OPTS -jar $JAR -fsroot $HOME $PARAMS \"$@\""
  exec java $JAVA_OPTS -jar $JAR -fsroot $HOME $PARAMS "$@"
fi

# As argument is not jenkins, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"
