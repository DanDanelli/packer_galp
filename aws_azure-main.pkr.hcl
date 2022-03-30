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

// source "azure-arm" "windows" {
//   azure_tags = {
//     dept = "Engineering"
//     task = "Image deployment"
//   }
//   client_id                         = "36cc18ed-87b5-47b7-b5ae-cd0791934340"
//   client_secret                     = "pLE7Q~QHLfKwGjAuv3lYSpTr9H5YAwqcVCgmH"
//   communicator                      = "winrm"
//   image_offer                       = "WindowsServer"
//   image_publisher                   = "MicrosoftWindowsServer"
//   image_sku                         = "2016-Datacenter"
//   location                          = "East US"
//   managed_image_name                = "packer-windows-demo-${local.timestamp}"
//   managed_image_resource_group_name = "myPackerGroup"
//   os_type                           = "Windows"
//   subscription_id                   = "aa3930a3-3762-49e2-b88e-38bc0581dfb3"
//   tenant_id                         = "c97621e9-4bac-4ed5-ab14-b38e8e16ce85"
//   vm_size                           = "Standard_D2_v2"
//   winrm_insecure                    = true
//   // winrm_timeout                     = "30m"
//   winrm_use_ssl                     = true
//   winrm_username                    = "packer"
//   user_data_file                    = "./azure/windows/2016/bootstrap.ps1"
// }

// build {
//   sources = ["source.azure-arm.windows"]
// }

// source "amazon-ebs" "ubuntu" {
//     ami_name            = "packer-linux-demo-${local.timestamp}"
//     instance_type       = "${local.instance_type}"
//     region              = "${local.region}"
//     vpc_id              = "${local.vpc_id}"
//     subnet_id           = "${local.subnet_id}"
//     security_group_ids  = ["sg-008991abea339f2dc"]
//     associate_public_ip_address = true
//   source_ami_filter {
//     filters = {
//       name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
//       root-device-type    = "ebs"
//       virtualization-type = "hvm"
//     }
//     most_recent = true
//     owners      = ["099720109477"]
//   }
//   ssh_username   = "ubuntu"
//   user_data_file = "./aws/linux/ubuntu/bootstrap.sh"
// }

//   build {
//     name      = "learn-packer-ubuntu"
//     sources   = ["source.amazon-ebs.ubuntu"]
    
//     provisioner "shell" {
//       script  = "./aws/linux/ubuntu/install_apache.sh"
//     }
//  }

source "amazon-ebs" "windows" {
  ami_name          = "packer-windows-demo-${local.timestamp}"
  communicator      = "winrm"
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
  user_data_file = "./aws/windows/2019/bootstrap.ps1"
  winrm_password = "PackerDemoSR3G4lp"
  winrm_username = "Administrator"
}

# a build block invokes sources and runs provisioning steps on them.
build {
  name    = "learn-packer"
  sources = ["source.amazon-ebs.windows"]

  provisioner "powershell" {
    script = "./aws/windows/2019/reset.ps1"
  }

  // provisioner "windows-restart" {
  // }
}