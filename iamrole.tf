resource "aws_iam_role" "read_role" {
  name = "readrole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "read_attachment" {
  role       = aws_iam_role.read_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "read_profile" {
  name = "read_profile"
  role = aws_iam_role.read_role.name
}

resource "aws_instance" "read_instance" {
  ami           = "ami-04cdc91e49cb06165"
  instance_type = "t3.micro"
  key_name  	= "vibhapardeep"
  
  iam_instance_profile = aws_iam_instance_profile.read_profile.name

  tags = {
    Name = "readinstance"
  }
}

resource "aws_s3_bucket_policy" "read_bucket_policy" {
  bucket = "ryana-bucket3"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.read_role.name}"
        },
        "Action": [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::ryana-bucket3",
          "arn:aws:s3:::ryana-bucket3/*"
        ]
      }
    ]
  })
}

data "aws_caller_identity" "current" {}