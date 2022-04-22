apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: ${cluster_name}
  region: ap-northeast-1
  version: "${cluster_version}"
  tags:
    Project: ${project}
    Environment: ${environment}
vpc:
  id: ${vpc}
  subnets:
    public:
      ap-northeast-1a:
        id: ${public_subnet_a}
      ap-northeast-1c:
        id: ${public_subnet_c}
      ap-northeast-1d:
        id: ${public_subnet_d}
    private:
      ap-northeast-1a:
        id: ${cluster_subnet_a}
      ap-northeast-1c:
        id: ${cluster_subnet_c}
      ap-northeast-1d:
        id: ${cluster_subnet_d}
nodeGroups:
  - name: ${cluster_name}
    instanceType: ${instance_type}
    labels:
      type: eks-cluster
    minSize: 1
    desiredCapacity: 2
    maxSize: 2
    securityGroups:
      attachIDs:
        - ${security_group}
    privateNetworking: true
    iam:
      attachPolicyARNs:
        - arn:aws:iam::aws:policy/AmazonS3FullAccess
        - arn:aws:iam::aws:policy/CloudFrontFullAccess
        - arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
        - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
      withAddonPolicies:
        autoScaler: true
        ebs: true
        albIngress: true
    tags:
      Project: ${project}
      Environment: ${environment}