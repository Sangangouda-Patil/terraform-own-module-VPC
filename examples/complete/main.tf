module "vpc" {
  source = "../modules/vpc"

  vpc_config = {
    cidr_block = "10.1.0.0/16"
    name       = "example-vpc"
  }

  subnet_config = {
    public-a = {
      cidr_block = "10.0.0.0/24"
      az         = "us-east-1a"
      public     = true
    }

    public-b = {
      cidr_block = "10.0.2.0/24"
      az         = "us-east-1a"
      public     = true
    }
    private-a = {
      cidr_block = "10.0.1.0/24"
      az         = "us-east-1a"
    }
  }
}
