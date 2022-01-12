variable "name" {
  default = "infra"
}
variable "github_repo" {
  default="test-proj-one"  # Replace with projects infra branch
}

variable "github_branch" {
  default = "main"
}

variable "github_org" {
  default = "onegunsamurai"   #Replace with communityfunded
}

variable "artifact_store" {
  default = "codepipeline-us-west-2-812925994347"
}
variable "docker_build_image" {
  default = "aws/codebuild/standard:3.0"
}


variable "region" {
  default = "us-west-2"
}

variable "profile" {
  
}

variable "timeout" {
  default = "30"
}

variable "compute_type" {
  default = "BUILD_GENERAL1_SMALL"
}
