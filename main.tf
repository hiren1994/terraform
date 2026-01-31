
# Existing VPC (Data Source)
# -----------------------------
data "aws_vpc" "existing_vpc" {
  id = var.vpc_id
}

# Existing Subnet (Data Source)
# -----------------------------
data "aws_subnet" "existing_subnet" {
  id = var.subnet_id
}
# Existing Key Pair (Data Source)
# -----------------------------

data "aws_key_pair" "existing" {
  key_name = var.key_pair_name
}


# Ubuntu 22.04 AMI
# -----------------------------
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# Security Group (SSH only)
# -----------------------------
resource "aws_security_group" "ssh_sg" {
  name        = "ec2-ssh-sg"
  description = "Allow SSH access"
  vpc_id      = data.aws_vpc.existing_vpc.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-ssh-sg"
  }
}

# -----------------------------
# EC2 Instance
# -----------------------------
resource "aws_instance" "ubuntu_ec2" {
  depends_on             = [aws_security_group.ssh_sg]
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.existing_subnet.id
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]
  key_name               = data.aws_key_pair.existing.key_name

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = "ubuntu-22-04"
  }
}
