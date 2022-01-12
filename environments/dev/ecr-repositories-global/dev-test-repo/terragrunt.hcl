terraform {
  source = "../../../../modules//ecr"       # Make Sure this matches the ECR Module, replative path may differ
}

include {
  path = find_in_parent_folders()
}



inputs = {

  name    = "dev-test-repo"      # Should be equal to Directory Name and to Repository Name
  enabled = true              # Enable if you want repository to be created

    # Principal ARNs to provide access to the ECR below:

  allowed_read_principals = [
    #"arn:aws:iam::111111111111:root", # prod
    #"arn:aws:iam::222222222222:root", # dev
    #"arn:aws:iam::333333333333:root", # master
    #"arn:aws:iam::444444444444:root", # staging
  ]

  allowed_write_principals = [
    #"arn:aws:iam::111111111111:root", # prod
    #"arn:aws:iam::222222222222:root", # dev
    #"arn:aws:iam::333333333333:root", # master
    #"arn:aws:iam::444444444444:root", # staging
  ]

}