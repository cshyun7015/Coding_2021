# aws eks update-kubeconfig --region ap-northeast-2 --name ib07441-eks-cluster

resource "aws_eks_cluster" "Eks_Cluster" {
  name     = "ib07441-eks-cluster"
  role_arn = aws_iam_role.Iam_Role_Eks.arn

  vpc_config {
    subnet_ids = [aws_subnet.Subnet_Private_01.id, aws_subnet.Subnet_Private_02.id]
  }

#   encryption_config {
#     provider {
#       key_arn = aws_kms_key.Kms_Key.arn
#     }
#     resources = []
#   }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.Iam_Role_Policy_Attachment_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.Iam_Role_Policy_Attachment_AmazonEKSVPCResourceController,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.Eks_Cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.Eks_Cluster.certificate_authority[0].data
}

resource "aws_eks_node_group" "Eks_Node_Group" {
  cluster_name    = aws_eks_cluster.Eks_Cluster.name
  node_group_name = "ib07441-eks-node-group"
  node_role_arn   = aws_iam_role.Iam_Role_Eks_Node_Group.arn
  subnet_ids      = [aws_subnet.Subnet_Private_01.id, aws_subnet.Subnet_Private_02.id]

  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.Iam_Role_Policy_Attachment_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.Iam_Role_Policy_Attachment_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.Iam_Role_Policy_Attachment_AmazonEC2ContainerRegistryReadOnly,
  ]

  remote_access {
    ec2_ssh_key = var.default_key_name
  }
}

data "tls_certificate" "Ekscluster_Identity_Oidc_Issuer" {
  url = aws_eks_cluster.Eks_Cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "Iam_Openid_Connect_Provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.Ekscluster_Identity_Oidc_Issuer.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.Eks_Cluster.identity[0].oidc[0].issuer
}

resource "aws_eks_addon" "Eks_Addon" {
  cluster_name = aws_eks_cluster.Eks_Cluster.name
  addon_name   = "vpc-cni"
  
  service_account_role_arn = aws_iam_role.Iam_Role_VPC_CNI.arn
}

resource "aws_key_pair" "KeyPair" {
  key_name   = "IB07441_EC2_SSH_Key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCaw4lByVXTd5s+u3vs5zjWDzhPaidTyu+b6H77nI7+qplG6V3sTAVSTgV6U7wB//cZx9SgDq05OAk7U7MZZ1SJ91oUsYuibYaVc4I7BnHSY4RgE2NQjEmHuyZSBugCgG/v0pcEvarOKqxH6wp/ATHxDFd5sn8dwxUjTz5JiR74bOuDgzgBTQr8opraZL46wMyMIT5AD5vpbn3U1qNOOBJOlHvruRIRHG1Nu6DVY0GoSf2fjHZHEriNYt+utjulLfjm2uRZWNjsuMVMYeMpVeuVtVIjgrMD+UGyrfxFaIlUtvn2yndvUf6CA7MPGRKkGA9sENX5vc5M/QW/Vh/HF7EUAgdR7HdYnCClyQ2Py4ftTIhXdw799C5Z+4Gbks2bn67ORPIMTT67dBy6BT++IIHVrgup+NFf8NseNft3S3ABxD/NW4NDP+dF5fCUY7QVAPoOMVmi/ogT9zL1VDsI5BM5Yx6BxxM5opACBN8honTaCTvlPCxjN6nYqNHh1sIrenk= zogzog@SKCC20N01233"
}

variable default_key_name {
  default = "IB07441_EC2_SSH_Key"
}