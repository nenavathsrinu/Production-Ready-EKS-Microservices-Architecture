# Production 3-Tier HA Architecture - Quick Reference Guide

## 🎯 Architecture at a Glance

```
┌─────────────────────────────────────────────────────────────┐
│                    END USERS (Internet)                      │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTPS
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    ROUTE53 (DNS)                            │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    WAF (Web ACL)                            │
│              • OWASP Protection                             │
│              • Rate Limiting                                │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│         AWS REGION: ap-south-1 (Mumbai)                      │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │              VPC (10.0.0.0/16)                          │ │
│ │                                                          │ │
│ │  ┌────────────────────────────────────────────────────┐  │ │
│ │  │  PUBLIC SUBNETS                                   │  │ │
│ │  │  ┌──────────────┐      ┌──────────────┐          │  │ │
│ │  │  │  AZ-1       │      │  AZ-2        │          │  │ │
│ │  │  │  • ALB      │      │  • NAT GW   │          │  │ │
│ │  │  │  • NAT GW   │      │              │          │  │ │
│ │  │  └──────────────┘      └──────────────┘          │  │ │
│ │  └────────────────────────────────────────────────────┘  │ │
│ │                                                          │ │
│ │  ┌────────────────────────────────────────────────────┐  │ │
│ │  │  PRIVATE SUBNETS (Application Tier)               │  │ │
│ │  │  ┌──────────────┐      ┌──────────────┐          │  │ │
│ │  │  │  AZ-1       │      │  AZ-2        │          │  │ │
│ │  │  │  • App EC2  │      │  • App EC2   │          │  │ │
│ │  │  │  (ASG)      │      │  (ASG)       │          │  │ │
│ │  │  └──────────────┘      └──────────────┘          │  │ │
│ │  └────────────────────────────────────────────────────┘  │ │
│ │                                                          │ │
│ │  ┌────────────────────────────────────────────────────┐  │ │
│ │  │  DATABASE SUBNETS                                 │  │ │
│ │  │  ┌──────────────┐      ┌──────────────┐          │  │ │
│ │  │  │  AZ-1       │      │  AZ-2        │          │  │ │
│ │  │  │  • RDS      │◄────►│  • RDS       │          │  │ │
│ │  │  │  Primary    │ Repl │  Standby     │          │  │ │
│ │  │  └──────────────┘      └──────────────┘          │  │ │
│ │  └────────────────────────────────────────────────────┘  │ │
│ │                                                          │ │
│ │  ┌────────────────────────────────────────────────────┐  │ │
│ │  │  SHARED SERVICES                                    │  │ │
│ │  │  • S3 (via VPC Endpoint)                           │  │ │
│ │  │  • KMS                                             │  │ │
│ │  │  • CloudWatch                                     │  │ │
│ │  │  • Systems Manager                                │  │ │
│ │  │  • EventBridge                                    │  │ │
│ │  └────────────────────────────────────────────────────┘  │ │
│ └──────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

---

## 📊 Request Flow Diagram

```
1. USER REQUEST
   │
   ├─► Route53 (DNS Resolution)
   │
   ├─► WAF (Security Filtering)
   │   ├─► Blocks malicious traffic
   │   └─► Allows legitimate requests
   │
   ├─► ALB (Load Balancing)
   │   ├─► Health Check
   │   └─► Route to healthy instance
   │
   ├─► EC2 Application Server
   │   ├─► Process business logic
   │   │
   │   ├─► RDS Database (if needed)
   │   │   ├─► Primary (writes)
   │   │   └─► Standby (replication)
   │   │
   │   ├─► S3 (via VPC Endpoint)
   │   │   └─► Get/Put objects
   │   │
   │   └─► EventBridge (events)
   │
   └─► RESPONSE BACK TO USER
```

---

## 🏗️ Component Matrix

| Component | Location | Purpose | High Availability |
|-----------|----------|---------|-------------------|
| **Route53** | Global | DNS resolution | Multi-region |
| **WAF** | Regional | Web security | Regional redundancy |
| **ALB** | Public Subnets (Multi-AZ) | Load balancing | Multi-AZ |
| **NAT Gateway** | Public Subnets (per AZ) | Outbound internet | One per AZ |
| **EC2 Instances** | Private Subnets (Multi-AZ) | Application servers | Auto Scaling Group |
| **RDS Primary** | Database Subnet (AZ-1) | Database writes | Multi-AZ with standby |
| **RDS Standby** | Database Subnet (AZ-2) | Database replica | Auto failover |
| **S3** | Regional | Object storage | 99.999999999% durability |
| **KMS** | Regional | Encryption keys | Regional redundancy |
| **CloudWatch** | Regional | Monitoring | Regional redundancy |

---

## 🔒 Security Layers

```
Layer 1: WAF
   ├─► OWASP Top 10 Protection
   ├─► Rate Limiting
   └─► IP Filtering

Layer 2: Network Security
   ├─► Security Groups (Instance level)
   ├─► Network ACLs (Subnet level)
   └─► Private Subnets (No direct internet)

Layer 3: Data Security
   ├─► Encryption at Rest (KMS)
   ├─► Encryption in Transit (TLS/SSL)
   └─► IAM Roles (No hardcoded credentials)

Layer 4: Access Control
   ├─► IAM Policies (Least Privilege)
   ├─► VPC Endpoints (Private AWS access)
   └─► SSM Session Manager (Secure access)
```

---

## 📈 Scaling Strategy

### **Application Tier Scaling**

```
Traffic Increase
   │
   ├─► CloudWatch detects high CPU/Memory
   │
   ├─► Auto Scaling Group triggers
   │
   ├─► New EC2 instance launched
   │
   ├─► Health check passes
   │
   └─► ALB routes traffic to new instance
```

**Scaling Metrics:**
- CPU Utilization > 70%
- Memory Usage > 85%
- Request Count threshold
- Custom CloudWatch metrics

**Scaling Limits:**
- Min: 2 instances (one per AZ)
- Desired: 2 instances
- Max: 10 instances

### **Database Scaling**

**Vertical Scaling:**
- Upgrade instance class
- Increase storage
- Minimal downtime

**Horizontal Scaling:**
- Add read replicas (read scaling)
- Multi-AZ (high availability)

---

## 🚨 Failover Scenarios

### **Scenario 1: Application Server Failure**

```
1. Instance becomes unhealthy
   │
2. ALB health check fails
   │
3. Traffic routes to healthy instance
   │
4. Auto Scaling launches replacement
   │
5. New instance joins ALB
   │
Result: Zero downtime
```

### **Scenario 2: Database Primary Failure**

```
1. RDS detects primary failure
   │
2. Standby promoted to primary (< 60s)
   │
3. DNS updated automatically
   │
4. Application reconnects
   │
5. New standby created
   │
Result: < 2 minutes downtime
```

### **Scenario 3: Entire AZ Failure**

```
1. AZ-1 fails completely
   │
2. ALB routes to AZ-2 instances
   │
3. Database standby becomes primary
   │
4. System operates at reduced capacity
   │
5. Auto Scaling launches instances in healthy AZ
   │
Result: System continues operating
```

---

## 💰 Cost Breakdown (Estimated)

| Component | Monthly Cost (USD) | Notes |
|-----------|-------------------|-------|
| **ALB** | ~$20 | Base cost + LCU |
| **EC2 Instances** | ~$150-300 | t3.medium, 2 instances |
| **RDS Multi-AZ** | ~$200-400 | db.t3.medium, Multi-AZ |
| **NAT Gateway** | ~$65 | 2 NAT Gateways |
| **S3** | ~$10-50 | Based on storage/requests |
| **CloudWatch** | ~$20-50 | Metrics, logs, alarms |
| **WAF** | ~$5-30 | Based on requests |
| **Data Transfer** | ~$20-100 | Varies by usage |
| **Total** | **~$490-1,000/month** | Production estimate |

**Cost Optimization Tips:**
- Use Reserved Instances for EC2/RDS (30-50% savings)
- S3 lifecycle policies for old data
- VPC endpoints reduce data transfer costs
- Right-size instances based on actual usage

---

## 🔧 Key Configuration Values

### **VPC Configuration**
- **CIDR**: 10.0.0.0/16
- **Public Subnets**: 10.0.0.0/24, 10.0.1.0/24
- **Private Subnets**: 10.0.10.0/24, 10.0.11.0/24
- **Database Subnets**: 10.0.20.0/24, 10.0.21.0/24

### **Auto Scaling Configuration**
- **Min Size**: 2
- **Desired Size**: 2
- **Max Size**: 10
- **Health Check**: ELB
- **Cooldown**: 300 seconds

### **RDS Configuration**
- **Engine**: PostgreSQL
- **Multi-AZ**: Enabled
- **Backup Retention**: 7 days
- **Encryption**: Enabled (KMS)
- **Public Access**: Disabled

### **ALB Configuration**
- **Type**: Application Load Balancer
- **Scheme**: Internet-facing
- **Health Check Path**: /health
- **Health Check Interval**: 30 seconds
- **SSL/TLS**: Enabled (HTTPS)

---

## 📋 Checklist for Team Review

### **Architecture Review**
- [ ] Multi-AZ deployment confirmed
- [ ] Security groups reviewed
- [ ] Network ACLs configured
- [ ] Encryption enabled (at rest & in transit)
- [ ] Backup strategy defined

### **High Availability**
- [ ] Auto Scaling configured
- [ ] Health checks enabled
- [ ] Multi-AZ RDS configured
- [ ] NAT Gateway redundancy (per AZ)
- [ ] Failover tested

### **Security**
- [ ] WAF rules reviewed
- [ ] IAM roles follow least privilege
- [ ] Security groups are restrictive
- [ ] VPC endpoints configured
- [ ] KMS key rotation enabled

### **Monitoring**
- [ ] CloudWatch alarms configured
- [ ] Log aggregation set up
- [ ] Dashboard created
- [ ] Alerting configured
- [ ] Cost monitoring enabled

### **Documentation**
- [ ] Architecture diagram updated
- [ ] Runbooks created
- [ ] Disaster recovery plan documented
- [ ] Team training completed

---

## 🎓 Key Terms Explained

**Multi-AZ (Multi-Availability Zone)**
- Deploying resources across multiple data centers
- Provides high availability and fault tolerance

**Auto Scaling Group (ASG)**
- Automatically adds/removes EC2 instances
- Based on demand and health checks

**Application Load Balancer (ALB)**
- Distributes incoming traffic across multiple targets
- Layer 7 (HTTP/HTTPS) load balancing

**VPC Endpoint**
- Private connection to AWS services
- Traffic stays within AWS network (no internet)

**Multi-AZ RDS**
- Primary database in one AZ
- Standby replica in another AZ
- Automatic failover capability

**WAF (Web Application Firewall)**
- Protects web applications from common exploits
- Filters and monitors HTTP/HTTPS traffic

---

## 📞 Support & Resources

**AWS Documentation:**
- [VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [RDS Multi-AZ](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html)
- [ALB User Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)

**Architecture Resources:**
- AWS Well-Architected Framework
- AWS Architecture Center
- AWS Solutions Library

---

**Quick Reference Version:** 1.0  
**Last Updated:** 2024  
**Region:** ap-south-1 (Mumbai)

