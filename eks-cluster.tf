module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  # create asg with 3 nodes
  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = 2
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t2.medium"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}


data "aws_iam_policy_document" "kubectl_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::809031430406:root"]
    }
  }
}
resource "aws_iam_role" "eks_kubectl_role" {
  name               = "example-kubectl-access-role"
  assume_role_policy = "${data.aws_iam_policy_document.kubectl_assume_role_policy.json}"
}
resource "aws_iam_role_policy_attachment" "eks_kubectl-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks_kubectl_role.name}"
}
resource "aws_iam_role_policy_attachment" "eks_kubectl-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks_kubectl_role.name}"
}
resource "aws_iam_role_policy_attachment" "eks_kubectl-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks_kubectl_role.name}"
}