# jenkins-sample

## 構成

### vpc

- VPCに割り当てるセグメントは `10.0.0.0/16`
  - 以下のIPはカッコの用途のため利用できない（前4つと最後1つ）
    - `10.0.0.0`（ネットワークアドレス）
    - `10.0.0.1`（VPC ルーター）
    - `10.0.0.2`（DNS へのマッピング用）
    - `10.0.0.3`（将来の利用のためにAWSで予約）
    - `10.0.255.255` （ネットワークブロードキャストアドレス）
- サブネットは冗長化のため 3 つ利用し、セグメントはそれぞれ以下
  - Public サブネット AZ-A: `10.0.0.0/24`
  - Public サブネット AZ-C: `10.0.1.0/24`
  - Public サブネット AZ-D: `10.0.2.0/24`
  - Protected サブネット AZ-A: `10.0.64.0/24`
  - Protected サブネット AZ-C: `10.0.65.0/24`
  - Protected サブネット AZ-D: `10.0.66.0/24`
  - Private サブネット AZ-A: `10.0.128.0/24`
  - Private サブネット AZ-C: `10.0.129.0/24`
  - Private サブネット AZ-D: `10.0.130.0/24`
- なお、Public/Protected/Privateの意味は以下の通り
  - Public：インターネットゲートウェイ指定のあるサブネット。LB置き場。
  - Protected：NAT経由でインターネット接続できるサブネット。AP置き場。Public サブネットからのみアクセスを許可。
  - Private：インターネットゲートウェイもNAT経由の指定のないサブネット。DB置き場。Protected サブネットからのみ接続を許可。

### lb

- Target Group に関するリソースは `jenkins-server` で作成

### jenkins-server

- `lb` のセキュリティグループからのみアクセス可能な設定
- Jenkins などの初期構築は `UserData` を利用
  - `UserData` の実行ログは `/var/log/cloud-init-output.log`
- Protected サブネット AZ-A の作成

EC2 へのアクセスは SSM Login を行うため、 Session Manager Plugin の導入が必要。

```bash
$ brew install --cask session-manager-plugin
```

以下でアクセス。

```bash
$ aws ssm start-session --target "i-xxxxxxxxxxxxxxxxx"
```
