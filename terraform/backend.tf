terraform {
  backend "s3" {
    bucket = "ankita-demo-tfstate-bucket-1"
    key    = "eks/terraform.tfstate"
    region = "us-west-2"
  }
}


