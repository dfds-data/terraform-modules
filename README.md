# Introduction

Easy to set-up and flexible event-based data science pipelines. It uses a
pattern that separates the infrastructure from the code. The build team controls
the CI/CD pipeline for the code, the execution environment, environment
variables. Running `terraform apply` after updating the lambda function to use a
new image or other configuration updates will not revert these updates.

## Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html)
- [Docker](https://www.docker.com/products/docker-desktop)
- [saml2aws](https://wiki.dfds.cloud/en/playbooks/getting-started/prereqs-win)
- [AWS capability](https://build.dfds.cloud/capabilities)
- [Incoming webhook connector url for Teams channel](https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook)

### Log in to capability

1. saml2aws login --force

### Create Terraform bucket

1. `aws s3api create-bucket --bucket <bucket_name> --region <region> --create-bucket-configuration LocationConstraint=<region>`
2. Enter terraform bucket name into [backend.tf](terraform/backend.tf)

### Push image to AWS ECR repository

1. Start Docker
2. `aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com`
3. `aws ecr create-repository --repository-name <repository_name>`
4. Enter folder the contains the Dockerfile that you want to build
5. `docker build -t <repository_name> .`
6. `docker tag <repository_name>:<tag> <account_id>.dkr.ecr.<region>.amazonaws.com/<repository_name>:<tag>`
7. `docker push <account_id>.dkr.ecr.<region>.amazonaws.com/<repository_name>:<tag>`

### Specify the infrastructure

1. In the terraform folder, define the infrastructure with the two source
   modules
   [cronjob](https://github.com/dfds-data/terraform-modules/tree/main/modules/lambda_cronjob)
   and
   [sns_subscription](https://github.com/dfds-data/terraform-modules/tree/main/modules/lambda_sns_subscription).

### Have Terraform provision infrastructure

1. Write the webhook_url and monitor_image_uri in the terraform.tfvars file.
2. `terraform init`
3. `terraform apply`

### Deploy function

You must have a file with a lambda handler function. You can also specify a
requirements file to install all your needed dependencies. Below is an example
of such a Dockerfile. Place it in the same directory as the code.

```docker
FROM amazon/aws-lambda-python:3.8

COPY requirements.txt preprocess.py ./
RUN python -m pip install -r requirements.txt -t .

CMD ["preprocess.lambda_handler"]
```

1. [Create ECR repository for the function and push the image.](#push-image-to-aws-ecr-repository)
2. Use AWS CLI commands to update the function and other configuration
   associated to the function

#### Update function configuration

```aws
aws lambda update-function-configuration --function-name <function_name> \
    --environment "Variables={<env_name_1>=<env_name_1_val>, <env_name_2>=<env_name_2_val>}" \
    --memory-size <memory_size> \
    --timeout <timeout>
```

#### Update function code

```aws
aws lambda update-function-code \
    --function-name <function_name> \
    --image-uri <image_uri>
```

#### Update configuration

```aws
aws iam attach-role-policy --policy-arn <policy_arn> --role-name <function_name>
```

### Write to an SNS topic

When a
[lambda_cronjob](https://github.com/dfds-data/terraform-modules/tree/main/modules/lambda_cronjob)
or
[lambda_sns_subscription](https://github.com/dfds-data/terraform-modules/tree/main/modules/lambda_sns_subscription)
is spun up, terraform also spins up an SNS topic with the same name as the
lambda function. When the lambda function is executed there are some
[predefined runtime environment variables](https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars.html):
this includes the AWS_LAMBDA_FUNCTION_NAME, which contains the name of the
lambda function. We use that to get the SNS topic ARN in the below example.

```python
import json
import boto3
from os import environ

def get_sns_topic_arn():
    account_id = boto3.client('sts').get_caller_identity().get('Account')
    topic_name = environ["AWS_LAMBDA_FUNCTION_NAME"]
    region = environ["AWS_REGION"]
    return f"arn:aws:sns:{region}:{account_id}:{topic_name}"

def publish_to_sns(message):
    client = boto3.client("sns")
    sns_topic_arn = get_sns_topic_arn()
    response = client.publish(
        TargetArn=sns_topic_arn,
        Message=json.dumps({"default": json.dumps(message)}),
        MessageStructure="json",
    )
```

where `message` is a python dictionary.
