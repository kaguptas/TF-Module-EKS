# TF-Module-EKS
This module provides the Terraform logic needed to deploy an EKS cluster with out-of-the-box addons. It also allows the flexibility for users to pick-and-choose additional addons to install on their cluster.

## How to Use

### Prerequisites

1. Terraform >= 1.0.0
2. Local VPN connection to connect to the cluster.

### Features

Out-of-the-box "basic" addons:
- EKS-managed addons (kube-proxy, coredns, vpc-cni)
- EKS-managed nodes: a small EKS-managed node group.
- Karpenter - the autoscaling solution intended to host most of your workloads. Both the Controller and a default provisioner is deployed. Multiple provisioners can be deployed for custom karpenter-node requirements.
- IRSA: Allows K8s service accounts in the EKS cluster to use AWS IAM roles. Some are provided for Slmetrics.
- Cluster encryption: via KMS.

## Usage Notes

**Live Repo**:
https://github.com/kaguptas/TF-Live-EKS

This repo is where you create cluster-specific directories that invoke this versioned module.

**Versioning**:
Each significant change to this module is tagged via Git tags. To use a specific version, you can reference it in your `source` parameter.
  ```
  module "eks" {
      source  = "git@github.com:kaguptas/TF-Module-EKS.git?ref=tag_version"
      ...
  }
  ```

It is good practice to invoke a specific version of the module in your live repo in order to ensure your infrastructure remains consistent as the module is iterated on.

**Tagging your module commits**:
After each MR, tag the repo so that you can pin your live repo's to a specific user-friendly version tag:

To tag a new version:
```
git tag -a v0.2 -m "v0.2 Description of changes"
git push origin v0.2
```
