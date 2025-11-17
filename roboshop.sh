#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0f5223df757c2d0ea"
INSTANCES=("mangodb" "redis" "mysql" "frontend")
ZONE_ID="Z068958217B8R8Q4GDM1O"
DOMAIN_NAME="miasha84s.site"

for instance in ${INSTANCES[@]}
do

INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-09c813fb71547fc4f \
    --instance-type t2.micro \
    --security-group-ids sg-0f5223df757c2d0ea \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=test}]" \
    --query "Instances[0].InstanceId" \
    --output text)
if [ $instance != "frontend" ]
then 
INSTANCE_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    else
    INSTANCE_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    fi
    echo "$instance ip address: $INSTANCE_IP"
done 