
data "aws_ssm_parameter" "git_token" {
  name = "github_token"
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.name}-codepipeline-s3-965340621517"
}

resource "aws_codepipeline" "infra-pipe" {
  name     = "${var.name}"
  role_arn = "${aws_iam_role.codebuild_role.arn}"

  artifact_store {
    location = aws_s3_bucket.this.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        Owner                = "${var.github_org}"
        Repo                 = "${var.github_repo}"
        PollForSourceChanges = "true"
        Branch               = "${var.github_branch}"
        OAuthToken           = "${data.aws_ssm_parameter.git_token.value}"
      }
    }
  }

  stage {
    name = "build-dev-infra"

    action {
      name             = "build-dev-infra"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      version          = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.project.name}"
        EnvironmentVariables = jsonencode([
          {
            name  = "ENVIRONMENT"
            value = "dev"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }




}

