## Common ##
data "aws_iam_policy_document" "ecs_task_execution_role_assume_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

## ECS Task Execution Role ## 
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-ecsTaskExecutionRole"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_assume_policy.json
}

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name = "${var.name}-ecs-task-execution"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = data.aws_iam_policy_document.ecs_task_execution_policy_document.json
}

data "aws_iam_policy_document" "ecs_task_execution_policy_document" {

  statement {
    sid = "Logs"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*"
    ]
  }
  statement {
    sid = "EcrContents"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]

    resources = [
      "*"
    ]
  }

}

## ECS Task Role ##
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name}-ecsTaskRole"

  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_assume_policy.json
}


resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "${var.name}-ecs-task"
  role = aws_iam_role.ecs_task_role.id

  policy = data.aws_iam_policy_document.ecs_task_policy_document.json
}

data "aws_iam_policy_document" "ecs_task_policy_document" {

  statement {
    sid = "Logs"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "ECSPermissions"

    actions = [
      "ecs:ExecuteCommand",
      "ecs:DescribeTasks"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "AWSCLIECSExec"

    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "sqs"

    actions = [
      "sqs:SendMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:ReceiveMessage",
      "sqs:GetQueueUrl"
    ]

    resources = [
      aws_sqs_queue.s3_upload.arn
    ]
  }

  statement {
    sid = "s3"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      aws_s3_bucket.example.arn,
      "${aws_s3_bucket.example.arn}/*"
    ]
  }

}

##---------Lambda------------##
resource "aws_iam_role" "lambda" {
  name = "${var.lambda_name}-lambda-role"

  assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Action": "sts:AssumeRole",
                "Effect": "Allow"
            }
        ]
    }
    EOF
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "${var.lambda_name}-lambda-policy"
  role = aws_iam_role.lambda.id

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "LambdaCloudwatchGroup",
              "Effect": "Allow",
              "Action": "logs:CreateLogGroup",
              "Resource": "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:*"
          },
          {
              "Sid": "LambdaCloudwatchLogging",
              "Effect": "Allow",
              "Action": [
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
              ],
              "Resource": "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.lambda_name}:*"
          },
          {
              "Sid": "LambdaSQS",
              "Effect": "Allow",
              "Action": "sqs:getqueueattributes",
              "Resource": "*"
          },
          {
              "Sid": "LambdaECS",
              "Effect": "Allow",
              "Action": "ecs:RunTask",
              "Resource": "*"
          },
          {
              "Sid": "LambdaIamPass",
              "Effect": "Allow",
              "Action": "iam:PassRole",
              "Resource": "*"
          },
          {
            "Sid": "LambdaSNS", 
             "Effect": "Allow",
            "Action": [
              "sns:Publish",
              "sns:Subscribe"
            ],
            "Resource": ["${aws_sns_topic.s3_upload.arn}"]
          }
      ]
    }
    EOF
}
