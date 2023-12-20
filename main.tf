provider "aws" {}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}

resource "aws_vpc" "terraform-project" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "tf-subnet-1" {
    vpc_id = aws_vpc.terraform-project.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
    Name: "${var.env_prefix}subnet-1"
    }
}

resource "aws_internet_gateway" "tf-igateway" {
    vpc_id = aws_vpc.terraform-project.id
    tags = {
        Name: "${var.env_prefix}-igw"
    }    
}

resource  "aws_route_table" "tf-route-table" {
    vpc_id = aws_vpc.terraform-project.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.tf-igateway.id
    }
    tags = {
        Name: "${var.env_prefix}-routetable-1"
    }
}

resource "aws_route_table_association" "rtb-subnet-asso" {
    subnet_id = aws_subnet.tf-subnet-1.id
    route_table_id = aws_route_table.tf-route-table.id
}
