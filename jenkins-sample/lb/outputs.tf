output "lb" {
  value = {
    dns_name     = aws_lb.lb.dns_name
    listener_arn = aws_lb_listener.listener.arn
  }
}

output "sg" {
  value = {
    id = aws_security_group.sg_lb.id
  }
}