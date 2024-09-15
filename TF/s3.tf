resource "aws_s3_bucket" "example" {
  bucket = "computer-vision-${data.aws_caller_identity.current.account_id}"
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.example.id

  topic {
    topic_arn = aws_sns_topic.s3_upload.arn
    events    = ["s3:ObjectCreated:*"]

    filter_prefix = "video-in/"
    filter_suffix = ".mp4"
  }



}


