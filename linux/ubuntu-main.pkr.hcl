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

source "azure-arm" "ubuntu" {
  azure_tags = {
    dept = "Engineering"
    task = "Image deployment"
  }
  client_id                         = "36cc18ed-87b5-47b7-b5ae-cd0791934340"
  client_secret                     = "pLE7Q~QHLfKwGjAuv3lYSpTr9H5YAwqcVCgmH"
  image_offer                       = "UbuntuServer"
  image_publisher                   = "Canonical"
  image_sku                         = "18.04-LTS"
  location                          = "East US"
  managed_image_name                = "azure-ubuntu-demo-${local.timestamp}"
  managed_image_resource_group_name = "myPackerGroup"
  os_type                           = "Linux"
  ssh_username                      = "ubuntu"
  subscription_id                   = "aa3930a3-3762-49e2-b88e-38bc0581dfb3"
  tenant_id                         = "c97621e9-4bac-4ed5-ab14-b38e8e16ce85"
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
    name      = "aws-packer-ubuntu"
    sources   = ["source.amazon-ebs.ubuntu","source.azure-arm.ubuntu"]

  provisioner "shell" {
    script = "apache.sh"
  }

  provisioner "shell" {
    script = "reset.sh"
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}