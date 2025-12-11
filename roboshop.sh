#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-074bbf13eb04da445"
#INSTANCES=("mangodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
INSTANCES=("mangodb"  "frontend")
ZONE_ID="Z03411543BSLBE0GBV4TS"
DOMAIN_NAME="miasha84s.site"

for instance in "${INSTANCES[@]}"
do
  # Launch instance and capture ID
  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-09c813fb71547fc4f \
    --instance-type t3.micro \
    --security-group-ids sg-074bbf13eb04da445 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query "Instances[0].InstanceId" \
    --output text)
for instance in "${INSTANCES[@]}"
do
  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-09c813fb71547fc4f \
    --instance-type t3.micro \
    --security-group-ids sg-074bbf13eb04da445 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query "Instances[0].InstanceId" \
    --output text)

  # Wait until instance is running
  aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

  if [ "$instance" != "frontend" ]; then
    INSTANCE_IP=$(aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --query "Reservations[0].Instances[0].PrivateIpAddress" \
      --output text)
    RECORD_NAME="$instance.$DOMAIN_NAME"
  else
    INSTANCE_IP=$(aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --query "Reservations[0].Instances[0].PublicIpAddress" \
      --output text)
    RECORD_NAME="$DOMAIN_NAME"
  fi

  echo "$instance IP address: $INSTANCE_IP"

  aws route53 change-resource-record-sets \
    --hosted-zone-id "$ZONE_ID" \
    --change-batch "{
      \"Comment\": \"Creating or Updating a record set for $instance\",
      \"Changes\": [{
        \"Action\": \"UPSERT\",
        \"ResourceRecordSet\": {
          \"Name\": \"$RECORD_NAME\",
          \"Type\": \"A\",
          \"TTL\": 300,
          \"ResourceRecords\": [{\"Value\": \"$INSTANCE_IP\"}]
        }
      }]
    }"
    
done