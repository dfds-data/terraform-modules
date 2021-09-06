# Introduction

This module spins up the infrastructure for monitoring a cloudwatch log group
and sending alerts to a Microsoft Teams channel.

# How to use

You must set the `environmentname` and `entity_name` variables. Be careful not
to set this to an existing pair of environmentname and entity_name, in that case
terraform will replace the existing resources. Terraform will ask you before
replacing those resources.

You will need to have created a builds bucket. You can create it with the
base_infrastructure module, or create it manually.

You will also need to specify the log group you want to watch by setting the
`log_group` variable.

The module assumes that the `filterpattern` is "ERROR". You can change that with
the aws cli or set the `filterpattern` variable when defining the infrastructure
in terraform. The `filterpattern` variable is ignored in subsequent `terraform apply` commands

The module will generate a dummy lambda layer. You can change that with the aws
cli.

The lambda function will look for the environment variable `webhook_url`. You can
set that with the aws cli.

```
module "monitor_log" {
  source                  = "github.com/dfds-data/terraform-modules/modules/lambda_monitor_log"
  environmentname         = "dev"
  entity_name             = "metrics"
  log_group               = module.cronjob.log_group_name
  builds_bucket           = module.base_infrastructure.builds_bucket
}

```

# Variables

There is a list of all variables and a description of these in the [variables.tf ](./variables.tf) file
