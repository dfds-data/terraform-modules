# Introduction

This module spins up the infrastructure for a cronjob on aws lambda. It uses a
pattern that separates the infrastructure from the code. The build team controls
the CI/CD pipeline for the code, the execution environment, environment
variables. Running `terraform apply` after updating the code, layer or
environment will not revert these updates

# How to use

You must set the `environmentname` and `entity_name` variables. Be careful not
to set this to an existing pair of environmentname and entity_name, in that case
terraform will replace the existing resources. Terraform will ask you before
replacing those resources.

You will need to have created a builds bucket. You can create it with the base_infrastructure module, or create it manually. 

The module will generate a dummy lambda layer and a dummy lambda function. You can change these with the aws cli.

```
module "cronjob" {
  source                  = "github.com/dfds-data/terraform-modules/modules/lambda_cronjob"
  environmentname         = "dev"
  entity_name             = "metrics"
  role_policies           = ["arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AmazonAthenaFullAccess", "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"]
  builds_bucket           = module.base_infrastructure.builds_bucket
}

```
