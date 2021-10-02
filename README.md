# AWS-Lambda + Python + Terraform example
Deploy your Python app in minutes!

This is a template for rapid deploy of Python web services (FastAPI, Flask, etc) on AWS-Lambda, automated by Terraform.

## Requirements
* Python +3.7 and python3-venv
```bash
sudo apt-get install python3-venv
```
* AWS-cli, [(check AWS cli intall docs)](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html9),
and IAM credentials

  ```bash
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  ```
* Terraform

## Hello, world!
1. Clone this repository, open a terminal in the repository root
  ```bash
  git clone this/repository
  cd  this/repository
  ```
1. Crete the env files:
  ```bash
  chmod +x ./create_env.sh
  ./create_env.sh
  ```
1. upload to AWS-lambda (may apply charges)
  ```bash
  chmod +x ./upload.sh
  ./upload.sh
  ```
1. you will see a prompt to confirm the Terraform plan, if everything looks good, type "yes". If everything went right, after a couple of minutes you will see this:
```
Testing API endpoint
...
{"Hello":"World!!!"}
```




***
## Quick Deploy for your project

1. Replace  **/app** with the code of your Python App, or change the value of **APP_DIR** in **upload.sh** to make it point to the path of your app.
  * this example uses FastAPI, is almost the same for Flask an other micro-frameworks.
  * Remember to import Mangum and create a handler for the main function. this is going to be used by Lambda.
1. In **/env**  create a folder for the virtual environment with the requirements of your Python app, or change the value of **PACKAGES_DIR** in **upload.sh**.
  * you can replace the requirements.txt in the root folder and run **create_env.sh** to create the content of **./env**
1. setup your system for automatic deploy:
  * install AWS-cli
  * create and save IAM credentials
  * install terraform
1. Deploy:
  * edit the variable.tf file for custom names
  * run upload.sh

Each step is explained with more details in the following sections.


```
.
├── app
|   └── ...
├── env
|   └── ...
├── temp
|   └── ...
├── temp
|   └── ...
├── main.tf
├── upload.sh
└── variables.tf
```
***

## Lambda Functions on AWS
Basic setup:
* Python code:
  * simple code on aws-console or a zip file uploaded to S3 for bigger apps
  * every library outside the standard library must be included in the zip file
  * you need a handler for Lambda, in this case we use Mangum
* API gateway to trigger the lambda function
  * gateway URL used as a proxy to pass requests to the app router
  * permissions for gateway: in this case will be public.

### Server-less architecture drawbacks
Generally speaking there are three main disadvantages of using lambda functions:
1. cold startups, with something like 1 second of latency when the function hasn't been used in more than 30 min (rough estimation)
1. it can became more expensive than EC2 beyond certain usage level
1. vendor lock, specially with very fragmented design patterns that uses a specific api gateway for each function.

Solutions :

1. To avoid cold startup, there are many ways to warm up your function, like ping it every half hour, (if it is actually necessary )
1. If your app grows a lot, at some point you may want to migrate to EC2. In this example we are going to set everything up to be prepared for that moment [(check this article)](https://hackernoon.com/cons-of-serverless-architectures-7b8b570c19da).
1. To avoid vendor lock and to be ready to migrate, a good option is to mount a group of function inside one app, using FastAPI, Flask or other similar framework,  with only one API gateway working as a proxy, and your app managing the routes for different calls. This way you can migrate your whole app in one single step.

Other option is to create a container for your app, and run the container inside lambda. AFAIK is a bit faster to avoid the container and use it only if you want to migrate, anyway all the compatibility issues are solved by virtual environment and the right Python version inside Lambda

***
## Python apps for lambda

create virtual env
```bash
CODE
```
this is done by running **_create_env.sh_**


create a zip file with all the content of **/env/lib/Python3.7/sit-packages/** copied at the same level of the main file of the project, this way Python can call every library without any special path.

In this case we copy the content of **/app** and **/env/lib/Python3.7/sit-packages/** to **/temp/**, then you can create a zip file to upload to S3
```bash
CODE
```
this is done when you run **_upload.sh_**

Remember to add a handler for Lambda, in this case, we use Mangum. There are other options, like chalice, the aws-Python-micro-web-framework, AFAIK there is no advantage over FastAPI+Mangum, and if you use chalice you may want to consider the vendor lock risk.
```Python
CODE
```
check the usage example of Mangum in **/app/hello_lambda.py**

***

## Terraform


[check]( https://www.terraform.io/docs/providers/aws/index.html)



run `terraform init`

run `terraform apply`

run `terraform destroy`


### Terraform output

can use the output for other automation tasks or scripts:

    $ terraform output -raw deployment_invoke_url
    https://example.url/for/yor/api/endoint


or get a JSON outpu:

$ terraform output -ra

    $ terraform output -json
    {
      "deployment_invoke_url": {
        "sensitive": false,
        "type": "string",
        "value": "https://4yr90px2ua.execute-api.sa-east-1.amazonaws.com/test"
      },
      "lambda": {
        "sensitive": true,
        "type": "string",
        "value": "arn:aws:lambda:sa-east-1:189743987374:function:my_lambda_NAME:$LATEST"
      }
    }

### Ping Test for your API


## Desploy
inside the root directory of the project run:

    cmod +x upload.sh
    ./upload.sh
