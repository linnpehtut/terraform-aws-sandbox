provider "aws" {
    region = "ap-southeast-1"
    # access_key = "AKIA55V6L57JMA7UCWTV"
    # secret_key = "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"
}

variable "cidr_blocks" {
    description = "cidr blocks for vpc and subnets"
    type = list(string)
}

variable "environment" {
    description = "environment defined"
}

 
resource "aws_vpc" "tftest" {
    cidr_block = var.cidr_blocks[0]
    tags = {
        Name: var.environment,
        vpc_env: "tf"
    }
}

resource "aws_subnet" "tf-subnet-1" {
    vpc_id = aws_vpc.tftest.id
    cidr_block = var.cidr_blocks[1]
    availability_zone = "ap-southeast-1a"
    tags = {
    Name: "subnet-tftest-1"
    }
}

# output "tf-vpc-id" {
#     value = aws_vpc.tftest
# }

# output "tf-subnet-id" {
#     value = aws_subnet.tf-subnet-1
# }

# data "aws_vpc" "existing_vpc" {
#     default = true
# }

# resource "aws_subnet" "tf-subnet-2" {
#     vpc_id = data.aws_vpc.existing_vpc.id
#     cidr_block = "172.31.112.0/20"
#     availability_zone = "ap-southeast-1b"
#     tags = {
#         Name: "subnet-tftest"
#     }        
# }

# output "tf-vpc-id" {
#     value = aws_vpc.tftest.id
# }

# output "tf-subnet-id" {
#     value = aws_subnet.tf-subnet-1.id
# }
