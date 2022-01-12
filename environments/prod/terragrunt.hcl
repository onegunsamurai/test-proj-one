# Weak spots in code.
#   VPC calls LABEL module through symlink (rewrite)



#########################################################################################################################################
#
#           █▀█ █▀█ █▀█ █▀▄   █▀▀ █▀█ █▄░█ █▀▀ █ █▀▀ █░█ █▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█
#           █▀▀ █▀▄ █▄█ █▄▀   █▄▄ █▄█ █░▀█ █▀░ █ █▄█ █▄█ █▀▄ █▀█ ░█░ █ █▄█ █░▀█
#
#############################################################################################################################################


locals {
#GLOBAL
    profile             = "default"
    region              = "us-east-1"
    account_id          = "965340621517"

#LABEL SETTINGS
    namespace           = "cf"                  #Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'
    environment         = "prod"                #Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT'
    stage               = "prod"                #Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'
    name                = "app"                 #Solution name, e.g. 'app' or 'jenkins
    enabled             = true                  #Set to false to prevent the module from creating any resources
    delimiter           = "-"                   #Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`
    attributes          = [""]                  #Additional attributes (e.g. `1`)
    tags                = {}                    #Additional tags (e.g. `map('BusinessUnit','XYZ') ***********EDIT map() has been deprecated
    additional_tag_map  = {}                    #Additional tags for appending to each tag map
    label_order         = []                    #The naming order of the id output and Name tag
    regex_replace_chars = "/[^a-zA-Z0-9-]/"     #Regex to replace chars with empty string in `namespace`

#NETWORK SETTINGS
    cidr_block                      = "172.10.0.0/16"         #CIDR for the VPC
    instance_tenancy                = "default"             #A tenancy option for instances launched into the VPC
    enable_dns_hostnames            = true                  #A boolean flag to enable/disable DNS hostnames in the VPC
    enable_dns_support              = true                  #A boolean flag to enable/disable DNS support in the VPC
    enable_classiclink              = false                 #A boolean flag to enable/disable ClassicLink for the VPC
    enable_classiclink_dns_support  = false                 #A boolean flag to enable/disable ClassicLink DNS Support for the VPC
    enable_ipv6                     = true                  #A boolean flag to enable/disable IPv6 Support for the VPC
    max_subnet_count                = 2                     #Sets the maximum amount of subnets to deploy. 0 will deploy a subnet for every provided availablility zone (in `availability_zones` variable) within the region
    vpc_default_route_table_id      = ""                    #Default route table for public subnets. If not set, will be created. (e.g. `rtb-f4f0ce12`)
    public_network_acl_id           = ""                    #Network ACL ID that will be added to public subnets. If empty, a new ACL will be created
    private_network_acl_id          = ""                    #Network ACL ID that will be added to private subnets. If empty, a new ACL will be created
    map_public_ip_on_launch         = true                  #Instances launched into a public subnet should be assigned a public IP address

# ECR SETTINGS
#
#===============================================================================================================================
#   To edit ECR settings you should go to environments/prod/ecr-repositories-global and edit settings for a specific repository
#   
#   Available Settings Are:
#       - Turn ECR creation: On/Off     
#       - Assign access ARN's
#       - Assign repository name
#
#   NOTE:
#       To create new repository, create a new folder-matching repository name and copy terragrunt.hcl from any ECR folders.
#       Next, change the "name" parameter in terragrunt.hcl to match the directory and repository name.
#
#  ** To initialize all repositories at the same time, run terragrunt run-all apply from ecr-repositories-global directory.
#

#   Default Principal ARN's for ECR access.
    allowed_read_principals         = []
    allowed_write_principals        = []
#===============================================================================================================================


# ECS SERVICE
#
#===============================================================================================================================
#
#
#   To manage settings for a specific ECS cluster 
#   You need to go to /env/ecs folder and follow
#   to the directory of a specific cluster. Then
#   open the terragrint.hcl and edit configs
#   of a specific cluster
#


}


remote_state {
    backend = "s3"
    generate = {
       path = "backend.tf"
       if_exists = "overwrite_terragrunt"
    }
    config = {
        bucket          = "${local.name}-${local.environment}-bucket-897adshjk1asd"
        key             = "${path_relative_to_include()}/terraform.tfstate"
        region          = local.region
        encrypt         = true
        profile         = local.profile
        dynamodb_table  = "${local.name}-dynamodb"
    }
}



inputs = {
    profile                         = local.profile
    region                          = local.region
    account_id                      = local.account_id

    namespace                       = local.namespace
    name                            = local.name                  
    environment                     = local.environment                 
    stage                           = local.stage                
    enabled                         = local.enabled                  
    delimiter                       = local.delimiter                   
    attributes                      = local.attributes                    
    tags                            = local.tags                    
    additional_tag_map              = local.additional_tag_map                    
    label_order                     = local.label_order                
    regex_replace_chars             = local.regex_replace_chars    

    cidr_block                      = local.cidr_block       
    instance_tenancy                = local.instance_tenancy            
    enable_dns_hostnames            = local.enable_dns_hostnames               
    enable_dns_support              = local.enable_dns_support          
    enable_classiclink              = local.enable_classiclink            
    enable_classiclink_dns_support  = local.enable_classiclink_dns_support             
    enable_ipv6                     = local.enable_ipv6
    max_subnet_count                = local.max_subnet_count     
    vpc_default_route_table_id      = local.vpc_default_route_table_id                    
    public_network_acl_id           = local.public_network_acl_id
    private_network_acl_id          = local.private_network_acl_id
    map_public_ip_on_launch         = local.map_public_ip_on_launch
}