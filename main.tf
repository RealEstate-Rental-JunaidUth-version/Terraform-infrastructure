# Create a VPC for the EKS Cluster.
# We use a single NAT Gateway to save costs!
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true # Huge money saver: only 1 NAT Gateway!
  one_nat_gateway_per_az = false

  # Required tags for Kubernetes AWS Load Balancer discovery
  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  # Public access so we can connect to it easily from local machine
  cluster_endpoint_public_access = true

  # AWS EBS CSI Driver addon for dynamic PVC provisioning (MySQL & Kafka)
  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    # 1. Exactly 1 node to save money.
    # 2. SPOT instance for ~70% discount (~$0.05/hr).
    # 3. t3.xlarge (4 vCPU, 16GB RAM) to accommodate all 28 pods smoothly.
    cheap_spot_nodes = {
      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      # Free Tier eligible instance (2 vCPU, 8 GiB Memory)
      instance_types = var.node_instance_types
      capacity_type  = var.node_capacity_type
      ami_type       = "AL2023_x86_64_STANDARD"

      # Attach EBS CSI Driver IAM policy so the node can provision EBS volumes
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
    }
  }

  enable_cluster_creator_admin_permissions = true
}
