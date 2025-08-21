# VPC Module

VPC（Virtual Private Cloud）を作成するためのTerraformモジュールです。

## 構成

- ap-northeast-1リージョンの3 AZ構成
- Public SubnetとPrivate Subnetを各AZに作成
- Internet Gatewayを設定してPublic Subnetからインターネットへのアクセスを提供
- NAT GatewayをPublic Subnetに配置してPrivate Subnetからのインターネットアクセスを提供
- 主要なAWSサービス用のVPC Endpointを設定

## リソース

### ネットワーク基盤
- VPC
- Internet Gateway
- Public Subnet × 3（各AZ）
- Private Subnet × 3（各AZ）
- NAT Gateway × 3（各Public Subnetに配置）
- Elastic IP × 3（NAT Gateway用）
- Route Table（Public用 × 1、Private用 × 3）

### VPC Endpoints
- S3（Gateway型）
- DynamoDB（Gateway型）
- EC2（Interface型）
- ECR API（Interface型）
- ECR DKR（Interface型）
- ECS（Interface型）
- ECS Agent（Interface型）
- ECS Telemetry（Interface型）
- CloudWatch Logs（Interface型）
- CloudWatch Monitoring（Interface型）
- SSM（Interface型）
- SSM Messages（Interface型）
- EC2 Messages（Interface型）
- KMS（Interface型）
- RDS（Interface型）
- STS（Interface型）

## 変数

| 名前 | 説明 | 型 | デフォルト値 | 必須 |
|------|------|----|-----------| ---- |
| system | システム名 | `string` | - | はい |
| env | 環境名 | `string` | - | はい |
| domain | ドメイン名 | `string` | - | はい |
| vpc_cidr | VPCのCIDRブロック | `string` | `"10.0.0.0/16"` | いいえ |
| public_subnet_cidrs | Public SubnetのCIDRブロックリスト | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]` | いいえ |
| private_subnet_cidrs | Private SubnetのCIDRブロックリスト | `list(string)` | `["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]` | いいえ |

## 出力

| 名前 | 説明 |
|------|------|
| vpc_id | VPCのID |
| vpc_cidr_block | VPCのCIDRブロック |
| internet_gateway_id | Internet GatewayのID |
| public_subnet_ids | Public SubnetのIDリスト |
| private_subnet_ids | Private SubnetのIDリスト |
| public_subnet_cidrs | Public SubnetのCIDRブロックリスト |
| private_subnet_cidrs | Private SubnetのCIDRブロックリスト |
| nat_gateway_ids | NAT GatewayのIDリスト |
| nat_gateway_ips | NAT GatewayのElastic IPアドレスリスト |
| public_route_table_id | Public Route TableのID |
| private_route_table_ids | Private Route TableのIDリスト |
| vpc_endpoint_security_group_id | VPC Endpoint用Security GroupのID |
| vpc_endpoint_s3_id | S3 VPC EndpointのID |
| vpc_endpoint_dynamodb_id | DynamoDB VPC EndpointのID |

## 使用例

```hcl
module "vpc" {
  source = "../modules/vpc"

  system = "pepese"
  env    = "prd"
  domain = "network"

  vpc_cidr               = "10.0.0.0/16"
  public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
```
