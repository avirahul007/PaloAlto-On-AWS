module "panos-bootstrap" {
  source  = "PaloAltoNetworks/panos-bootstrap/aws"
  version = "1.0.0"

  #region      = "${var.aws_region}"

  hostname         = "my-firewall"
  panorama-server  = "panorama1.example.org"
  panorama-server2 = "panorama2.example.org"
  tplname          = "My Firewall Template"
  dgname           = "My Firewalls"
  vm-auth-key      = "supersecretauthkey"
}

resource "random_id" "bucket_id" {
  byte_length = 8
}
resource "aws_s3_bucket" "bucket" {
  bucket = "bootstrap-${random_id.bucket_id.hex}"
  acl    = "private"
}

resource "aws_s3_bucket_object" "bootstrap_dirs" {
  for_each = toset(var.bootstrap_directories)

  bucket  = aws_s3_bucket.bucket.id
  key     = each.value
  content = "/dev/null"
}

resource "aws_s3_bucket_object" "init_cfg" {
  bucket = aws_s3_bucket.bucket.id
  key    = "config/init-cfg.txt"
  content = templatefile("${path.module}/init-cfg.txt.tmpl",
    {
      "hostname"         = var.hostname,
      "panorama-server"  = var.panorama-server,
      "panorama-server2" = var.panorama-server2,
      "tplname"          = var.tplname,
      "dgname"           = var.dgname,
      "dns-primary"      = var.dns-primary,
      "dns-secondary"    = var.dns-secondary,
      "vm-auth-key"      = var.vm-auth-key,
      "op-command-modes" = var.op-command-modes
    }
  )
}

resource "aws_s3_bucket_object" "bootstrap_files" {
  for_each = fileset("${path.root}/files", "**")

  bucket  = aws_s3_bucket.bucket.id
  key     = each.value
  source  = "${path.root}/files/${each.value}"
}

resource "aws_iam_role" "bootstrap" {
  name = "BootstrapRole-${random_id.bucket_id.hex}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
      "Service": "ec2.amazonaws.com"
    },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "bootstrap" {
  name = "BootstrapRolePolicy-${random_id.bucket_id.hex}"
  role = aws_iam_role.bootstrap.id

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}"
    },
    {
    "Effect": "Allow",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "bootstrap" {
  name = "BootstrapInstanceProfile-${random_id.bucket_id.hex}"
  role = aws_iam_role.bootstrap.name
  path = "/"
}