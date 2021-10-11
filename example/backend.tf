terraform {
  backend "s3" {
    bucket = "terraform-xckja"
    key = "terraform.tfstate"
    region = "eu-central-1"
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
