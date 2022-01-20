
/*
  Create the VPC
*/
resource "aws_vpc" "main" {
  cidr_block = "${var.VPCCIDR}"
  tags = merge({
    Application = "${var.StackName}"
    Network = "MGMT"
    Name = "${var.VPCName}"
  })
}

resource "aws_subnet" "NewPublicSubnet" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.PublicCIDR_Block}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  #map_public_ip_on_launch = true
  tags = merge({
        Application = "${var.StackName}"
        Name = "${join("", list(var.StackName, "NewPublicSubnet"))}"
  })
}

resource "aws_subnet" "NewPrivateSubnet" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.PrivateCIDR_Block}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  #map_public_ip_on_launch = true
  tags = merge({
        Application = "${var.StackName}"
        Name = "${join("", list(var.StackName, "NewWebSubnet"))}"
  })
}

resource "aws_vpc_dhcp_options" "dopt21c7d043" {
  domain_name          = "me-south-1.internal"
  domain_name_servers  = ["AmazonProvidedDNS"]
}

resource "aws_network_interface" "FWManagementNetworkInterface" {
  subnet_id       = "${aws_subnet.NewPublicSubnet.id}"
  security_groups = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips_count = 1
  private_ips = ["10.0.0.10"]
}

resource "aws_network_interface" "FWPublicNetworkInterface" {
  subnet_id       = "${aws_subnet.NewPublicSubnet.id}"
  security_groups = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips_count = 1
  private_ips = ["10.0.0.20"]

}

resource "aws_network_interface" "FWPrivate12NetworkInterface" {
  subnet_id       = "${aws_subnet.NewPrivateSubnet.id}"
  security_groups = ["${aws_security_group.sgWideOpen.id}"]
  source_dest_check = false
  private_ips_count = 1
  private_ips = ["10.0.1.20"]
}

resource "aws_eip" "ManagementElasticIP" {
  vpc   = true
  depends_on = ["aws_vpc.main", "aws_internet_gateway.InternetGateway"]
}

resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = "${aws_vpc.main.id}"
  tags = merge({
    Application = "${var.StackName}"
    Network =  "MGMT"
    Name = "${join("-", list(var.StackName, "InternetGateway"))}"
  })
}

resource "aws_eip_association" "FWEIPManagementAssociation" {
  network_interface_id   = "${aws_network_interface.FWManagementNetworkInterface.id}"
  allocation_id = "${aws_eip.ManagementElasticIP.id}"
}

resource "aws_vpc_dhcp_options_association" "dchpassoc1" {
  vpc_id          = "${aws_vpc.main.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dopt21c7d043.id}"
}


resource "aws_security_group" "sgWideOpen" {
  name        = "sgWideOpen"
  description = "Wide open security group"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = "0"
    to_port         = "0"
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "FWInstance" {
  disable_api_termination = false
  iam_instance_profile = "${module.panos-bootstrap.instance_profile_name}"
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized = true
  ami = "${var.PANFWRegionMap[var.aws_region]}"
  instance_type = "${var.fw_instance_size}"

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp2"
    delete_on_termination = true
    volume_size = 60
  }

  key_name = "${var.ServerKeyName}"
  monitoring = false

  network_interface {
    device_index = 0
    network_interface_id = "${aws_network_interface.FWManagementNetworkInterface.id}"
  }

  network_interface {
    device_index = 1
    network_interface_id = "${aws_network_interface.FWPublicNetworkInterface.id}"
  }

  network_interface {
    device_index = 2
    network_interface_id = "${aws_network_interface.FWPrivate12NetworkInterface.id}"
  }


  user_data = "${base64encode(join("", list("vmseries-bootstrap-aws-s3bucket=", var.MasterS3Bucket)))}"

  #tags = "${merge(map("Name", format("%s", var.name)), var.tags)}"
}

resource "null_resource" "check_fw_ready" {
  triggers = {
    key = "${aws_instance.FWInstance.id}"
  }

  provisioner "local-exec" {
    command = "./check_fw.sh ${aws_eip.ManagementElasticIP.public_ip}"
  }
}

output "FirewallManagementURL" {
  value = "${join("", list("https://", "${aws_eip.ManagementElasticIP.public_ip}"))}"
}