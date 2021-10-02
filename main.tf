# resource "null_resource" "temporary_copy" {
#   provisioner "local-exec" {
#     command = "echo 'hola mundo'; rm -rf ./temp; mkdir ./temp; cp -r ./env/lib/python3.7/site-packages/*  ./temp/ ; cp -r ./app/* ./temp/ "
#   }
# }

# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"


}

provider "archive" {
}





data "archive_file" "zip" {
  type        = "zip"
  source_dir = "temp"
  output_path = "my_lambda_func.zip"
}





data "aws_iam_policy_document" "policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

# #############################################################################
# S3 bucket configuration

resource "random_pet" "lambda_bucket_name" {
  prefix = "my-new-bucket-name"
  length = 4
}

resource "aws_s3_bucket" "examples-dev" {
  bucket = random_pet.lambda_bucket_name.id

  acl           = "private"
  force_destroy = true

  # provisioner "file" {
  #   source      = "./env/lib/python3.7/site-packages/*"
  #   destination = "./temp"
  # }
}


resource "aws_s3_bucket_object" "examples-dev" {
  bucket = aws_s3_bucket.examples-dev.id

  key    = "my_lambda_func.zip"
  source = data.archive_file.zip.output_path

  etag = filemd5(data.archive_file.zip.output_path)
}

# #############################################################################
# AWS-LAMBDA  configuration

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = "${data.aws_iam_policy_document.policy.json}"
}

resource "aws_lambda_function" "my_lambda_func" {
#  depends_on = [null_resource.temporary_copy]
  function_name = "my_lambda_NAME"


  # for S3 bucket
  s3_bucket = aws_s3_bucket.examples-dev.id
  s3_key    = aws_s3_bucket_object.examples-dev.key

  # for local file
  #filename         = "${data.archive_file.zip.output_path}"


  source_code_hash = "${data.archive_file.zip.output_base64sha256}"

  role    = "${aws_iam_role.iam_for_lambda.arn}"
  handler = "hello_lambda.handler"
  runtime = "python3.8"

  environment {
    variables = {
      greeting = "Hello, world!"
    }
  }
}

##################################################################
# https://registry.terraform.io/providers/hashicorp/aws/2.34.0/docs/guides/serverless-with-aws-lambda-and-api-gateway
# API gateway configuration

resource "aws_api_gateway_rest_api" "example" {
  name        = "ServerlessExample"
  description = "Terraform Serverless Application Example"
}


resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  parent_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}



resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.my_lambda_func.invoke_arn}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
  resource_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.my_lambda_func.invoke_arn}"
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  stage_name  = "test"
}
# ###################################################################
# Connect api gateway with lamda function  as a trigger

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.my_lambda_func.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.example.execution_arn}/*/*"
}
