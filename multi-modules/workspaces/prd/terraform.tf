terraform {
  required_version = "~> 1.12.0" # Terraform のバージョン
  required_providers {           # Provider の設定
    aws = {
      source  = "hashicorp/aws"
      version = "6.9.0"          # AWS Provider のバージョン
    }
    # 以下にその他利用するプロバイダーを追加
    # http = {
    #   source  = "hashicorp/http"
    #   version = "3.4.5"
    # }
    # tls = {
    #   source  = "hashicorp/tls"
    #   version = "4.0.6"
    # }
  }
}
