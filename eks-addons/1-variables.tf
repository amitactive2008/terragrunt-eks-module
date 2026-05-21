variable "env" {
  description = "Environment name."
  type        = string
}

variable "eks_name" {
  description = "Name of the cluster."
  type        = string
}

variable "enable_eks_oidc" {
  description = "Determines whether we want to enable oidc"
  type        = bool
  default     = false
}
variable "enable_cluster_autoscaler" {
  description = "Determines whether to deploy cluster autoscaler"
  type        = bool
  default     = false
}
variable "enable_eks_pod_identity" {
  description = "Determines whether pod identity enable or not"
  type        = bool
  default     = false
}
variable "pod_identity_addon_version" {
  description = "pod_identity_addon_version"
  default = "v1.3.10-eksbuild.3"
  type        = string
}

variable "aws-vpc-cni-version" {
  description = "aws-vpc-cni-version"
  default = "v1.21.2-eksbuild.2"
  type        = string
}

variable "enable_ebs_csi_driver" {
  description = "Enable ebs csi driver"
  type        = bool
  default     = false
}
variable "enable_lb_controller" {
  description = "Enable lb-controller"
  type        = bool
  default     = false
}

variable "cluster_autoscaler_helm_verion" {
  description = "Cluster Autoscaler Helm verion"
  type        = string
}

variable "openid_provider_arn" {
  description = "IAM Openid Connect Provider ARN"
  type        = string
}
variable "vpc_id" {
  description = "The VPC ID where the EKS cluster is deployed."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where the cluster resides."
  type        = string
}
