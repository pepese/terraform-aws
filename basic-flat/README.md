# terraform-aws / basic-flat

## 構成

```bash
basic-flat-env/
├── main.tf        # Terraformバージョン、Provider、Backend、変数、locals変数、Module、Outputsの設定
│
├── sample-vpc.tf  # resource（sampleサービスのVPC） の設定を記述
├── ...            # resource（その他） の設定を記述
```

## 使い方

```bash
# 対象のサンプルへ移動
$ cd basic-flat
$ pwd
path/to/basic-flat

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

# 個別のリソースの差分確認
$ terraform plan

# 個別のリソースの適用
$ terraform apply

# 個別のリソースの削除
$ terraform destroy
```