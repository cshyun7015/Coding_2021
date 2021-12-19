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