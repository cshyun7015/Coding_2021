resource "aws_iam_role" "IamRole_EC2TrustRole" {
  name = "IB07441_IamRole_EC2"
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
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM", 
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", 
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role", 
    "arn:aws:iam::aws:policy/CloudWatchFullAccess", 
  ]
}

resource "aws_iam_instance_profile" "IamInstanceProfile_EC2" {
  name = "IB07441_IamInstanceProfile_EC2"
  role = aws_iam_role.IamRole_EC2TrustRole.name
}

resource "aws_iam_role" "IamRole_ECSTrustRole" {
  name = "IB07441_IamRole_ECS"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
            {
              "Sid": "",
              "Effect": "Allow",
              "Principal": {
                "Service": "ecs.amazonaws.com"
              },
              "Action": "sts:AssumeRole"
            }
  ]
}
EOF
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

resource "aws_iam_role" "IamRole_CodeBuildTrustRole" {
  name = "IB07441_IamRole_CodeBuild"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
            {
              "Sid": "",
              "Effect": "Allow",
              "Principal": {
                "Service": "codebuild.amazonaws.com"
              },
              "Action": "sts:AssumeRole"
            }
  ]
}
EOF
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCodePipelineReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ]
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
          },
          {
              "Action": [
                  "codecommit:*",
                  "codedeploy:*"
              ],
              "Effect": "Allow",
              "Resource": "*"
          }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "IamRolePolicyAttachment_Pipeline" {
  role       = aws_iam_role.IamRole_PipelineTrustRole.name
  policy_arn = aws_iam_policy.IamPolicy_CodePipelinePolicy.arn
}

resource "aws_iam_role" "IamRole_CodeDeployTrustRole" {
  name = "IB07441_IamRole_CodeDeploy"
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
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM", 
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", 
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role", 
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
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

resource "aws_iam_role" "IamRole_CodeDeployECSTrustRole" {
  name = "IB07441_IamRole_CodeDeployECS"
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
}

resource "aws_iam_policy" "IamPolicy_CodeDeployECS_Policy" {
  name        = "IB07441-Code-Deploy-ECS-Addition-Policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ecs:DescribeServices",
                "ecs:CreateTaskSet",
                "ecs:UpdateServicePrimaryTaskSet",
                "ecs:DeleteTaskSet",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:ModifyRule",
                "lambda:InvokeFunction",
                "cloudwatch:DescribeAlarms",
                "sns:Publish",
                "s3:GetObject",
                "s3:GetObjectVersion"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "iam:PassRole"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "iam:PassedToService": [
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "IamRolePolicyAttachment_CodeDeployECS" {
  role       = aws_iam_role.IamRole_CodeDeployECSTrustRole.name
  policy_arn = aws_iam_policy.IamPolicy_CodeDeployECS_Policy.arn
}

resource "aws_iam_role" "IamRole_EcsTaskTrustRole" {
  name = "IB07441_IamRole_EcsTask"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "IamPolicy_EcsTask_Policy" {
  name        = "IB07441-Ecs-Task-Addition-Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "IamRolePolicyAttachment_EcsTask" {
  role       = aws_iam_role.IamRole_EcsTaskTrustRole.name
  policy_arn = aws_iam_policy.IamPolicy_EcsTask_Policy.arn
}