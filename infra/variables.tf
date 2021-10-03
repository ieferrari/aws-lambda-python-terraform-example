variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "sa-east-1"
}

variable "lambda_name" {
  description = "The name for the new Lambda function"
  default     = "my_lambda_NAME"
}

variable "api_gateway_name" {
  description = "The name for the new Api Gateway"
  default     = "ServerlessExample"
}
