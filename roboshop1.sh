#!/bin/bash


AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0f5223df757c2d0ea"
INSTANCES=("mangodb")
ZONE_ID="Z068958217B8R8Q4GDM1O"
DOMAIN_NAME="miasha84s.site"

for instance in "${INSTANCES[@]}"
do
  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query "Instances[0].InstanceId" \
    --output text)

  # Wait until instance is running
  aws ec2 wait instance-running --instance-ids $INSTANCE_ID

  if [ "$instance" != "frontend" ]; then
    INSTANCE_IP=$(aws ec2 describe-instances \
      --instance-ids $INSTANCE_ID \
      --query "Reservations[0].Instances[0].PrivateIpAddress" \
      --output text)
  else
    INSTANCE_IP=$(aws ec2 describe-instances \
      --instance-ids $INSTANCE_ID \
      --query "Reservations[0].Instances[0].PublicIpAddress" \
      --output text)
  fi

  echo "$instance ip address: $INSTANCE_IP"
done