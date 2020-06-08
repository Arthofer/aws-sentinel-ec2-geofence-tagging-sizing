terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Space"

    workspaces {
      name = "AWS-Sentinel"
    }
  }
}

resource "random_pet" "server" {
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  #don't change this from us-west-2 :)
  region = "us-west-2"
}

variable "aws_access_key" {
  description = "access key"
}

variable "aws_secret_key" {
  description = "secret key"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "demo" {
  ami = data.aws_ami.ubuntu.id

  #do not change this from t2.micro, unless you want to trigger sentinel
   instance_type = "t2.xlarge"
   instance_type = "t2.micro"

  tags = {
    Name = random_pet.server.id
    #uncomment this for working, comment out for sentinel policy trigger
    Owner = "austina"
    TTL   = "24hrs"
    }
  }
