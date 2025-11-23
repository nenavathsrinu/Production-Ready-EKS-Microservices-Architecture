# EKS Microservices Architecture - Terraform Modules

This Terraform configuration deploys a complete EKS microservices architecture on AWS with modular, reusable components.

## 📁 Project Structure

```
terraform-eks-microservices/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output values
├── terraform.tfvars.example   # Example variable values
├── README.md                  # This file
└── modules/
    ├── vpc/                   # VPC, subnets, NAT, VPC endpoints
    ├── eks/                   # EKS cluster, node groups, add-ons
    ├── rds/                   # RDS PostgreSQL (primary + replica)
    ├── alb/                   # Application Load Balancer, WAF, Route53
    ├── security/              # KMS, IAM, Secrets Manager, Security Groups
    ├── monitoring/            # CloudWatch, X-Ray, Alarms
    ├── data/                  # DynamoDB, ElastiCache, S3
    ├── messaging/             # SQS, EventBridge
    └── cicd/                  # ECR, CodeBuild, CodePipeline
```

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **kubectl** installed (for EKS access)
4. **AWS IAM permissions** for creating resources

### Step 1: Configure Variables

Copy the example variables file and customize:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
aws_region = "ap-south-1"
environment = "prod"
project_name = "eks-microservices"

# ... customize other variables
```

### Step 2: Initialize Terraform

```bash
cd terraform-eks-microservices
terraform init
```

### Step 3: Review Plan

```bash
terraform plan
```

### Step 4: Apply Configuration

```bash
terraform apply
```

This will create:
- VPC with public/private/database subnets
- EKS cluster with managed node groups
- RDS PostgreSQL (primary + read replica)
- Application Load Balancer with WAF
- DynamoDB, ElastiCache, S3
- SQS, EventBridge
- ECR repositories, CI/CD pipeline
- Security groups, KMS keys, IAM roles
- CloudWatch monitoring

### Step 5: Configure kubectl

After deployment, configure kubectl:

```bash
aws eks update-kubeconfig --name eks-microservices-prod --region ap-south-1
```

## 📦 Modules Overview

### 1. VPC Module (`modules/vpc/`)

Creates:
- VPC with CIDR 10.0.0.0/16
- Public, private, and database subnets across 2 AZs
- Internet Gateway
- NAT Gateways (one per AZ)
- VPC Endpoints (S3, ECR API, ECR DKR, CloudWatch Logs)
- Route tables and associations

**Outputs:**
- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`
- `database_subnet_ids`

### 2. EKS Module (`modules/eks/`)

Creates:
- EKS cluster with encryption
- Managed node groups (configurable)
- IAM roles for cluster and nodes
- OIDC provider for IRSA
- Security groups
- EKS add-ons (VPC CNI, CoreDNS, kube-proxy)

**Outputs:**
- `cluster_id`
- `cluster_arn`
- `cluster_endpoint`
- `cluster_certificate_authority_data`

### 3. RDS Module (`modules/rds/`)

Creates:
- RDS PostgreSQL primary instance
- Read replica (optional)
- DB subnet group
- Parameter group
- Automated backups
- Multi-AZ deployment
- Performance Insights

**Outputs:**
- `rds_endpoint`
- `rds_read_replica_endpoint`

### 4. ALB Module (`modules/alb/`)

Creates:
- Application Load Balancer
- HTTPS listener (with SSL certificate)
- HTTP listener (redirects to HTTPS)
- Target groups
- WAF Web ACL (optional)
- Route53 record (optional)
- S3 bucket for ALB logs

**Outputs:**
- `alb_dns_name`
- `alb_arn`
- `default_target_group_arn`

### 5. Security Module (`modules/security/`)

Creates:
- KMS key for encryption
- Secrets Manager secret for RDS password
- Security groups (RDS, ElastiCache)
- IAM policies for EKS nodes

**Outputs:**
- `kms_key_id`
- `kms_key_arn`
- `rds_security_group_id`
- `elasticache_security_group_id`

### 6. Monitoring Module (`modules/monitoring/`)

Creates:
- CloudWatch log groups
- CloudWatch dashboard
- CloudWatch alarms (EKS CPU, ALB 5xx errors)
- X-Ray sampling rules

**Outputs:**
- `application_log_group_name`
- `dashboard_url`

### 7. Data Module (`modules/data/`)

Creates:
- DynamoDB table (sessions)
- ElastiCache Redis cluster (multi-AZ)
- S3 bucket (artifacts/config)

**Outputs:**
- `dynamodb_table_name`
- `elasticache_endpoint`
- `s3_bucket_name`

### 8. Messaging Module (`modules/messaging/`)

Creates:
- SQS queue with dead letter queue
- EventBridge custom bus
- EventBridge rules (order created, payment processed)

**Outputs:**
- `sqs_queue_url`
- `eventbridge_bus_name`

### 9. CI/CD Module (`modules/cicd/`)

Creates:
- ECR repositories (one per microservice)
- CodeBuild project
- CodePipeline (if GitHub configured)
- S3 bucket for artifacts
- IAM roles and policies

**Outputs:**
- `ecr_repository_urls`
- `codebuild_project_name`

## 🔧 Configuration

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `ap-south-1` |
| `environment` | Environment name | `prod` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `eks_cluster_version` | Kubernetes version | `1.28` |
| `rds_instance_class` | RDS instance type | `db.t3.medium` |

### Node Group Configuration

Edit `eks_node_groups` in `terraform.tfvars`:

```hcl
eks_node_groups = {
  node_group_1 = {
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    min_size       = 2
    max_size       = 10
    desired_size   = 2
    disk_size      = 20
  }
}
```

## 🔐 Security Best Practices

✅ **Encryption:**
- RDS encrypted at rest with KMS
- S3 buckets encrypted with KMS
- DynamoDB encrypted at rest
- ElastiCache encrypted in transit and at rest

✅ **Network Security:**
- Private subnets for EKS and databases
- Security groups with least privilege
- VPC endpoints for private AWS service access

✅ **Access Control:**
- IAM roles for EKS (IRSA)
- Secrets Manager for sensitive data
- WAF for application protection

## 📊 Monitoring

### CloudWatch Dashboard

Access the dashboard via:
```bash
terraform output dashboard_url
```

### Key Metrics Monitored

- EKS cluster CPU utilization
- ALB request count and response time
- RDS connection count and CPU
- Application logs in CloudWatch

## 🚢 CI/CD Pipeline

### ECR Repositories

The CI/CD module creates ECR repositories for:
- `api-gateway`
- `user-service`
- `order-service`
- `payment-service`
- `inventory-service`
- `notification-service`

### Build Process

1. Developer pushes code to GitHub
2. CodePipeline triggers
3. CodeBuild builds Docker images
4. Images pushed to ECR
5. ArgoCD (deployed separately) syncs and deploys

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy
```

**⚠️ Warning:** This will delete all resources including databases. Ensure you have backups!

## 📝 Notes

1. **RDS Password**: If not provided, a random password is generated. Store it securely.
2. **SSL Certificate**: Provide `alb_certificate_arn` for HTTPS. Create via ACM.
3. **GitHub Token**: Required for CodePipeline. Store in AWS Secrets Manager in production.
4. **State Management**: Configure S3 backend for team collaboration.
5. **Cost**: This architecture includes multiple resources. Monitor costs in AWS Cost Explorer.

## 🔗 Next Steps

After deployment:

1. **Deploy Applications**: Use ArgoCD or kubectl to deploy microservices
2. **Configure Ingress**: Set up ALB Ingress Controller or NGINX Ingress
3. **Service Mesh**: Deploy Istio or App Mesh
4. **Monitoring**: Set up Prometheus and Grafana
5. **Logging**: Configure Fluent Bit for log aggregation

## 📚 Additional Resources

- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)

## 🤝 Contributing

Feel free to submit issues or pull requests to improve this configuration.

## 📄 License

This configuration is provided as-is for educational and production use.

---

**Created for EKS Microservices Architecture Deployment**

