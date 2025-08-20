locals {
  common_param = {
    account_id    = "xxxxxx"         # AWS Account ID
    system        = "pepese"         # システム名・ID
    env           = "prd"            # 環境名（prd, stg、devなど）
    base_name     = "pepese-prd"     # ベース名（AWSリソース名は「[system]-[env]-[service_name]」形式）
    region        = "ap-northeast-1" # リージョン
    acm_region    = "us-east-1"      # ACM用リージョン
    backup_region = "ap-southeast-1" # バックアップ用リージョン
  }
}
