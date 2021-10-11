# Introduction

This module spins up the infrastructure for an SNS subscription on aws lambda.

# How to use

``` hcl
module <entity_name> {
  source        = "github.com/dfds-data/terraform-modules/modules/lambda_cronjob"
  entity_name   = <entity_name>
  image_uri = <image_uri> # This image can be anything for now. It will be ignored in subsequent runs of terraform apply. The image should updated in the CI/CD pipeline.
  monitor_image_uri = <monitor_image_uri> # This image must contain a function that reads an event and posts the message to a webhook url. Per default it listens to the 'ERROR' and 'timeout' words in the logs of the cronjob. This can be changed by specifying the 'filterpattern' argument.
  webhook_url = var.webhook_url
}
```