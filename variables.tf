data "aws_availability_zones" "available" {}
variable "aws_region" {
  default = "ap-south-1"
}
variable "PrivateCIDR_Block" {}
variable "PublicCIDR_Block" {}
variable "MasterS3Bucket" {}
variable "VPCName" {}
variable "VPCCIDR" {}
variable "ServerKeyName" {}
variable "StackName" {}
variable "fw_instance_size" {}
variable "PANFWRegionMap" {
  type = "map"
  default = {
    
      "us-west-2" = "ami-d424b5ac",
      "ap-northeast-1" =   "ami-57662d31",
      "us-west-1"      =   "ami-a95b4fc9",
      "ap-northeast-2" =   "ami-49bd1127",
      "ap-southeast-1" =   "ami-27baeb5b",
      "ap-southeast-2" =   "ami-00d61562",
      "eu-central-1"   =   "ami-55bfd73a",
      "eu-west-1"      =   "ami-a95b4fc9",
      "eu-west-2"      =   "ami-876a8de0",
      "sa-east-1"      =   "ami-9c0154f0",
      "us-east-1"      =   "ami-a2fa3bdf",
      "us-east-2"      =   "ami-11e1d774",
      "ca-central-1"   =   "ami-64038400",
      "ap-south-1"     =   "ami-e780d988"
  }
}
variable "bootstrap_directories" {
  description = "The directories comprising the bootstrap package"
  default = [
    "config/",
    "content/",
    "software/",
    "license/",
    "plugins/"
  ]
}

variable "hostname" {
  default     = ""
  description = "The hostname of the VM-series instance"
  type        = string
}

variable "panorama-server" {
  default     = ""
  description = "The FQDN or IP address of the primary Panorama server"
  type        = string
}

variable "panorama-server2" {
  default     = ""
  description = "The FQDN or IP address of the secondary Panorama server"
  type        = string
}

variable "tplname" {
  default     = ""
  description = "The Panorama template stack name"
  type        = string
}

variable "dgname" {
  default     = ""
  description = "The Panorama device group name"
  type        = string
}

variable "dns-primary" {
  default     = ""
  description = "The IP address of the primary DNS server"
  type        = string
}

variable "dns-secondary" {
  default     = ""
  description = "The IP address of the secondary DNS server"
  type        = string
}

variable "vm-auth-key" {
  default     = ""
  description = "Virtual machine authentication key"
  type        = string
}

variable "op-command-modes" {
  default     = ""
  description = "Set jumbo-frame and/or mgmt-interface-swap"
  type        = string
}