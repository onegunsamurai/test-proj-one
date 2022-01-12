terraform {
  source = "../../../../modules/codepipelines//infra"       # Make Sure this matches the ECR Module, replative path may differ
}

include {
  path = find_in_parent_folders()
}
