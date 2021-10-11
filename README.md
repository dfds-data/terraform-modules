# Introduction 
Easy to set-up and flexible event-based data science pipelines. It uses a
pattern that separates the infrastructure from the code. The build team controls
the CI/CD pipeline for the code, the execution environment, environment
variables. Running `terraform apply` after updating the lambda function to use a
new image or other configuration updates will not revert these updates.

# Getting Started

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html)
- [Docker](https://www.docker.com/products/docker-desktop)
- [saml2aws](https://wiki.dfds.cloud/en/playbooks/getting-started/prereqs-win)
- [AWS capability](https://build.dfds.cloud/capabilities)
- [Incoming webhook connector url for Teams channel](https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook)

## Log in to capability
1. saml2aws login --force

## Create Terraform bucket
1. `aws s3api create-bucket --bucket <bucket_name> --region <region> --create-bucket-configuration LocationConstraint=<region>`
2. Enter terraform bucket name into [backend.tf](terraform/backend.tf)

## Push image to AWS ECR repository
1. Start Docker
2. `aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com`
3. `aws ecr create-repository --repository-name <repository_name>`
4. Enter folder the contains the Dockerfile that you want to build
5. `docker build -t <repository_name> .`
6. `docker tag <repository_name>:<tag> <account_id>.dkr.ecr.<region>.amazonaws.com/<repository_name>:<tag>`
7. `docker push <account_id>.dkr.ecr.<region>.amazonaws.com/<repository_name>:<tag>`

## Specify the infrastructure
1. In the terraform folder, define the infrastructure with the two source modules [cronjob](https://github.com/dfds-data/terraform-modules/tree/main/modules/lambda_cronjob) and [sns_subscription](https://github.com/dfds-data/terraform-modules/tree/main/modules/lambda_sns_subscription).


### SNS subscription
``` terraform
module <entity_name> {
  source        = "github.com/dfds-data/terraform-modules/modules/lambda_sns_subscription"
  entity_name   = <entity_name>
  image_uri = <image_uri> # This image can be anything for now. It will be ignored in subsequent runs of terraform apply. The image should updated in the CI/CD pipeline.
  monitor_image_uri = <monitor_image_uri> # This image must contain a function that reads an event and posts the message to a webhook url. Per default it listens to the 'ERROR' and 'timeout' words in the logs of the cronjob. This can be changed by specifying the 'filterpattern' argument.
  webhook_url = var.webhook_url
  sns_topic_arn = module.<entitiy_name>.topic_arn
}
```
## Have Terraform provision infrastructure
1. Write the webhook_url and monitor_image_uri in the terraform.tfvars file. 
2. `terraform init`
3. `terraform apply`

## Deploy function

### Prerequisites
1. A file with a lambda handler function
2. A requirements file (optional)

You must have a file with a lambda handler function. You can also specify a requirements file to install all your needed dependencies. Below is an example of such a Dockerfile. Place it in the same directory as the code.
```docker
FROM amazon/aws-lambda-python:3.8

COPY requirements.txt ./
RUN python -m pip install -r requirements.txt -t .

COPY preprocess.py .

CMD ["preprocess.lambda_handler"]
```

2. [Create ECR repository for the function](#push-image-to-aws-ecr-repository) and push the image.
3. You aws-cli to update the function and other configuration associated to the function
```
aws lambda update-function-configuration --function-name <function_name> \
    --environment "Variables={<env_name_1>=<env_name_1_val>, <env_name_2>=<env_name_2_val>}" \
    --memory-size <memory_size> \
    --timeout <timeout>
```

```
aws lambda update-function-code \
    --function-name <function_name> \
    --image-uri <image_uri>
```

```
aws events put-rule --name <function_name> --schedule-expression <cron_expression>
```

```
aws iam attach-role-policy --policy-arn <policy_arn> --role-name <function_name>
```