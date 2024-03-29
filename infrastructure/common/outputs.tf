output "elb_dns_name" {
  value = aws_lb.ASG_load_balancer.dns_name
}

