
#------------------------------------------------------------------------------
# VPC Module
#------------------------------------------------------------------------------
module "demo_ecs_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "${var.name}-vpc"
  cidr = var.vpc_cidr_range

  azs             = ["${var.region}a"]
  private_subnets = var.private_subnets_list
  public_subnets  = var.public_subnets_list

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  create_igw         = true
  enable_nat_gateway = true
  enable_ipv6        = false

  enable_dns_hostnames = true
  enable_dns_support   = true
}
