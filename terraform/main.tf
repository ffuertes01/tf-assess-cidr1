provider "aws" {
  region = var.aws_region
}

# resource "aws_s3_bucket" "app_bucket" {
#   bucket = "${var.env_name}-${var.app_name}-bucket"

# #   # Enable static website hosting
# #   website {
# #     index_document = "index.html"
# #     error_document = "error.html"
# #   }

#   tags = {
#     Name        = "${var.env_name}-${var.app_name}-bucket"
#     Environment = var.env_name
#     Project     = var.app_name
#   }
# }

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

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket_policy.app_policy]
}

# Working policy
# resource "aws_s3_bucket_policy" "app_policy" {
#   bucket = aws_s3_bucket.app_bucket.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action    = ["s3:GetObject"]
#         Effect    = "Allow"
#         Resource  = "${aws_s3_bucket.app_bucket.arn}/*"
#         Principal = "*"
#       }
#     ]
#   })
# }

resource "aws_s3_bucket_policy" "app_policy" {
  bucket = aws_s3_bucket.app_bucket.id
  policy = data.aws_iam_policy_document.app_data_policy.json
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

resource "aws_s3_object" "app_files" {
  for_each = fileset("${var.build_dir}", "**")

  bucket = aws_s3_bucket.app_bucket.id
  key    = each.value
  source = "${var.build_dir}/${each.value}"
  etag   = filemd5("${var.build_dir}/${each.value}")
  content_type = each.value == "index.html" ? "text/html" : null
}
