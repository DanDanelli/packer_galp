packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
    timestamp     = regex_replace(timestamp(), "[- TZ:]", "") 
    region        = "eu-west-1"
    vpc_id        = "vpc-0388c9895160ff515"
    subnet_id     = "subnet-020b942e8598e2622"
    instance_type = "t2.micro"
}

variable "arm_client_id" {
  type    = string
  default = "${env("arm_client_id")}"
  validation {
    condition     = length(var.arm_client_id) > 0
    error_message = <<EOF
The arm_client_id environment variable must be set.
EOF
  }
}

variable "arm_client_secret" {
  type    = string
  default = "${env("arm_client_secret")}"
  validation {
    condition     = length(var.arm_client_secret) > 0
    error_message = <<EOF
The arm_client_secret environment variable must be set.
EOF
  }
}

variable "arm_subscription_id" {
  type    = string
  default = "${env("arm_subscription_id")}"
  validation {
    condition     = length(var.arm_subscription_id) > 0
    error_message = <<EOF
The arm_subscription_id environment variable must be set.
EOF
  }
}

variable "arm_tenant_id" {
  type    = string
  default = "${env("arm_tenant_id")}"
  validation {
    condition     = length(var.arm_tenant_id) > 0
    error_message = <<EOF
The arm_tenant_id environment variable must be set.
EOF
  }
}

source "azure-arm" "ubuntu" {
  azure_tags = {
    dept = "Engineering"
    task = "Image deployment"
  }
  client_id                         = "${var.arm_client_id}"
  client_secret                     = "${var.arm_client_secret}"
  subscription_id                   = "${var.arm_subscription_id}"
  tenant_id                         = "${var.arm_tenant_id}"
  image_offer                       = "UbuntuServer"
  image_publisher                   = "Canonical"
  image_sku                         = "18.04-LTS"
  location                          = "East US"
  managed_image_name                = "azure-ubuntu-demo-${local.timestamp}"
  managed_image_resource_group_name = "myPackerGroup"
  os_type                           = "Linux"
  ssh_username                      = "ubuntu"
  vm_size                           = "Standard_DS1_v2"
}

source "amazon-ebs" "ubuntu" {
    ami_name            = "aws-linux-demo-${local.timestamp}"
    instance_type       = "${local.instance_type}"
    region              = "${local.region}"
    vpc_id              = "${local.vpc_id}"
    subnet_id           = "${local.subnet_id}"
    associate_public_ip_address = true
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username   = "ubuntu"
}

build {
    name      = "builder"
    sources   = ["source.amazon-ebs.ubuntu","source.azure-arm.ubuntu"]

  provisioner "ansible" {
    playbook_file = "./ansible/main_v2.yml"
  }

  provisioner "shell" {
    script = "./resources/reset.sh"
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}