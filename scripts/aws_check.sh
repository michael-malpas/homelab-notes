#!/bin/bash

aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`]|[0].Value,InstanceId,State.Name]' \
  --output table
