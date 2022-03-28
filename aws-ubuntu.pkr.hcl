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
  //vpc_id        = "vpc-005907dca31d725f6"
  //subnet_id     = "subnet-0b0fa07c52ffc4553"
  vpc_id        = "vpc-0388c9895160ff515"
  subnet_id     = "subnet-020b942e8598e2622"
  instance_type = "t2.micro"
  
  }

source "amazon-ebs" "ubuntu" {
  ami_name          = "packer-linux-demo-${local.timestamp}"
  instance_type     = "${local.instance_type}"
  region            = "${local.region}"
  vpc_id            = "${local.vpc_id}"
  subnet_id         = "${local.subnet_id}"
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
  ssh_username = "ubuntu"
  user_data_file = "bootstrap_linux.sh"
}

  build {
    name = "learn-packer-ubuntu"
    sources = [
      "source.amazon-ebs.ubuntu"
  ]
 }

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
  user_data_file = "bootstrap_win.txt"
  winrm_password = "PackerDemoSR3G4lp"
  winrm_username = "Administrator"
}

# a build block invokes sources and runs provisioning steps on them.
build {
  name    = "learn-packer"
  sources = ["source.amazon-ebs.windows"]

  provisioner "windows-restart" {
  }
}