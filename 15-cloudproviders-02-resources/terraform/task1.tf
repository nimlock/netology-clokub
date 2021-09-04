resource "aws_s3_bucket" "b" {
  bucket = "ivan-netology-sept2021"
  acl    = "public-read"

  tags = {
    Name    = "My bucket"
  }
}

resource "aws_s3_bucket_object" "img" {
  bucket = aws_s3_bucket.b.id
  key    = "my_image.png"
  source = "image.png"
  acl    = "public-read"

  etag = filemd5("image.png")
}

data "aws_s3_bucket" "b" {
  bucket = aws_s3_bucket.b.id
}

data "aws_s3_bucket_object" "img" {
  bucket = aws_s3_bucket.b.id
  key    = aws_s3_bucket_object.img.id
}

# output "s3_bucket" {
#   value = data.aws_s3_bucket.b
# }

# output "s3_object" {
#   value = data.aws_s3_bucket_object.img
# }
