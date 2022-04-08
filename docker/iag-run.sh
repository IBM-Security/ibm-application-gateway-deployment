#!/bin/bash

if [ $# -ne 2 ];then
  echo "Usage: ${0} <config dir> <publish_host:port>"
  exit 1
fi

# Get directory for this script
RUNDIR="`dirname \"$0\"`"         # relative
RUNDIR="`( cd \"$RUNDIR/..\" && pwd )`"  # absolutized and normalized
if [ -z "$RUNDIR" ]; then
  echo "Failed to get local path"
  exit 1  # fail
fi

# Get absolute config directory
CONFIGDIR="`( cd \"$1\" && pwd )`"  # absolutized and normalized
if [ -z "$CONFIGDIR" ]; then
  echo "Failed to get config directory"
  exit 1  # fail
fi

# Check for existance of common/config.properties
if [ ! -f ${RUNDIR}/common/config.properties ];then
  echo "Couldn't find ${RUNDIR}/common/config.properties"
  exit 1 #Fail
fi

# Check for existance of src directory in provided config directory
if [ ! -d ${CONFIGDIR}/src/ ];then
  echo "Couldn't find directory ${CONFIGDIR}/src/"
  exit 1 #Fail
fi

# Check for existance of crypo files and call creation script if not found
if [ ! -f "$RUNDIR/common/secret_files/iag.certkey.pem" ]
then
        echo "Keys not generated yet; calling creation script..."
        $RUNDIR/common/create-iag-crypto.sh
fi

# Get the name of config directory
CONFIG_NAME=`basename ${CONFIGDIR}`

# Get name of config directory appended with random number
MOUNT_NAME=${CONFIG_NAME}-$RANDOM

# Create mount directory (with random name)
mkdir -p ${RUNDIR}/docker/mounts/${MOUNT_NAME}

# Copy all files from src directory to mount directory
cp -R ${CONFIGDIR}/src/* ${RUNDIR}/docker/mounts/${MOUNT_NAME}

# Silently delete existing container for same configuration
docker rm -f iag-${CONFIG_NAME} > /dev/null 2>&1

# Run a new container.  Mount directory and set environment.
docker run -d --name iag-${CONFIG_NAME} \
  -v ${RUNDIR}/docker/mounts/${MOUNT_NAME}/:/var/iag/config/ \
  -v ${RUNDIR}/common/secret_files:/var/iag/config/secret_files \
  -v ${RUNDIR}/common/env_files:/var/iag/config/env_files \
  --env-file=${RUNDIR}/common/config.properties \
  -p ${2}:8443 \
  ibmcom/ibm-application-gateway:21.12

# If container started, tail the log
if [ $? -eq 0 ];then
  echo "Logs for container... Ctrl-c will not terminate container."
  docker logs -f iag-${CONFIG_NAME}
fi
