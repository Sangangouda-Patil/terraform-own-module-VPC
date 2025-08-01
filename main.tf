# Create the main VPC with the provided CIDR block and name
resource "aws_vpc" "main" {
  cidr_block = var.vpc_config.cidr_block

  tags = {
    Name = var.vpc_config.name
  }
}

# Create subnets based on the user's configuration
resource "aws_subnet" "main" {
  vpc_id   = aws_vpc.main.id
  for_each = var.subnet_config # each.key = subnet name, each.value = { cidr_block, az, public }

  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    Name = each.key
  }
}

# Filter for public subnets (where public = true)
locals {
  public_subnet = {
    for key, config in var.subnet_config : key => config if config.public
  }
}

# Filter for private subnets (where public = false or not set)
locals {
  private_subnet = {
    for key, config in var.subnet_config : key => config if !config.public
  }
}

# Create an Internet Gateway only if there's at least one public subnet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  count  = length(local.public_subnet) > 0 ? 1 : 0
}

# Create a public route table if there are public subnets
resource "aws_route_table" "main" {
  count  = length(local.public_subnet) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "main" {
  for_each = local.public_subnet

  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.main[0].id
}
