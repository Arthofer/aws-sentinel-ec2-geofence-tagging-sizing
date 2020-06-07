terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "space"

    workspaces {
      name = "aws-sentinel-demo"
    }
  }
}

resource "random_pet" "server" {
}

provider "aws" {
  access_key = "AKIAJJUBLB6N43T67RMA"
  secret_key = "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"

  #don't change this from us-west-2 :)
  region = "us-west-2"
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

  tags = {
    Name = random_pet.server.id
    #uncomment this for working, comment out for sentinel policy trigger
    Owner = "chrisd"
    TTL   = "24hrs"
  }
}
