resource "aws_iam_policy" "remote_json_policy" {
  count = var.enable_lb_controller ? 1 : 0
  name        = "${var.eks_name}-AWSLoadBalancerControllerIAMPolicy"
  description = "Policy fetched from GitHub for AWS Load Balancer Controller"
  
  # Access the response body from the data source
  policy = file("${path.module}/iam_policy.json")
}

# Create the IAM Role for the Controller
resource "aws_iam_role" "aws_lbc" {
  count = var.enable_lb_controller ? 1 : 0
  name = "aws-load-balancer-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })
}

# Attach the required AWS Load Balancer Controller policy
# You can fetch the official JSON from AWS or use a data source
resource "aws_iam_role_policy_attachment" "aws_lbc_attach" {
  count      = var.enable_lb_controller ? 1 : 0
  role       = aws_iam_role.aws_lbc[0].name
  policy_arn = aws_iam_policy.remote_json_policy[0].arn # Ensure this policy exists or create it
}

# Make sure to install and enable EKS Pod Identity Agent add-on.

resource "aws_eks_pod_identity_association" "aws_lbc" {
  count = var.enable_lb_controller ? 1 : 0
  cluster_name    = var.eks_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.aws_lbc[0].arn
  # Logic to wait for the agent to be ready
  depends_on = [aws_eks_addon.pod_identity]
}

resource "helm_release" "aws_lbc" {
  count = var.enable_lb_controller ? 1 : 0
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts" 
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
#  version    = "1.7.2"

set = [
    {
    name  = "clusterName"
    value = var.eks_name
  },

 {
    name  = "serviceAccount.create"
    value = "true"
  },

  {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  },
    {
    name  = "vpcId"
    value = "dev-main"
  },
    {
    name  = "region"
    value = "us-east-1"
  }
]
  # Ensure association is active before the pods start
  depends_on = [
    aws_eks_pod_identity_association.aws_lbc,
    aws_iam_role_policy_attachment.aws_lbc_attach
    ]

}
