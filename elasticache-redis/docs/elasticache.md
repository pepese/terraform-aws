# ElastiCache(Redis) 設定

## 接続確認

踏み台から以下のように確認する。

```bash
$ redis-cli -h system-[env]-sample-redis.system.local --tls -a 'password' -p 6379 ping
PONG

$ redis-cli -h system-[env]-sample-redis.system.local --tls -a 'password' -c -p 6379
> quit
```