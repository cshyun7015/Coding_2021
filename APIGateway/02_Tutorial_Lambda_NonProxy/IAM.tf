resource "aws_iam_role" "IamRole_LambdaTrustRole" {
  name = "IB07441_IamRole_Lambda"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
            {
              "Sid": "",
              "Effect": "Allow",
              "Principal": {
                "Service": [
                  "lambda.amazonaws.com"
                ]
              },
              "Action": "sts:AssumeRole"
            }
  ]
}
EOF
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

resource "aws_iam_policy" "IamPolicy_Lambda_Policy" {
  name        = "IB07441-Lambda-Addition-Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ddb:PutItem"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "IamRolePolicyAttachment_Lambda" {
  role       = aws_iam_role.IamRole_LambdaTrustRole.name
  policy_arn = aws_iam_policy.IamPolicy_Lambda_Policy.arn
}