data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Try to find the default VPC and its subnets. If no subnet exists in the default VPC,
# create a single subnet so EC2 instances can be launched.
data "aws_default_vpc" "default" {}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_default_vpc.default.id
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "default" {
  count = length(data.aws_subnet_ids.default.ids) == 0 ? 1 : 0
  vpc_id            = data.aws_default_vpc.default.id
  cidr_block        = cidrsubnet(data.aws_default_vpc.default.cidr_block, 8, 1)
  availability_zone = length(data.aws_availability_zones.available.names) > 0 ? data.aws_availability_zones.available.names[0] : null

  tags = {
    Name    = "${var.name}-subnet"
    project = "swen-cloud-intel"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "${var.name}-sg"
  description = "Security group for SWEN demo app"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "App port (Streamlit)"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.name}-sg"
    project = "swen-cloud-intel"
  }
}

resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  subnet_id = var.subnet_id != "" ? var.subnet_id : (length(data.aws_subnet_ids.default.ids) > 0 ? element(data.aws_subnet_ids.default.ids, 0) : aws_subnet.default[0].id)

  # Only set key_name if provided
  key_name = length(var.key_name) > 0 ? var.key_name : null

  tags = {
    Name    = var.name
    project = "swen-cloud-intel"
  }
}
