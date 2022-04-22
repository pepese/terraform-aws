# 運用手順

## EC2 へのログイン

EC2 へのアクセスは SSM Login を行うため、 Session Manager Plugin の導入が必要。  
Cloud9（Intel 64-bit (x86_64) Linux ）の場合は以下。

```bash
$ curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
$ sudo yum install -y session-manager-plugin.rpm
```

Mac の場合は以下。

```bash
$ brew install --cask session-manager-plugin
```

以下でアクセス。

```bash
$ aws ssm start-session --target "i-xxxxxxxxxxxxxxxxx"
```

`session-manager-plugin` がうまく使えない場合は Management Console の Session Manager からでもよい。


## メトリクス情報取得

### EC2 : CPUUtilization

日単位。

```bash
aws cloudwatch get-metric-statistics \
--namespace "AWS/EC2" \
--dimensions Name="AutoScalingGroupName",Value="sample-prd-ec2-asg" \
--metric-name "CPUUtilization" \
--statistics "Maximum" \
--start-time "2021-10-31T15:00:00Z" \
--end-time "2021-11-25T15:00:00Z" \
--period $((60 * 60 * 24)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Maximum,Unit]" \
--output text
```

時間単位。

```bash
aws cloudwatch get-metric-statistics \
--namespace "AWS/EC2" \
--dimensions Name="AutoScalingGroupName",Value="sample-prd-ec2-asg" \
--metric-name "CPUUtilization" \
--statistics "Maximum" \
--start-time "2021-11-8T15:00:00Z" \
--end-time "2021-11-9T15:00:00Z" \
--period $((60 * 60)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Maximum,Unit]" \
--output text
```

`Z` がつくことで UTC 表示となる。

### EC2 : MemUsedPercent

日単位。

```bash
aws cloudwatch get-metric-statistics \
--namespace "CWAgent" \
--dimensions Name="AutoScalingGroupName",Value="sample-prd-ec2-asg" \
--metric-name "mem_used_percent" \
--statistics "Maximum" \
--start-time "2021-10-31T15:00:00Z" \
--end-time "2021-11-25T15:00:00Z" \
--period $((60 * 60 * 24)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Maximum,Unit]" \
--output text
```

時間単位。

```bash
aws cloudwatch get-metric-statistics \
--namespace "CWAgent" \
--dimensions Name="AutoScalingGroupName",Value="sample-prd-ec2-asg" \
--metric-name "mem_used_percent" \
--statistics "Maximum" \
--start-time "2021-11-8T15:00:00Z" \
--end-time "2021-11-9T15:00:00Z" \
--period $((60 * 60)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Maximum,Unit]" \
--output text
```

### EC2 : DiskUsedPercent

日単位。

```bash
aws cloudwatch get-metric-statistics \
--namespace "CWAgent" \
--dimensions Name="AutoScalingGroupName",Value="sample-prd-ec2-asg" \
--metric-name "disk_used_percent" \
--statistics "Maximum" \
--start-time "2021-10-31T15:00:00Z" \
--end-time "2021-11-25T15:00:00Z" \
--period $((60 * 60 * 24)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Maximum,Unit]" \
--output text
```

時間単位。

```bash
aws cloudwatch get-metric-statistics \
--namespace "CWAgent" \
--dimensions Name="AutoScalingGroupName",Value="sample-prd-ec2-asg" \
--metric-name "disk_used_percent" \
--statistics "Maximum" \
--start-time "2021-11-8T15:00:00Z" \
--end-time "2021-11-9T15:00:00Z" \
--period $((60 * 60)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Maximum,Unit]" \
--output text
```

### RDS : CPUUtilization

日単位。

```bash
aws cloudwatch get-metric-statistics \
--namespace "AWS/RDS" \
--dimensions Name="DBInstanceIdentifier",Value="sample-prd-rds" \
--metric-name "CPUUtilization" \
--statistics "Maximum" \
--start-time "2021-10-31T15:00:00Z" \
--end-time "2021-11-25T15:00:00Z" \
--period $((60 * 60 * 24)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Maximum,Unit]" \
--output text
```

時間単位。

```bash
aws cloudwatch get-metric-statistics \
--namespace "AWS/RDS" \
--dimensions Name="DBInstanceIdentifier",Value="sample-prd-rds" \
--metric-name "CPUUtilization" \
--statistics "Maximum" \
--start-time "2021-11-8T15:00:00Z" \
--end-time "2021-11-9T15:00:00Z" \
--period $((60 * 60)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Maximum,Unit]" \
--output text
```

### RDS : FreeableMemory

日単位。

```bash
aws cloudwatch get-metric-statistics \
--namespace "AWS/RDS" \
--dimensions Name="DBInstanceIdentifier",Value="sample-prd-rds" \
--metric-name "FreeableMemory" \
--statistics "Minimum" \
--start-time "2021-10-31T15:00:00Z" \
--end-time "2021-11-25T15:00:00Z" \
--period $((60 * 60 * 24)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Minimum,Unit]" \
--output text
```

時間単位。

```bash
aws cloudwatch get-metric-statistics \
--namespace "AWS/RDS" \
--dimensions Name="DBInstanceIdentifier",Value="sample-prd-rds" \
--metric-name "FreeableMemory" \
--statistics "Minimum" \
--start-time "2021-11-8T15:00:00Z" \
--end-time "2021-11-9T15:00:00Z" \
--period $((60 * 60)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Minimum,Unit]" \
--output text
```

### RDS : FreeStorageSpace

日単位。

```bash
aws cloudwatch get-metric-statistics \
--namespace "AWS/RDS" \
--dimensions Name="DBInstanceIdentifier",Value="sample-prd-rds" \
--metric-name "FreeStorageSpace" \
--statistics "Maximum" \
--start-time "2021-10-31T15:00:00Z" \
--end-time "2021-11-25T15:00:00Z" \
--period $((60 * 60 * 24)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Maximum,Unit]" \
--output text
```

時間単位。

```bash
aws cloudwatch get-metric-statistics \
--namespace "AWS/RDS" \
--dimensions Name="DBInstanceIdentifier",Value="sample-prd-rds" \
--metric-name "FreeStorageSpace" \
--statistics "Maximum" \
--start-time "2021-11-8T15:00:00Z" \
--end-time "2021-11-9T15:00:00Z" \
--period $((60 * 60)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Maximum,Unit]" \
--output text
```

### RDS : DatabaseConnections

日単位。

```bash
aws cloudwatch get-metric-statistics \
--namespace "AWS/RDS" \
--dimensions Name="DBInstanceIdentifier",Value="sample-prd-rds" \
--metric-name "DatabaseConnections" \
--statistics "Maximum" \
--start-time "2021-10-31T15:00:00Z" \
--end-time "2021-11-25T15:00:00Z" \
--period $((60 * 60 * 24)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Maximum,Unit]" \
--output text
```

時間単位。

```bash
aws cloudwatch get-metric-statistics \
--namespace "AWS/RDS" \
--dimensions Name="DBInstanceIdentifier",Value="sample-prd-rds" \
--metric-name "DatabaseConnections" \
--statistics "Maximum" \
--start-time "2021-11-8T15:00:00Z" \
--end-time "2021-11-9T15:00:00Z" \
--period $((60 * 60)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Maximum,Unit]" \
--output text
```

### ALB : RequestCount

日単位。


```bash
aws cloudwatch get-metric-statistics \
--namespace "AWS/ApplicationELB" \
--dimensions Name="TargetGroup",Value="targetgroup/sample-prd-lb-tg/a88adf5c9de45136" Name="LoadBalancer",Value="app/sample-prd-lb/3e8e01fa982fa6f8" \
--metric-name "RequestCount" \
--statistics "Sum" \
--start-time "2021-10-31T15:00:00Z" \
--end-time "2021-11-25T15:00:00Z" \
--period $((60 * 60 * 24)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Sum,Unit]" \
--output text
```

時間単位。

```bash
aws cloudwatch get-metric-statistics \
--namespace "AWS/ApplicationELB" \
--dimensions Name="TargetGroup",Value="targetgroup/sample-prd-lb-tg/a88adf5c9de45136" Name="LoadBalancer",Value="app/sample-prd-lb/3e8e01fa982fa6f8" \
--metric-name "RequestCount" \
--statistics "Sum" \
--start-time "2021-11-8T15:00:00Z" \
--end-time "2021-11-9T15:00:00Z" \
--period $((60 * 60)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Sum,Unit]" \
--output text
```

### ALB : TargetResponseTime

```bash
aws cloudwatch get-metric-statistics \
--namespace "AWS/ApplicationELB" \
--dimensions Name="TargetGroup",Value="targetgroup/sample-prd-lb-tg/a88adf5c9de45136" Name="LoadBalancer",Value="app/sample-prd-lb/3e8e01fa982fa6f8" \
--metric-name "TargetResponseTime" \
--statistics "Average" \
--extended-statistics p95 \
--start-time "2021-10-18T00:00:00Z" \
--end-time "2021-10-20T00:00:00Z" \
--period $((60 * 60)) \
--query "sort_by(Datapoints,&Timestamp)[][Timestamp,Average,Unit]" \
--output text
```