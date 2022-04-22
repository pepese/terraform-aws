# AWS 設計

ここでは、 Terraform 管理内・外リソースついて記す。

## Terraform 管理リソース

## modules/main_vpc.tf

- VPCに割り当てるセグメントは prd は `10.0.0.0/16` 、 stg は `10.1.0.0/16`
  - 以下のIPはカッコの用途のため利用できない（前4つと最後1つ）（ prd の場合）
    - `10.0.0.0`（ネットワークアドレス）
    - `10.0.0.1`（VPC ルーター）
    - `10.0.0.2`（DNS へのマッピング用）
    - `10.0.0.3`（将来の利用のためにAWSで予約）
    - `10.0.255.255` （ネットワークブロードキャストアドレス）
- サブネットは冗長化のため 2 つ利用し、セグメントはそれぞれ以下（ prd の場合）
  - Public サブネット AZ-A: `10.0.0.0/24`
  - Public サブネット AZ-C: `10.0.1.0/24`
  - Protected サブネット AZ-A: `10.0.64.0/24`
  - Protected サブネット AZ-C: `10.0.65.0/24`
  - Private サブネット AZ-A: `10.0.128.0/24`
  - Private サブネット AZ-C: `10.0.129.0/24`
  - Management サブネット AZ-A: `10.0.192.0/24`
  - Management サブネット AZ-C: `10.0.193.0/24`
- なお、Public/Protected/Privateの意味は以下の通り
  - Public：インターネットゲートウェイ指定のあるサブネット。LB置き場。
  - Protected：NAT経由でインターネット接続できるサブネット。AP置き場。Public サブネットからのみアクセスを許可。
  - Private：インターネットゲートウェイもNAT経由の指定のないサブネット。DB置き場。Protected サブネットからのみ接続を許可。
  - Management：Public サブネットと同等であるが、LBは設置せず bastion や管理用のインスタンスを配備する。
- 各 AZ に 1 つずつ EIP を作成し、 NAT Gatewayに設定

### modules/main_lb.tf

- Public サブネット に作成
- PORT 443 および 80 のみ受け付け、80 へのアクセスは 443 にリダイレクト
- Target Group に関するリソースは `main_ec2.tf` にて作成

### modules/main_ec2.tf

- Autoscaling Group の 1 台構成で、自動復旧にのみ対応
- Protected サブネット に作成
- `lb` のセキュリティグループからのみアクセス可能な設定
- `UserData` を利用して EC2 の設定を実施
    - `UserData` は `modules/tpl/ec2_user_data.sh.tpl`
    - `UserData` の実行ログは `/var/log/cloud-init-output.log`
- `aws_lb_listener_rule` の `listenerrule_blockage_hostname` は閉塞用
    - 普段はコメントアウトしているが、閉塞したいときにアクティブ化

### modules/main_rds.tf

- MySQL 5.7 の Multi-AZ Failover Cluster 構成

### modules/main_route53.tf

- Host Zone は手動作成
- サービス毎の名前解決 A レコードの追加
- RDS Endpoint を解決する Private Hosted Zone と CNAME レコードの追加

### modules/main_s3.tf

- EC2 へマウントする S3 Bucket の作成

### modules/main_waf.tf

- 日本からのリクエストのみ許可
- その他 AWS Managed Rule で本システムのスタックに関係するものを追加

### modules/main_cloudwatch.tf

- CloudWatch Log Group
    - EC2 へ CloudWatch エージェントを導入することが前提
- CloudWatch Alarm に EC2、RDS、LB で代表的なメトリクスを追加
- CloudWatch Alarm に EC2 のログ監視を追加
- なお、 Alarm は SNS と連携してアラートメールが送信される

### modules/main_sns.tf

- CloudWatch Alarm と連携するトピックを作成
- 上記トピックをサブスクライブし、アラートメールを送信


## Terraform 管理外リソース

以下の AWS リソースは Terraform ではなく、 Management Console等で手動で作成したものです。

- S3
    - `tfstate-sample` バケット： Terraform の State ファイル用
- IAM
    - 人が利用するユーザ・グループ・ロール・ポリシーは手動で作成
    - AWS リソース（ EC2 など）が利用するロール・ポリシーは Terraform で作成
- Route53
    - `sample.com` ドメイン
- ACM
    - `*.sample.com` ドメインの証明書
- CloudWatch
    - `certificate-expire` アラーム： `*.sample.com` ドメインの証明書の期限切れが近いことを知らせるアラーム
- Cloud9
    - 開発者が利用するインスタンス
    - EC2 への SSM Login