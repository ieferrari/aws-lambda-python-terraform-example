output "lambda" {
  # sensitive = true # use this for password and other secrets
  value = "${aws_lambda_function.my_lambda_func.qualified_arn}"
}


output "deployment_invoke_url" {
  description = "Deployment invoke url"
  value       = aws_api_gateway_deployment.example.invoke_url
}
