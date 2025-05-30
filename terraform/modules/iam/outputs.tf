output "cluster_role_arn" {
  description = "ARN of the EKS cluster service role"
  value       = aws_iam_role.cluster_role.arn
}

output "node_group_role_arn" {
  description = "ARN of the EKS node group role"
  value       = aws_iam_role.node_group_role.arn
}

output "ebs_csi_role_arn" {
  description = "ARN of the EBS CSI driver role"
  value       = aws_iam_role.ebs_csi_role.arn
}

output "load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller role"
  value       = aws_iam_role.load_balancer_controller_role.arn
} 