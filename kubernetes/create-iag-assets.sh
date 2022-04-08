#!/bin/bash

# Get directory for this script
RUNDIR="`dirname \"$0\"`"         # relative
RUNDIR="`( cd \"$RUNDIR/..\" && pwd )`"  # absolutized and normalized
if [ -z "$RUNDIR" ] ; then
  echo "Failed to get local path"
  exit 1  # fail
fi

if [ ! -f "$RUNDIR/common/secret_files/iag.certkey.pem" ]
then
        echo "Keys not generated yet; calling creation script..."
        $RUNDIR/common/create-iag-crypto.sh
fi

echo "Deleting iag Secret (if it exists)"
kubectl delete secret iag > /dev/null 2>&1
echo "Creating new iag Secret from common/secret_files"
kubectl create secret generic iag --from-file=${RUNDIR}/common/secret_files/
echo "Deleting iag ConfigMap (if it exists)"
kubectl delete configmap iag > /dev/null 2>&1
echo "Creating new iag ConfigMap from common/env_files"
kubectl create configmap iag --from-file=${RUNDIR}/common/env_files/

if [ -f ${RUNDIR}/common/config.properties ]; then
  echo "Processing common/config.properties"
  while IFS= read -r line; do
    if [[ ! ${line} =~ ^[[:space:]]*#.* ]]; then
      if [[ ${line} =~ ^.*=.* ]]; then
        key="$( cut -d '=' -f 1 <<< "${line}")"
        value="$( cut -d '=' -f 2- <<< "${line}")"
        if [[ ${key} == S_* ]]; then
          echo "Adding ${key} to Secret"
          b64value=`echo -n ${value} | base64`
          kubectl patch secret iag -p "{\"data\":{\"${key}\":\"${b64value}\"}}"
        else
          echo "Adding ${key} to ConfigMap"
          kubectl patch configmap iag -p "{\"data\":{\"${key}\":\"${value}\"}}"
        fi
      fi
    fi
  done < ${RUNDIR}/common/config.properties
fi
