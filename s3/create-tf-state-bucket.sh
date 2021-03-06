#!/usr/bin/env bash

set -ex

BUCKET_NAME=automatictester-co-uk-aws-exp
REGION=eu-west-1

aws s3api create-bucket \
   --bucket ${BUCKET_NAME} \
   --acl private \
   --region ${REGION} \
   --create-bucket-configuration LocationConstraint=${REGION}

aws s3api put-public-access-block \
   --bucket ${BUCKET_NAME} \
   --public-access-block-configuration '{"BlockPublicAcls":true,"IgnorePublicAcls":true,"BlockPublicPolicy":true,"RestrictPublicBuckets":true}'
