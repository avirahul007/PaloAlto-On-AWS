provider "aws" {
    access_key = "Your Access Key"
    secret_key = "Your Secret Key"
    token = "Your Token Key"
    region     = "${var.aws_region}"
}
