# ElastiCache(Redis) 設定

## スローログの有効化

現状の Terraform では以下の Issue にある通り、 ElastiCache のログを CloudWatch Logs へ送信することができない。

- https://githubmemory.com/repo/hashicorp/terraform-provider-aws/issues/20023

そのため、 Terraform による構築後、以下の手順で手動設定を行う。

1. マネージメントコンソールにログイン
2. 「ElastiCache ダッシュボード」 -> 「Redis」ページへ遷移し、対象のクラスタを選択
3. 「ログ」タブを選択して、スローログに関する以下の設定を行う
  - スローログを有効にする -> はい
  - ログの形式 -> JSON
  - 送信先のタイプ -> CloudWatch Logs
  - ログの送信先、新規/既存 -> 既存
  - ログの送信先、ロググループ名 -> 「"/aws/elasticache/system-[env]-sample/redis/slowlog"」
    - `sample-cloudwatch.tf` にて環境に応じて構築されているので、それを選択する

AWS CLI で実行する場合は以下の通り。

```bash
$ aws elasticache modify-replication-group \
      --apply-immediately \
      --replication-group-id system-[env]-sample \
      --log-delivery-configurations '{
        "LogType":"slow-log", 
        "DestinationType":"cloudwatch-logs",  
        "DestinationDetails":{ 
          "CloudWatchLogsDetails":{ 
            "LogGroup":"/aws/elasticache/system-[env]-sample/redis/slowlog"
          } 
        }, 
        "LogFormat":"json" 
      }'
```

## 接続確認

踏み台から以下のように確認する。

```bash
$ redis-cli -h system-[env]-sample-redis.system.local --tls -a 'password' -p 6379 ping
PONG

$ redis-cli -h system-[env]-sample-redis.system.local --tls -a 'password' -c -p 6379
> quit
```