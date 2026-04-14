#!/bin/bash
VPC_ID="vpc-07838552e3cd7099f"

# Eliminar cluster EKS
aws eks delete-cluster --name eks-platform-cluster

# Eliminar NAT Gateways
for nat in $(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" --query "NatGateways[?State=='available'].NatGatewayId" --output text); do
  aws ec2 delete-nat-gateway --nat-gateway-id $nat
  echo "Eliminando NAT: $nat"
done

echo "Esperando que los NAT se eliminen..."
sleep 60

# Liberar Elastic IPs
for eip in $(aws ec2 describe-addresses --query "Addresses[?AssociationId==null].AllocationId" --output text); do
  aws ec2 release-address --allocation-id $eip
  echo "Liberando EIP: $eip"
done

# Eliminar subnets
for subnet in $(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[*].SubnetId" --output text); do
  aws ec2 delete-subnet --subnet-id $subnet
  echo "Eliminando subnet: $subnet"
done

# Eliminar IGW
for igw in $(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query "InternetGateways[*].InternetGatewayId" --output text); do
  aws ec2 detach-internet-gateway --internet-gateway-id $igw --vpc-id $VPC_ID
  aws ec2 delete-internet-gateway --internet-gateway-id $igw
  echo "Eliminando IGW: $igw"
done

# Eliminar route tables
for rt in $(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[?Associations[0].Main!=\`true\`].RouteTableId" --output text); do
  aws ec2 delete-route-table --route-table-id $rt
  echo "Eliminando RT: $rt"
done

# Eliminar VPC
aws ec2 delete-vpc --vpc-id $VPC_ID
echo "VPC eliminada"
