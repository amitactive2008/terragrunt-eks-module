resource "aws_iam_role" "test_oidc" {
  count = var.enable_eks_oidc ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role_policy.json
  name               = "eks-oidc-role"
}

resource "aws_iam_policy" "test-policy" {
  count = var.enable_eks_oidc ? 1 : 0
  name = "${var.eks_name}-eks-oidc-policy"

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

resource "aws_iam_role_policy_attachment" "test_attach" {
  count = var.enable_eks_oidc ? 1 : 0
  role       = aws_iam_role.test_oidc[0].name
  policy_arn = aws_iam_policy.test-policy[0].arn
}

output "test_policy_arn" {
  value = aws_iam_role.test_oidc[*].arn
}