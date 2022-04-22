# サーバ構築手順

「Amazon Linux 2 AMI (HVM), SSD Volume Type」( `ami-09ebacdc178ae23b7` ) をベースとし、後述のソフトウェアを導入する。


## MySQL Client

```bash
$ sudo yum localinstall https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
$ sudo yum-config-manager --disable mysql80-community
$ sudo yum-config-manager --enable mysql57-community
$ sudo yum install -y mysql-community-client
```

## Apache

```bash
$ sudo yum install -y httpd
$ sudo systemctl restart httpd
$ sudo systemctl enable httpd
$ yum info httpd
Loaded plugins: extras_suggestions, langpacks, priorities, update-motd
281 packages excluded due to repository priority protections
Installed Packages
Name        : httpd
Arch        : x86_64
Version     : 2.4.48
Release     : 2.amzn2
Size        : 4.0 M
Repo        : installed
From repo   : amzn2-core
Summary     : Apache HTTP Server
URL         : https://httpd.apache.org/
License     : ASL 2.0
Description : The Apache HTTP Server is a powerful, efficient, and extensible
            : web server.

# 起動
$ sudo systemctl start httpd
# 停止
$ sudo systemctl stop httpd
# 再起動
$ sudo systemctl restart httpd
# 自動起動
$ sudo systemctl enable httpd
# 自動起動停止
$ sudo systemctl disable httpd
```

## CloudWatch エージェント

```bash
$ sudo yum install amazon-cloudwatch-agent
```

通常手動で行う場合は `/opt/aws/amazon-cloudwatch-agent/etc/` 配下に以下のような内容で `amazon-cloudwatch-agent.json` を作成する。（ `sudo vi amazon-cloudwatch-agent.json` ）  
しかし、本設定は User Data（ [modules/tpl/ec2_user_data.sh.tpl](../modules/tpl/ec2_user_data.sh.tpl) ）により自動設定を行っている。

```json:amazon-cloudwatch-agent.json
{
   "agent":{
      "metrics_collection_interval":60,
      "run_as_user":"root"
   },
   "logs":{
      "logs_collected":{
         "files":{
            "collect_list":[
               {
                  "file_path":"/var/log/messages",
                  "log_group_name":"${system}_${env}_ec2_messages",
                  "log_stream_name":"{instance_id}"
               },
               {
                  "file_path":"/var/log/httpd/access_log",
                  "log_group_name":"${system}_${env}_ec2_apache_access_log",
                  "log_stream_name":"{instance_id}",
                  "timestamp_format":"%d/%b/%Y:%H:%M:%S %z"
               },
               {
                  "file_path":"/var/log/httpd/error_log",
                  "log_group_name":"${system}_${env}_ec2_apache_error_log",
                  "log_stream_name":"{instance_id}",
                  "timestamp_format":"%a %b %d %H:%M:%S.%f %Y"
               }
            ]
         }
      }
   },
   "metrics":{
      "append_dimensions":{
         "AutoScalingGroupName":"${aws:AutoScalingGroupName}",
         "ImageId":"${aws:ImageId}",
         "InstanceId":"${aws:InstanceId}",
         "InstanceType":"${aws:InstanceType}"
      },
      "aggregation_dimensions":[
        ["AutoScalingGroupName"],
        ["AutoScalingGroupName", "ImageId"],
        ["AutoScalingGroupName", "ImageId", "path"],
        ["InstanceId", "InstanceType"],
        []
      ],
      "metrics_collected":{
         "disk":{
            "measurement":[
               "used_percent"
            ],
            "metrics_collection_interval":60,
            "resources":[
               "*"
            ]
         },
         "mem":{
            "measurement":[
               "mem_used_percent"
            ],
            "metrics_collection_interval":60
         },
         "statsd":{
            "metrics_aggregation_interval":60,
            "metrics_collection_interval":10,
            "service_address":":8125"
         }
      }
   }
}
```

CloudWatch エージェントの起動は以下。

```bash
# 設定を読み込んで起動（ `amazon-cloudwatch-agent.json` を TOML 形式の設定ファイルに変換して `amazon-cloudwatch-agent.toml` に保存した後に実行される）
$ sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
# ステータス確認
$ sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
# 停止
$ sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a stop
# 起動
$ sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a start
# ログ
# /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

エージェントによって収集されるメトリクスに使用するデフォルトの名前空間は CWAgent 。