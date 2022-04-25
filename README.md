# terraform-aws

AWS Provider を用いた Terraform のサンプル集です。

## 命名

https://blog.pepese.com/terraform-naming/

## サンプル

リポジトリルート配下にディレクトリを切って、それぞれ Terraform プロジェクトとしてサンプルを作成しています。  
サンプルは以下の通りです。

### ベースプロジェクトサンプル

- `basic-flat`
  - AWS Modules を用いない、フラットに `.tf` ファイルを配置したプロジェクトです
  - **小規模** かつ **環境分割が不要** な場合の構成です
  - 変数は極力 `locals` としています
  - `aws_vpc` のみをサンプルとして作成します
- `basic-flat-env`
  - AWS Modules を用いない、フラットに `.tf` ファイルを配置したプロジェクトです
  - **小規模** かつ **環境分割が必要** な場合の構成です
  - `.tfvars` ファイルで環境差分を吸収します（例： `terraform plan -var-file=env-prd.tfvars` ）
  - `aws_vpc` のみをサンプルとして作成します
- `basic-modules`
  - AWS Modules を用いて複数環境構築可能にしたプロジェクトです
  - **大規模** かつ **環境分割が必要** な場合な場合の構成です
  - `modules` ディレクトリ配下に共通で参照するモジュールを、 `env` 配下に各環境のディレクトリ（ `prd` や `stg` など）を作成します
  - `aws_vpc` のみをサンプルとして作成します

### AWS リソースサンプル

- `ec2-asg-apache`
  - Auto Scaling Group 設定をした EC2 上に User Data で Apache と CloudWatch Agent を設定するプロジェクトです
  - ベースプロジェクトは `basic-flat`
- `rds-mysql`
  - RDS for MySQL と DB アクセス用の簡易な Bastion を構築するプロジェクトです
  - ベースプロジェクトは `basic-flat`
- `aurora-postgres`
  - Aurora PostgreSQL と DB アクセス用の簡易な Bastion を構築するプロジェクトです
  - ベースプロジェクトは `basic-flat`
- `elasticache-redis`
  - ElastiCache for Redis と DB アクセス用の簡易な Bastion を構築するプロジェクトです
  - ベースプロジェクトは `basic-flat`
- `ecs-appmesh-blue-green`
  - ECS と App Mesh を使って Blue/Green デプロイメントを行うことができるプロジェクトです
  - VPC Endpoint もつけてます
  - ベースプロジェクトは `basic-flat`
- `iam-forced-mfa`
  - MFA 強制の IAM User を作成するプロジェクトです
  - 作成する IAM User は `Developers` グループに所属し、 CodeArtifact 、 CloudWatch Logs へのアクセス権限があります
  - ベースプロジェクトは `basic-flat`
- `ecs`
  - ECS と RDS for PostgreSQL を構築するプロジェクトです
  - 要メンテ
- `eks`
  - Terraform と `eksctl` で EKS を構築するプロジェクトです
  - 要メンテ