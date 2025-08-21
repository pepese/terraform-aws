# GitHub Copilot

本モジュールは Github Copilot を利用して作成しました。  
設定は以下の通りです。

- モード：Agent
- モデル：Claude Sonnet 4
- コンテキスト：multi-modules/README.md

## プロンプト１

コンテキストのREADME.mdの内容に従って、vpcモジュールを作成してください。
内容は以下の通りです。

- VPC（Virtual Private Cloud）を作成するためのモジュール
- リージョンは `ap-northeast-1` 3 AZ 構成とする
- VPC およびサブネットの CIDR は 変数化する
- サブネットは Public サブネットと Private サブネットをそれぞれ作成
- インターネットゲートウェイを作成し VPC にアタッチ
- Private サブネットに Nat Gateway を設定してインターネットにアクセスできるように設定
- VPC Endpoint は設定可能なものは全て有効化
- なお、各AWSリソースのパラメータのデフォルト設定値は特別な理由がない限り変更したり、変数化したりしないこと

## プロンプト２（修正が必要だったため）

aws_vpc の enable_dns_hostnames と enable_dns_support はデフォルト値のままで、特に設定は不要です。
aws_subnet の map_public_ip_on_launch はデフォルト値のままで、特に設定は不要です。
サブネットやルートテーブルの `Name` タグの値は count ではなく、AZ名（ `a` 、 `c` 、 `d` ）を使用して命名してください。