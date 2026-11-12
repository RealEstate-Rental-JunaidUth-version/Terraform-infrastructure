variable "aws_region" {
  description = "AWS region to deploy infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "realestate-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for VPC subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks for EKS worker nodes"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks for load balancers"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "cluster_name" {
  description = "Name of the Amazon EKS cluster"
  type        = string
  default     = "realestate-test-cluster"
}

variable "cluster_version" {
  description = "Kubernetes control plane version"
  type        = string
  default     = "1.31"
}

variable "node_instance_types" {
  description = "EC2 instance types for the EKS managed node group"
  type        = list(string)
  default     = ["m7i-flex.large"]
}

variable "node_capacity_type" {
  description = "Capacity type for worker nodes (e.g. SPOT, ON_DEMAND)"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_min_size" {
  description = "Minimum number of nodes in managed node group"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of nodes in managed node group"
  type        = number
  default     = 1
}

variable "node_desired_size" {
  description = "Desired number of nodes in managed node group"
  type        = number
  default     = 1
}
