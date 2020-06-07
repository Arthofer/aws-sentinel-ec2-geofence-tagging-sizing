terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "cdunlap"

    workspaces {
      name = "aws-sentinel-demo"
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
   #instance_type = "t2.xlarge"
   instance_type = "t2.micro"

  key_name = var.ssh_key_name

  tags = {
    Name = random_pet.server.id
    #uncomment this for working, comment out for sentinel policy trigger
    Owner = "chrisd"
    TTL   = "24hrs"
  }
  user_data = data.template_file.cloud-init.rendered
}

output "private_ip" {
  description = "Private IP of instance"
  value       = join("", aws_instance.demo.*.private_ip)
}

output "public_ip" {
  description = "Public IP of instance (or EIP)"
  value       = join("", aws_instance.demo.*.public_ip)
}

data "template_file" "cloud-init" {
  template = file("cloud-init.tpl")

  vars = {
    boinc_project_id = var.boinc_project_id
  }
}

variable "boinc_project_id" {
  description = "Boinc Project id: boinccmd --lookup_account URL email password https://boinc.berkeley.edu/wiki/Boinccmd_tool"
}
variable "ssh_key_name" {
  description = "You AWS SSH KeyName"
}
