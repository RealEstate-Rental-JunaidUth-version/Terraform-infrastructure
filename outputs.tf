output "cluster_name" {
  description = "Name of the deployed Amazon EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for the Amazon EKS API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the Amazon EKS control plane"
  value       = module.eks.cluster_security_group_id
}

output "vpc_id" {
  description = "ID of the VPC created for the cluster"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs where EKS worker nodes run"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs for external load balancers"
  value       = module.vpc.public_subnets
}

output "configure_kubectl" {
  description = "Command to authenticate your local kubectl with the EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
