resource "aws_sqs_queue" "s3_upload" {
  name       = "${var.name}-sqs"
  fifo_queue = false
}

resource "aws_sqs_queue_policy" "s3_upload" {
  queue_url = aws_sqs_queue.s3_upload.url
  policy    = data.aws_iam_policy_document.s3_upload_queue.json
}

data "aws_iam_policy_document" "s3_upload_queue" {
  statement {
    sid    = "myaccountsqs"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "sqs:*"
    ]
    resources = [
      aws_sqs_queue.s3_upload.arn
    ]
  }

  statement {
    sid    = "Allow-SNS-SendMessage"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      aws_sqs_queue.s3_upload.arn
    ]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.s3_upload.arn]
    }

  }
}
