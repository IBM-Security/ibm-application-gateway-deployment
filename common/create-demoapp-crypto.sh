#!/bin/bash

# Get directory for this script
RUNDIR="`dirname \"$0\"`"         # relative
RUNDIR="`( cd \"$RUNDIR\" && pwd )`"  # absolutized and normalized
if [ -z "$RUNDIR" ] ; then
  echo "Failed to get local path"
  exit 1  # fail
fi

# Enter the demoapp directory
cd ${RUNDIR}/demoapp

# Create a new RSA keypair and create self-signed x509 cert.
openssl req -newkey rsa -nodes -config ../demoapp_cert_config -x509 -out demoapp.cert.pem -days 730

# Copy the certificate to env_files (so IAG will receive it as a file)
cp ${RUNDIR}/demoapp/demoapp.cert.pem ${RUNDIR}/env_files
