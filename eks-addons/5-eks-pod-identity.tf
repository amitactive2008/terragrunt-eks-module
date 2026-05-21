resource "aws_iam_role" "pod-identity-role" {
  count = var.enable_eks_pod_identity ? 1 : 0
  name  = "${var.eks_name}-eks-pod-identity-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "pod-identity-policy" {
  count = var.enable_eks_pod_identity ? 1 : 0
  name = "${var.eks_name}-eks-pod-identity-policy"

  policy = jsonencode({
    Statement = [{
      Action = [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:s3:::*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "pod-identity-role-policy-attachment" {
  count = var.enable_eks_pod_identity ? 1 : 0
  role       = aws_iam_role.pod-identity-role[0].name
  policy_arn = aws_iam_policy.pod-identity-policy[0].arn
}

output "pod-identity-policy_arn" {
  value = aws_iam_role.pod-identity-role[*].arn
}


data "aws_eks_cluster" "cluster" {
  name = var.eks_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_service_account_v1" "pod-identity-sa" {
  count = var.enable_eks_pod_identity ? 1 : 0
  metadata {
    name      = "${var.eks_name}-eks-pod-identity-sa"
    namespace = "default"
  }
}

resource "aws_eks_addon" "pod_identity" {
  count = var.enable_eks_pod_identity ? 1 : 0
  cluster_name  = var.eks_name
  addon_name    = "eks-pod-identity-agent"
  addon_version = var.pod_identity_addon_version # Use the latest version
}


resource "aws_eks_pod_identity_association" "example" {
  count = var.enable_eks_pod_identity ? 1 : 0
  cluster_name    = var.eks_name
  namespace       = "default"
  service_account = kubernetes_service_account_v1.pod-identity-sa[0].metadata[0].name
  role_arn        = aws_iam_role.pod-identity-role[0].arn
}
