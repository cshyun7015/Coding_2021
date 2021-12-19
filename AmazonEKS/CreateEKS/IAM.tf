resource "aws_iam_role" "Iam_Role_Eks" {
  name = "ib07441-eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "Iam_Role_Policy_Attachment_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.Iam_Role_Eks.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "Iam_Role_Policy_Attachment_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.Iam_Role_Eks.name
}

resource "aws_iam_role" "Iam_Role_Eks_Node_Group" {
  name = "ib07441-eks-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "Iam_Role_Policy_Attachment_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.Iam_Role_Eks_Node_Group.name
}

resource "aws_iam_role_policy_attachment" "Iam_Role_Policy_Attachment_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.Iam_Role_Eks_Node_Group.name
}

resource "aws_iam_role_policy_attachment" "Iam_Role_Policy_Attachment_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.Iam_Role_Eks_Node_Group.name
}

data "aws_iam_policy_document" "Iam_Policy_Document" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.Iam_Openid_Connect_Provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.Iam_Openid_Connect_Provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "Iam_Role_VPC_CNI" {
  assume_role_policy = data.aws_iam_policy_document.Iam_Policy_Document.json
  name               = "ib07441-vpc-cni-role"
}

resource "aws_iam_role_policy_attachment" "Iam_Role_Policy_Attachment_VPC_CNI" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.Iam_Role_VPC_CNI.name
}