resource "aws_codebuild_project" "project" {
  name          = var.name
  description   = "CodeBuild Project for All Envs" # Some description if needed here
  build_timeout = var.timeout
  
  service_role  = aws_iam_role.codebuild_role.arn

  environment {
    compute_type = var.compute_type
    image        = var.docker_build_image
    type         = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "${file("buildspec.yaml")}"
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}