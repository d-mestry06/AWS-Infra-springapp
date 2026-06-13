terraform {
  backend "s3" {
    bucket         = "my-dim-test-s3"
    key            = "infra.tfstate"
    region         = "ap-south-1"
    profile        = "default"
    dynamodb_table = "terraform-state-lock"
  }
}