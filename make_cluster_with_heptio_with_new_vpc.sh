#!/bin/bash
if [ -z "${CLUSTER_ID}" ]; then
    echo "CLUSTER_ID must be set"
    exit 1
fi

if [ -z "${AVAILABILITY_ZONE}" ]; then
    echo "AVAILABILIT_ZONE must be set"
    exit 1
fi

BASTION_INSTANCE_TYPE=${BASTION_INSTANCE_TYPE:-t2.micro}
NODE_INSTANCE_TYPE=${NODE_INSTANCE_TYPE:-m4.large}
DISK_SIZE_GB=${DISK_SIZE_GB:-100}
SSH_LOCATION=${SSH_LOCATION:-0.0.0.0/0}
K8S_NODE_CAPACITY=${K8S_NODE_CAPACITY:-1}

KEYFILE=$(mktemp)
aws ec2 create-key-pair --key-name "${CLUSTER_ID}Key" --query 'KeyMaterial' --output text >> ${KEYFILE}

cat ${KEYFILE} >> ./${CLUSTER_ID}Key.pem
chmod 400 ./${CLUSTER_ID}Key.pem

CREATED=$(mktemp)
aws cloudformation create-stack --stack-name ${CLUSTER_ID} --template-url https://heptio-aws-quickstart-test.s3.amazonaws.com/heptio/kubernetes/master/templates/kubernetes-cluster-with-new-vpc.template --capabilities CAPABILITY_IAM \
    --parameters \
    ParameterKey=AdminIngressLocation,ParameterValue="${SSH_LOCATION}" \
    ParameterKey=AvailabilityZone,ParameterValue="${AVAILABILITY_ZONE}" \
    ParameterKey=ClusterDNSProvider,ParameterValue="CoreDNS" \
    ParameterKey=BastionInstanceType,ParameterValue="${BASTION_INSTANCE_TYPE}" \
    ParameterKey=DiskSizeGb,ParameterValue="${DISK_SIZE_GB}" \
    ParameterKey=InstanceType,ParameterValue="${NODE_INSTANCE_TYPE}" \
    ParameterKey=K8sNodeCapacity,ParameterValue="${K8S_NODE_CAPACITY}" \
    ParameterKey=KeyName,ParameterValue="${CLUSTER_ID}Key" \
    ParameterKey=NetworkingProvider,ParameterValue="calico" \
    ParameterKey=QSS3BucketName,ParameterValue="aws-quickstart" \
    ParameterKey=QSS3KeyPrefix,ParameterValue="quickstart-heptio/" | tee ${CREATED}
