resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.env_name}-${var.app_name}-bucket"

  tags = {
    Name        = "${var.env_name}-${var.app_name}-bucket"
    Environment = var.env_name
    Project     = var.app_name
  }
}

resource "aws_s3_bucket_website_configuration" "s3_web" {
  bucket = aws_s3_bucket.app_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

}

resource "aws_s3_bucket_public_access_block" "s3_public_block" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.app_bucket.id
  policy = data.aws_iam_policy_document.app_data_policy.json
  depends_on = [aws_s3_bucket_public_access_block.s3_public_block]
}

data "aws_iam_policy_document" "app_data_policy" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.app_bucket.arn}/*"
    ]

    condition {
      test     = "DateLessThan"
      variable = "aws:CurrentTime"
      values = ["2024-12-09T20:11:00Z"]
    }
  }
}

# Working:
# resource "aws_s3_object" "app_files" {
#   for_each = fileset("${var.build_dir}", "**")
#   bucket = aws_s3_bucket.app_bucket.id
#   key    = each.value
#   source = "${var.build_dir}/${each.value}"
#   etag   = filemd5("${var.build_dir}/${each.value}")
#   content_type  = lookup(
#     {
#       "html" = "text/html",
#       "css"  = "text/css",
#       "js"   = "application/javascript",
#       "json" = "application/json",
#       "txt"  = "text/plain",
#       "png"  = "image/png",
#       "jpg"  = "image/jpeg",
#       "svg"  = "image/svg+xml",
#       "map"  = "application/json" # Map files
#     },
#     length(split(".", each.value)) > 1 ? split(".", each.value)[length(split(".", each.value)) - 1] : "",
#     "application/octet-stream"
#   )
# }

# Working wit only index.html file
# resource "aws_s3_object" "app_files" {
#   for_each = fileset("${var.build_dir}", "**")

#   bucket = aws_s3_bucket.app_bucket.id
#   key    = each.value
#   source = "${var.build_dir}/${each.value}"
#   etag   = filemd5("${var.build_dir}/${each.value}")
#   content_type = each.value == "index.html" ? "text/html" : null
# }
