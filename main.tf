terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Space"

    workspaces {
      name = "aws-sentinel-demo"
    }
  }
}

resource "random_pet" "server" {
}

resource "aws_key_pair" "deployer" {
  key_name   = "austindemoSSH"
  public_key = "02001ce6056d38dc5"
  }
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

variable "ssh_key_name" {
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
   #instance_type = "t2.xlarge"
   instance_type = "t2.micro"

  key_name = var.ssh_key_name

  tags = {
    Name = random_pet.server.id
    #uncomment this for working, comment out for sentinel policy trigger
    Owner = "chrisd"
    TTL   = "24hrs"
    }
  }
