# terraform-aws / basic-flat-env

## 構成

```bash
basic-flat-env/
├── main.tf        # Terraformバージョン、Provider、Backend、変数、Module、Outputsの設定
│
├── env-prd.tfvars # 環境差分に応じて変数に値を代入
├── env-stg.tfvars
├── env-xxx.tfvars
│
├── sample-vpc.tf  # resource（sampleサービスのVPC） の設定を記述
├── ...            # resource（その他） の設定を記述
```

## 使い方

```bash
# 対象のサンプルへ移動
$ cd basic-flat-env 
$ pwd
path/to/basic-flat-env

# 使用する AWS CLI のプロファイルを指定
$ export TF_VAR_profile=xxx

# プロジェクトの初期化
$ terraform init

# ファイルフォーマット
$ terraform fmt

# 個別のリソースのterraform 初期化
$ terraform init

# 個別のリソースの設定確認
$ terraform validate

# 個別のリソースの差分確認（環境に応じて -var-file オプションのファイルを変更）
$ terraform plan -var-file=env-prd.tfvars

# 個別のリソースの適用（環境に応じて -var-file オプションのファイルを変更）
$ terraform apply -var-file=env-prd.tfvars

# 個別のリソースの削除（環境に応じて -var-file オプションのファイルを変更）
$ terraform destroy -var-file=env-prd.tfvars
```