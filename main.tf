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
  access_key = "AKIAJIGLX7MGJ7MMILEA"
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
