resource "aws_lambda_function" "myapp_lambda_function" {
  filename      = "${path.module}/lambda_out/${var.lambda_name}.zip"
  function_name = var.lambda_name
  role          = aws_iam_role.lambda.arn
  handler       = "${var.lambda_name}.lambda_handler"
  runtime       = "python3.10"


  environment {
    variables = {
      ECS_CLUSTER_NAME    = aws_ecs_cluster.main.name
      ECS_TASK_DEFINITION = aws_ecs_task_definition.main.id
      SQS_QUEUE_URL       = aws_sqs_queue.s3_upload.url
      SECURITY_GROUP_ID   = aws_security_group.ecs_task.id
      ECS_SUBNET_ID       = join(",", module.demo_ecs_vpc.private_subnets)
      SNS_TOPIC           = aws_sns_topic.s3_upload.arn
    }
  }
}


resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.myapp_lambda_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.s3_upload.arn
}


#create zip file
data "archive_file" "zip_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/lambda_out/${var.lambda_name}.zip"
}
