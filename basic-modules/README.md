# terraform-aws / basic-modules

## 構成

```bash
basic-modules/
├── env         # 環境差分用ディレクトリ
│   ├── prd       # prd 環境用ディレクトリ
│   │   └── main.tf # 環境差分に応じたTerraformバージョン、Provider、Backend、変数、Module、Outputsの設定
│   ├── stg       # stg 環境用ディレクトリ
│   │   └── main.tf
│
└── modules     # 各環境共通で利用する resources をモジュール化
    ├── sample-vpc.tf  # resource（sampleサービスのVPC） の設定を記述
    ├── ...            # resource（その他） の設定を記述
    ├── variables.tf   # Module 内で利用する変数定義
    └── outputs.tf     # outputし、他のリソースから tfstate ファイル経由で参照されるデータを記載
```

## 使い方

```bash
# 対象のサンプルへ移動
$ cd basic-modules 
$ pwd
path/to/basic-modules

# 使用する AWS CLI のプロファイルを指定
$ export TF_VAR_profile=xxx

# プロジェクトの初期化
$ cd env/[環境]
$ terraform init

# ファイルフォーマット
$ cd env/[環境]
$ terraform fmt ../../modules
$ terraform fmt

# 個別のリソースのterraform 初期化
$ cd env/[環境]
$ terraform init

# 個別のリソースの設定確認
$ cd env/[環境]
$ terraform validate

# 個別のリソースの差分確認
$ cd env/[環境]
$ terraform plan

# 個別のリソースの適用
$ cd env/[環境]
$ terraform apply

# 個別のリソースの削除
$ cd env/[環境]
$ terraform destroy
```