terraform {
  backend "s3" {
    bucket       = "pepese-prd--tfstate" # State ファイルを配置するバケット
    key          = "terraform.tfstate"   # State ファイルを配置するパス・ファイル名
    region       = "ap-northeast-1"      # S3のリージョン
    use_lockfile = true                  # State Lock
  }
}
