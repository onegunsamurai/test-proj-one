terraform {
    source = "../../../../modules//ecs"
}

include {
    path = find_in_parent_folders()
}

dependencies {
    paths = ["../../main-vpc"]
}

dependency "main-vpc" {
    config_path = "../../main-vpc"
    mock_outputs = {
        vpc_id              = "vpc-000000000000"
        public_subnet_ids   = ["subnet-00000000000", "subnet-111111111111"]
        private_subnet_ids   = ["subnet-22222222222", "subnet-444444444444"]
    }
}

inputs = {

# Don't change:
    vpc_id              = dependency.main-vpc.outputs.vpc_id
    public_subnet_ids   = dependency.main-vpc.outputs.public_subnet_ids
    private_subnet_ids  = dependency.main-vpc.outputs.private_subnet_ids
#===================

# Configurations:
name        = "v2-prod"     # Make sure the name is unique

instance_type       = "t2.micro"          # Setup instance types to be used in ECS Cluster
volume_size         = 30                  # Select how much storage should be allocated
max_instances       = 2                   # Max. amount of instances in the cluster
desired_instances   = 1                   # Desired number of instances
min_instances       = 1                   # Min. amount of instances in the cluster
single_balancer     = true                # Create a single load balancer to serve the entire ECS cluster
vpn_security_groups = []                  # Add if there are any VPN Security Groups should be attached

}

