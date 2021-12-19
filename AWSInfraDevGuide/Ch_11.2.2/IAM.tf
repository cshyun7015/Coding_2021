resource "aws_iam_role" "IamRole_PipelineTrustRole" {
  name = "IB07441_PilelineTrustRole"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
            {
              "Sid": "1",
              "Effect": "Allow",
              "Principal": {
                "Service": [
                  "codepipeline.amazonaws.com"
                ]
              },
              "Action": "sts:AssumeRole"
            }
  ]
}
EOF
}

resource "aws_iam_policy" "IamPolicy_CodePipelinePolicy" {
  name        = "IB07441_CodePipelinePolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
            {
              "Action": [
                "s3:*"
              ],
              "Resource": ["*"],
              "Effect": "Allow"
            },
            {
              "Action": [
                "elasticbeanstalk:*",
                "cloudformation:*",
                "autoscaling:*",
                "elasticloadbalancing:*",
                "ec2:*"
              ],
              "Resource": ["*"],
              "Effect": "Allow"
            },
            {
              "Action": [
                "codepipeline:*",
                "iam:ListRoles",
                "iam:PassRole",
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision",
                "lambda:*",
                "sns:*",
                "ecs:*",
                "ecr:*"
              ],
              "Resource": "*",
              "Effect": "Allow"
            },
            {
              "Sid": "ConnectionsFullAccess",
              "Effect": "Allow",
              "Action": [
                "codestar-connections:CreateConnection",
                "codestar-connections:DeleteConnection",
                "codestar-connections:UseConnection",
                "codestar-connections:GetConnection",
                "codestar-connections:ListConnections",
                "codestar-connections:TagResource",
                "codestar-connections:ListTagsForResource",
                "codestar-connections:UntagResource"
              ],
              "Resource": "*"
            },
            {
              "Action": [
                  "codebuild:StartBuild",
                  "codebuild:StopBuild",
                  "codebuild:BatchGet*",
                  "codebuild:Get*",
                  "codebuild:List*",
                  "codecommit:GetBranch",
                  "codecommit:GetCommit",
                  "codecommit:GetRepository",
                  "codecommit:ListBranches",
                  "s3:GetBucketLocation",
                  "s3:ListAllMyBuckets"
              ],
              "Effect": "Allow",
              "Resource": "*"
          },
          {
              "Action": [
                  "logs:GetLogEvents"
              ],
              "Effect": "Allow",
              "Resource": "arn:aws:logs:*:*:log-group:/aws/codebuild/*:log-stream:*"
          }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "IamRolePolicyAttachment_Pipeline" {
  role       = aws_iam_role.IamRole_PipelineTrustRole.name
  policy_arn = aws_iam_policy.IamPolicy_CodePipelinePolicy.arn
}

resource "aws_iam_role" "IamRole_LambdaTrustRole" {
  name = "IB07441_LambdaTrustRole"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
            {
              "Sid": "1",
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
    "arn:aws:iam::aws:policy/AWSCodePipelineCustomActionAccess"
  ]
}

resource "aws_iam_policy" "IamPolicy_LambdaPolicy" {
  name        = "IB07441_LambdaPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1592118538836",
      "Action": [
        "logs:*",
        "sns:*",
        "SNS:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "IamRolePolicyAttachment_Lambda" {
  role       = aws_iam_role.IamRole_LambdaTrustRole.name
  policy_arn = aws_iam_policy.IamPolicy_LambdaPolicy.arn
}