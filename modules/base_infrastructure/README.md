# Introduction
Sets up the base infrastructure for the other modules in this repository.

# How to use

Set up the base infrastructure by running the base infrastructure module

``` hcl
module "base_infrastructure" {
  source                = "github.com/dfds-data/terraform-modules/modules/base_infrastructure"
  builds_bucket         = "prod-builds"
  output_bucket         = "prod-output"
  athena_query_location = "prod-athena-query-location"
  glue_database         = "prod-db"
}
```