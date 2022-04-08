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

source "azure-arm" "windows" {
  azure_tags = {
    dept = "Engineering"
    task = "Image deployment"
  }
  //Corrigir
  // client_id                         = "36cc18ed-87b5-47b7-b5ae-cd0791934340"
  // client_secret                     = "pLE7Q~QHLfKwGjAuv3lYSpTr9H5YAwqcVCgmH"
  communicator                      = "winrm"
  image_offer                       = "WindowsServer"
  image_publisher                   = "MicrosoftWindowsServer"
  image_sku                         = "2016-Datacenter"
  location                          = "East US"
  managed_image_name                = "packer-windows-demo-${local.timestamp}"
  managed_image_resource_group_name = "myPackerGroup"
  os_type                           = "Windows"
  subscription_id                   = "aa3930a3-3762-49e2-b88e-38bc0581dfb3"
  tenant_id                         = "c97621e9-4bac-4ed5-ab14-b38e8e16ce85"
  vm_size                           = "Standard_D2_v2"
  winrm_insecure                    = true
  winrm_use_ssl                     = true
  winrm_username                    = "packer"
  user_data_file                    = "./azure/bootstrap.ps1"
}

source "amazon-ebs" "windows" {
  ami_name          = "packer-windows-demo-${local.timestamp}"
  communicator      = "winrm"
  winrm_username    = "Administrator"
  winrm_use_ssl     = true
  winrm_insecure    = true
  force_deregister = true
  force_delete_snapshot = true
  instance_type     = "${local.instance_type}"
  region            = "${local.region}"
  vpc_id            = "${local.vpc_id}"
  subnet_id         = "${local.subnet_id}"
  associate_public_ip_address = true
  source_ami_filter {
    filters = {
      name                = "*Windows_Server-2019-English-Full-Base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  user_data_file = "./aws/bootstrap.ps1"
}

build {
  name    = "builder"
  sources = ["source.azure-arm.windows", "source.amazon-ebs.windows"]

  provisioner "powershell" {
    script = "./ansible/remote_config.ps1"  
  }
  
  provisioner "ansible" {
    playbook_file = "./ansible/playbook.yml"
    extra_arguments = ["--extra-vars", "winrm_password=${build.Password}"]

  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    only = ["azure-arm.windows"]
    script = "./azure/sysprep.ps1"  
  }

  provisioner "powershell" {
    only = ["amazon-ebs.windows"]
    script = "./aws/reset.ps1"
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}