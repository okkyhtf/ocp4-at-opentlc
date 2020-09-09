#!/bin/env bash

# Make sure you setup these ENV variables
export AWSKEY=
export AWSSECRETKEY=
export REGION=ap-southeast-1
export OCP_VERSION=4.5.7
export GUID=

set -xe

# Download and extract the latest AWS Command Line Interface
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"

# Extract downloaded AWS Command Line Interface archive file
unzip ./awscli-bundle.zip

# Install the AWS CLI into /bin/aws
./awscli-bundle/install -i /usr/local/aws -b /bin/aws

# Validate that the AWS CLI works
aws --version

# Cleanup downloaded files
rm -rf ./awscli-bundle ./awscli-bundle.zip

# Configure AWS credentials
mkdir $HOME/.aws

cat <<EOF >>$HOME/.aws/credentials
[default]
aws_access_key_id = ${AWSKEY}
aws_secret_access_key = ${AWSSECRETKEY}
region = $REGION
EOF

# Validate AWS credentials
aws sts get-caller-identity

# Generate SSH keypair for OpenShift cluster
ssh-keygen -f ~/.ssh/cluster-${GUID}-key -N ''

# Download OpenShift 4 Installer binary
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_VERSION}/openshift-install-linux-${OCP_VERSION}.tar.gz
tar zxvf openshift-install-linux-${OCP_VERSION}.tar.gz -C /usr/bin
rm -f openshift-install-linux-${OCP_VERSION}.tar.gz /usr/bin/README.md
chmod +x /usr/bin/openshift-install

# Download OpenShift 4 Client binaries
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_VERSION}/openshift-client-linux-${OCP_VERSION}.tar.gz
tar zxvf openshift-client-linux-${OCP_VERSION}.tar.gz -C /usr/bin
rm -f openshift-client-linux-${OCP_VERSION}.tar.gz /usr/bin/README.md
chmod +x /usr/bin/oc

# CHeck that the OpenShift Installer
ls -l /usr/bin/{oc,openshift-install}

# Setup OpenShift Client Bash completion
oc completion bash >/etc/bash_completion.d/openshift

# Relogout to reinitialize Bash profile
echo "Please exit the session and relogin again to enable the Bash completion."
