#!/bin/bash
echo '=== Start Apache Httpd Settings ==='
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo '=== End Apache Httpd Settings ==='

echo '=== Start MySQL Client Settings ==='
sudo yum localinstall https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
sudo yum-config-manager --disable mysql80-community
sudo yum-config-manager --enable mysql57-community
sudo yum install -y mysql-community-client
echo '=== End MySQL Client Settings ==='

echo '=== Start CloudWatch Agent Settings ==='
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a stop
sudo rm -f /opt/aws/amazon-cloudwatch-agent/etc/*.json
sudo rm -f /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.toml
sudo touch /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo echo "{
   \"agent\":{
      \"metrics_collection_interval\":60,
      \"run_as_user\":\"root\"
   },
   \"logs\":{
      \"logs_collected\":{
         \"files\":{
            \"collect_list\":[
               {
                  \"file_path\":\"/var/log/messages\",
                  \"log_group_name\":\"${system}_${env}_ec2_messages\",
                  \"log_stream_name\":\"{instance_id}\"
               },
               {
                  \"file_path\":\"/var/log/httpd/access_log\",
                  \"log_group_name\":\"${system}_${env}_ec2_apache_access_log\",
                  \"log_stream_name\":\"{instance_id}\",
                  \"timestamp_format\":\"%d/%b/%Y:%H:%M:%S %z\"
               },
               {
                  \"file_path\":\"/var/log/httpd/error_log\",
                  \"log_group_name\":\"${system}_${env}_ec2_apache_error_log\",
                  \"log_stream_name\":\"{instance_id}\",
                  \"timestamp_format\":\"%a %b %d %H:%M:%S.%f %Y\"
               }
            ]
         }
      }
   },
   \"metrics\":{
      \"append_dimensions\":{
         \"AutoScalingGroupName\":\"\$${aws:AutoScalingGroupName}\",
         \"ImageId\":\"\$${aws:ImageId}\",
         \"InstanceId\":\"\$${aws:InstanceId}\",
         \"InstanceType\":\"\$${aws:InstanceType}\"
      },
      \"aggregation_dimensions\":[
        [\"AutoScalingGroupName\"],
        [\"AutoScalingGroupName\", \"path\"],
        [\"InstanceId\", \"InstanceType\"],
        []
      ],
      \"metrics_collected\":{
         \"disk\":{
            \"measurement\":[
               \"used_percent\"
            ],
            \"metrics_collection_interval\":60,
            \"resources\":[
               \"*\"
            ]
         },
         \"mem\":{
            \"measurement\":[
               \"mem_used_percent\"
            ],
            \"metrics_collection_interval\":60
         },
         \"statsd\":{
            \"metrics_aggregation_interval\":60,
            \"metrics_collection_interval\":10,
            \"service_address\":\":8125\"
         }
      }
   }
}" | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
echo '=== End CloudWatch Agent Settings ==='