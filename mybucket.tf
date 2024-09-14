#3. s3 bucket configuration
resource "aws_s3_bucket" "my_bucket" {
  bucket  = "ryana-bucket3"
  tags    = {
	Name          = "MyS3Bucket"
	Environment    = "vibha"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.my_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  
}
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.my_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
     }
     bucket_key_enabled = true
       
    
  }
}