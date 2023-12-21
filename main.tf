provider "aws" {}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable allowed_ip_for_ssh {}
variable instance_type {}
variable public_key_location {}

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

# The commented lines are to use the default route table instead of creating one
# resource  "aws_default_route_table" "default-tf-route-table" {
#     default_route_table_id = aws_vpc.terraform-project.default_route_table_id 

#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_internet_gateway.tf-igateway.id
#     }
#     tags = {
#         Name: "${var.env_prefix}-default-routetable-1"
#     }
# }

resource "aws_route_table_association" "rtb-subnet-asso" {
    subnet_id = aws_subnet.tf-subnet-1.id
    route_table_id = aws_route_table.tf-route-table.id
}

resource "aws_security_group" "tf-sg" {
    name = "tf-sg"
    vpc_id = aws_vpc.terraform-project.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.allowed_ip_for_ssh]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    
    tags = {
        Name: "${var.env_prefix}-sg"
    }
}

resource "aws_default_security_group" "default-sg" {
    vpc_id = aws_vpc.terraform-project.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.allowed_ip_for_ssh]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    
    tags = {
        Name: "${var.env_prefix}-default-sg"
    }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}
# before going straight to resource, u can check with output function of terraform
# output "aws_ami" {
#     value = data.aws_ami.latest-amazon-linux-image.id
# }

resource "aws_key_pair" "terrafor-key" {
    key_name = "terraform-key"
    public_key = file(var.public_key_location)
}

resource "aws_instance" "tf-app-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.tf-subnet-1.id
    vpc_security_group_ids = [aws_security_group.tf-sg.id, aws_default_security_group.default-sg.id] #we have 2 sg so i will attach 2
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    key_name = aws_key_pair.terrafor-key.key_name

    user_data = file("entrypoint.sh")

    tags = {
        Name = "${var.env_prefix}-server"
    }
}

output "ec2_public_ip" {
    value = aws_instance.tf-app-server.public_ip
}