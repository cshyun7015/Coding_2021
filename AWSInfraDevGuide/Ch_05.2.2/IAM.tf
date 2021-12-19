resource "aws_iam_role" "IamRole_CodeDeployTrustRole" {
  name = "IB07441-Code-Deploy-Service-Role"
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
                  "codedeploy.amazonaws.com"
                ]
              },
              "Action": "sts:AssumeRole"
            }
  ]
}
EOF
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  ]

}

resource "aws_iam_policy" "IamPolicy_CodeDeploy_Policy" {
  name        = "IB07441-Code-Deploy-Addtion-Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
            {
              "Action": [
                "ec2:RunInstances",
                "ec2:CreateTags",
                "iam:PassRole"
              ],
              "Resource": ["*"],
              "Effect": "Allow"
            }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "IamRolePolicyAttachment_CodeDeploy" {
  role       = aws_iam_role.IamRole_CodeDeployTrustRole.name
  policy_arn = aws_iam_policy.IamPolicy_CodeDeploy_Policy.arn
}

resource "aws_iam_policy" "IamPolicy_EC2_Policy" {
  name        = "IB07441-Code-Deploy-EC2-Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
            {
              "Action": [
                "s3:Get*",
                "s3:List*"
              ],
              "Resource": ["*"],
              "Effect": "Allow"
            }
  ]
}
EOF
}

resource "aws_iam_role" "IamRole_EC2TrustRole" {
  name = "IB07441-Code-Deploy-EC2-Role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
            {
              "Sid": "",
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

resource "aws_iam_role_policy_attachment" "IamRolePolicyAttachment_EC2" {
  role       = aws_iam_role.IamRole_EC2TrustRole.name
  policy_arn = aws_iam_policy.IamPolicy_EC2_Policy.arn
}

resource "aws_iam_instance_profile" "IamInstanceProfile_EC2" {
  name = "IB07441_IamInstanceProfile_EC2"
  role = aws_iam_role.IamRole_EC2TrustRole.name
}

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