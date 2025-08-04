terraform {
  backend "s3" {
    bucket         = "jenny-devops-terraform-state-jenny"   
    key            = "devops-platform/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-state-locks-jenny"         
    encrypt        = true
  }
}
