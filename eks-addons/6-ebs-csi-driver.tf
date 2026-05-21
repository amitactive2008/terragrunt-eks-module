resource "aws_iam_role" "ebs_csi_driver_role" {
  count = var.enable_ebs_csi_driver ? 1 : 0
  name  = "${var.eks_name}-ebs-csi-driver-role"

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

resource "aws_iam_role_policy_attachment" "ebs_csi_attachment" {
  # This ensures policies attach as long as the driver is enabled
  for_each = var.enable_ebs_csi_driver ? toset([
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]) : []

  policy_arn = each.value
  role       = aws_iam_role.ebs_csi_driver_role[0].name
}

resource "aws_eks_pod_identity_association" "ebs_csi" {
  count           = var.enable_ebs_csi_driver ? 1 : 0
  cluster_name    = var.eks_name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa" # Standard name for this addon
  role_arn        = aws_iam_role.ebs_csi_driver_role[0].arn
}

resource "aws_eks_addon" "ebs_csi" {
  count        = var.enable_ebs_csi_driver ? 1 : 0
  cluster_name = var.eks_name
  addon_name   = "aws-ebs-csi-driver"
  
  # Ensure the policy is attached before the addon tries to start
  depends_on = [aws_iam_role_policy_attachment.ebs_csi_attachment]
}
