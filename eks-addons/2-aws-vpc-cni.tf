resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = var.eks_name
  addon_name                  = "vpc-cni"
  addon_version               = var.aws-vpc-cni-version
  resolve_conflicts_on_create = "OVERWRITE"
}
# 1. Create the IAM Role
resource "aws_iam_role" "vpc_cni_role" {
  name = "${var.env}-${var.eks_name}-vpc-cni-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }]
  })
}


# 2. Attach the Managed CNI Policy
resource "aws_iam_role_policy_attachment" "vpc_cni_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.vpc_cni_role.name
}

# 3. Create the Pod Identity Association
resource "aws_eks_pod_identity_association" "vpc_cni" {
  cluster_name    = var.eks_name
  namespace       = "kube-system"
  service_account = "aws-node"
  role_arn        = aws_iam_role.vpc_cni_role.arn
}
