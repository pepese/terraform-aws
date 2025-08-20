# terraform-aws / multi-modules

## 構成

```bash
multi-modules/
├── workspaces  # 環境差分用ディレクトリ
│   ├── [env]     # 環境毎に分割されたディレクトリ
│   ├── prd       # prd 環境用ディレクトリ
│   │   ├── backend.tf    # バックエンドの設定ファイル
│   │   ├── data.tf       # data参照の設定ファイル
│   │   ├── locals.tf     # ローカル変数の設定ファイル
│   │   ├── main.tf       # モジュールの呼び出しを記述するファイル
│   │   ├── providers.tf  # プロバイダーの設定ファイル
│   │   └── terraform.tf  # バージョン制約の設定ファイル
│   ├── stg       # stg 環境用ディレクトリ
│   │   ├── backend.tf
│
└── modules     # 各環境共通で利用する Terraform Module
    ├── [module]  # Terraform Module毎に分割されたディレクトリ
    ├── ecs-frontend  # ecs-frontendモジュール：FrontendのECS/Fargateに関する resource を記述するファイルを配置
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf   # outputし、他のモジュール・リソースから参照されるデータを記載
    ├── ecs-backend   # ecs-backendモジュール：BackendのECS/Fargateに関する resource を記述するファイルを配置
    │   ├── main.tf
```

## ディレクトリ・ファイル構成

### workspaces/[env] 配下

| 名前         | 説明                                                                                                         |
|--------------|--------------------------------------------------------------------------------------------------------------|
| backend.tf   | tfstate設定用ファイル。                                                                                |
| data.tf      | data参照の設定ファイル。                                                                                       |
| locals.tf    | ローカル変数の設定ファイル。（ルートモジュールでは基本的に外部から値を注入することがないためvariableではなくlocal変数を利用） |
| main.tf      | モジュールの呼び出しを記述するファイル。                                                                       |
| providers.tf | プロバイダーの設定ファイル。                                                                                   |
| terraform.tf | Terraformおよびプロバイダーバージョン制約の設定ファイル。                                                         |

### modules/[module] 配下

| 名前         | 説明                                                                                                         |
|--------------|--------------------------------------------------------------------------------------------------------------|
| main.tf   | モジュールの内容を記述するファイル。可読性向上のための分割は許容する。なお、`terraform.required_providers` ブロックの記載は必須。 |
| variables.tf      | モジュール内変数の設定ファイル。                                                                                       |
| outputs.tf      | モジュールで作成したAWSリソースの情報をルートモジュールから参照可能にする変数を定義するファイル。               |

以下、`terraform.required_providers` の記載例。

```terraform:main.tf
# 通常の例
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}
# Aliasを受け取る場合の例
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      configuration_aliases = [ aws.alternate ]
    }
  }
```

## 命名規約

### 基本

| 対象                       | 命名方法      |
|----------------------------|--------------|
| ファイル名                  | ケバブケース  |
| ディレクトリ名              | ケバブケース  |
| リソース ID（resourceやdata） | スネークケース|
| リソース名（name属性やNameタグ） | ケバブケース  |
| 変数名                     | スネークケース|

### AWSリソースタグ

`tags` 属性のある `resource` には以下のタグを必ずつける。

- `System` ：システムを識別可能な文字列
- `Service` : システム内のコンポーネント・マイクロサービスなどを識別するサービス名
- `Env` ：環境名（dev, tst, stg, prd）
- `Terraform` ：`“true”`、 Terraform で作成した目印
- `Name` ：AWSリソース名の命名規則に従う

### AWSリソースID

ケバブケースで命名する。詳細は以下の通り。  
なお、 `[service]` はコンポーネント・マイクロサービスなどの名称、 `[resourceType]` はAWSリソースタイプを表す。

- CloudWatch/AutoScalingポリシー以外
  - 『**[service]**』
  - 例
    - `auth_api`
- CloudWatch Logs（ロググループ）
  - 『**[service]_[resourceType]**』
  - 例
    - `auth_api_ecs`
    - `auth_rds_cluster`
- CloudWatch Logs メトリクスフィルタ
  - 『**[service]_[resourceType]_log_{errorLevel}**』
  - 例
    - `auth_api_ecs_log_warn`
    - `auth_rds_cluster_log_error`
- CloudWatch Alarm (ログ)
  - 『**[service]_[resourceType]_log_{errorLevel}**』
  - 例
    - `auth_api_ecs_log_error`
- CloudWatch Alarm (ログ以外)
  - 『**[service]_{resourceType}_[metricName]_{low/high}_{errorLevel/scaleType}**』
  - 例
    - `auth_api_ecs_CPUUtilization_high_warn`
    - `auth_api_ecs_CPUUtilization_high_scaleOut`
- AutoScalingポリシー
  - 『**[service]_{resourceType}_[metricName]_{low/high}_{scaleType}**』
  - 例
    - `auth_api_ecs_CPUUtilization_high_scale_out`

なお、Terraform Modulesを用いてサービス名（auth-apiなど）によらない汎用的なモジュールを作成した場合、リソースIDは以下のように命名する。

- 以下の場合以外
  - 『**main**』
  - 例
    - VPCやECS Clusterなどはユニークになりやすい -> `main`
- 何らかの対象にアタッチ・利用するAWSリソース（IAM Role、Security Group、KMS Key、など）
  - 『**[resourceType]**』
  - 例
    - Security Group： `alb`
- Security Group Rule
  - 『**[resourceType]_[ingress/egress/self]**』
  - 例
    - `alb_ingress`
    - `alb_self`
- CloudWatch Logs（ロググループ）
  - 『**[resourceType]**』
  - 例
    - `alb`
    - `ecs`
    - `rds_cluster`
- CloudWatch Logs メトリクスフィルタ
  - 『**[resourceType]_log_{errorLevel}**』、『**[resourceType]_[ログ種別]_log_{errorLevel}**』
  - 例
    - `alb_log_error`
    - `ecs_log_error`
    - `elasticache_engine_log_error`
    - `elasticache_engine_slow_log_error`
- CloudWatch Alarm (ログ)
  - 『**[resourceType]_log_{errorLevel}**』、『**[resourceType]_[ログ種別]_log_{errorLevel}**』
  - 例
    - `alb_log_error`
    - `ecs_log_error`
    - `elasticache_engine_log_error`
    - `elasticache_engine_slow_log_error`
- CloudWatch Alarm (ログ以外)
  - 『**{resourceType}_[metricsName]_{low/high}_{errorLevel/scaleType}**』
  - 例
    - `CPUUtilization_high_warn`
    - `ecs_CPUUtilization_high_scaleout`
- CloudWatch Metrics
  - 『**{resourceType}_[metricName]_{low/high}**』
  - 例
    - `CPUUtilization_low`
    - `ecs_CPUUtilization_high`
- AutoScalingポリシー
  - 『**{resourceType}_[metricsName]_{low/high}_{scaleType}**』
  - 例
    - `ecs_CPUUtilization_high_scaleout`

### AWSリソース名

AWSリソース名は、resource の name 属性、AWSリソースタグの Name を指し、それぞれ異なることが無い様に命名する。  
なお aws_db_instance のように identifier を使用しなければならないケースは注意すること。

ケバブケースで命名する。詳細は以下の通り。  
なお、`[system]` はシステム名・ID、 `[env]` は環境名、 `[service]` はコンポーネント・マイクロサービスなどの名称、 `[resourceType]` はAWSリソースタイプを表す。

- CloudWatch/AutoScalingポリシー/SSMパラメータ以外
  - 『**[system]-[env]-[service]**』、『**[system]-[env]-[service]{-任意}**』
  - 例
    - `pepese-prd-auth-api`
    - `pepese-prd-web-admin`
- CloudWatch Logs（ロググループ）、CloudWatch Metrics 名前空間
  - 『**/[resourceType]/[system]-[env]-[service]**』
  - 例
    - `/ecs/pepese-prd-auth-api`
    - `/rds-cluster/pepese-prd-auth`
- CloudWatch Logs メトリクスフィルタ
  - 『**[system]-[env]-[service]-[resourceType]-log-{errorLevel}**』
  - 例
    - `pepese-prd-auth-api-ecs-log-warn`
    - `pepese-prd-auth-rds-cluster-log-error`
- CloudWatch Metrics
  - 『**[system]-[env]-[service]-[resourceType]-log-{errorLevel}-count**』
  - 例
    - `pepese-prd-auth-api-ecs-log-warn-count`
    - `pepese-prd-auth-rds-cluster-log-error-count`
- CloudWatch Alarm (ログ)
  - 『**[system]-[env]-[service]-[resourceType]-log-{errorLevel}**』
  - 例
    - `pepese-prd-auth-api-ecs-log-warn`
    - `pepese-prd-auth-rds-cluster-log-error`
- CloudWatch Alarm (ログ以外)
  - 『**[system]-[env]-[service]-{resourceType}-[metricName]-{low/high}-{errorLevel/scaleType}**』
  - 例
    - `pepese-prd-auth-api-ecs-CPUUtilization-high-warn`
    - `pepese-prd-asuth-rds-cluster-CPUUtilization-high-scaleOut`
- AutoScalingポリシー
  - 『**[system]-[env]-[service]-{resourceType}-[metricName]-{low/high}-{scaleType}**』
  - 例
    - `pepese-prd-auth-api-ecs-CPUUtilization-high-scale-out`
    - `pepese-prd-auth-rds-cluster-CPUUtilization-high-scaleOut`
- SSMパラメータ、KMSキー
  - 『**/[resourceType]など/[system]-[env]-[service]/任意**』
  - 例
    - `/rds-cluster/pepese-prd-auth/id`

## Terraform管理外のAWSリソース

以下のAWSリソースはTerraformの管理外で手動作成・削除する。

- ステートファイルを保存する S3 バケット
- ACMで管理する主ドメインの証明書
  - 主ドメイン以外の証明書はTerraformでよい
- ECSのタスク定義
  - ただし、初期構築はTerraformで行うものとし、タスク定義の更新については別管理のタスク定義ファイルにて行う
- Code兄弟（CodeBuildなど）の設定ファイル
- 秘匿化情報を含むため手動管理するSSMパラメータ
- Session Managerの以下の設定
  - Idle session timeout
  - RunAS設定
  - Shell profiles
- パラメータストア暗号化用のKMSキー
  - Terraform管理にするとTerraformコードの適用が煩雑(※)となるため管理外とする
    - Terraformコードを適用してKMSキーを作成→パラメータストアを手動設定→Terraformコードを適用してパラメータストアを参照する各種リソースを作成、のような手順になるため