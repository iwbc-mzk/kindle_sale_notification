# ------------------------------------------------------------------------------------------------------
# Local Variables
# ------------------------------------------------------------------------------------------------------
locals {
  runtime    = "python3.10"
  lambda_dir = "${path.module}/../aws_lambda"
}

# ------------------------------------------------------------------------------------------------------
# Archive Files
# ------------------------------------------------------------------------------------------------------
data "archive_file" "archive_fetch_items" {
  type             = "zip"
  source_file      = "${local.lambda_dir}/fetch_items.py"
  output_path      = "${local.lambda_dir}/fetch_items.zip"
  output_file_mode = "0666"
}

data "archive_file" "archive_publish_sns_message" {
  type             = "zip"
  source_file      = "${local.lambda_dir}/publish_sns_message.py"
  output_path      = "${local.lambda_dir}/publish_sns_message.zip"
  output_file_mode = "0666"
}

# ------------------------------------------------------------------------------------------------------
# Lambda Functions
# ------------------------------------------------------------------------------------------------------
resource "aws_lambda_function" "fetch_items" {
  filename      = data.archive_file.archive_fetch_items.output_path
  function_name = "ksn_fetch_items"
  role          = aws_iam_role.ksn_fetch_items.arn

  source_code_hash = data.archive_file.archive_fetch_items.output_base64sha256
  runtime          = local.runtime
  handler          = "fetch_items.lambda_handler"
  timeout          = 10

  environment {
    variables = {
      queue_url : aws_sqs_queue.ksn_queue.url,
      table_name : aws_dynamodb_table.ksn.name
    }
  }
}

resource "aws_lambda_function" "price_checker" {
  function_name = "ksn_price_checker"
  role          = aws_iam_role.ksn_price_checker.arn
  image_uri     = data.external.build_push_price_check.result.image_uri
  package_type  = "Image"

  memory_size = 1024
  timeout     = 60

  environment {
    variables = {
      queue_url : aws_sqs_queue.ksn_queue.url,
      table_name : aws_dynamodb_table.ksn.name,
    }
  }
}

resource "aws_lambda_function" "publish_sns_message" {
  filename      = data.archive_file.archive_publish_sns_message.output_path
  function_name = "ksn_publish_sns_message"
  role          = aws_iam_role.ksn_publish_sns_message.arn

  source_code_hash = data.archive_file.archive_publish_sns_message.output_base64sha256
  runtime          = local.runtime
  handler          = "publish_sns_message.lambda_handler"
  timeout          = 10

  environment {
    variables = {
      table_name = aws_dynamodb_table.ksn.name,
      topic_arn  = aws_sns_topic.kindle_sale_notification.arn
    }
  }
}
