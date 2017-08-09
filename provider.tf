provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "c4po-tfstate"
    key    = "demo/aws.tfstate"
    region = "us-east-1"
  }
}
