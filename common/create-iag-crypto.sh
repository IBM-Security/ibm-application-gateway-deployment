#!/bin/bash

# Get directory for this script
RUNDIR="`dirname \"$0\"`"         # relative
RUNDIR="`( cd \"$RUNDIR\" && pwd )`"  # absolutized and normalized
if [ -z "$RUNDIR" ] ; then
  echo "Failed to get local path"
  exit 1  # fail
fi

# Enter directory of script (/common)
cd ${RUNDIR}

# Create a new RSA keypair and create self-signed x509 cert.
openssl req -newkey rsa -nodes -config iag_cert_config -x509 -out iag.cert.pem -days 730

# Concatenate the public cert and private key into iag.certkey.pem in secret_files directory
# This directory will be mounted to the IAG container
cat iag.cert.pem iag.key.pem > secret_files/iag.certkey.pem

# Remove the individual files - they are not required
rm iag.key.pem
rm iag.cert.pem

# Generate a 64 byte (512 bit) failover key and store in secret_files as iag.failover.key
openssl rand -out secret_files/iag.failover.key 64
