#####################################
# lb constant
#####################################
output "lb" {
  value = {
    dns_name     = aws_lb.lb.dns_name
    listener_arn = aws_lb_listener.http_listener.arn
  }
}

output "sg" {
  value = {
    id = aws_security_group.lb_sg.id
  }
}

#####################################
# rds constant
#####################################

# noting now

#####################################
# vpc constant
#####################################

output "vpc" {
  value = {
    id = aws_vpc.vpc.id
  }
}

output "subnet" {
  value = {
    public_1a_id    = aws_subnet.public_1a.id
    public_1c_id    = aws_subnet.public_1c.id
    protected_1a_id = aws_subnet.protected_1a.id
    protected_1c_id = aws_subnet.protected_1c.id
    private_1a_id   = aws_subnet.private_1a.id
    private_1c_id   = aws_subnet.private_1c.id
  }
}