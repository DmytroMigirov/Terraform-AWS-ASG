# Create a security group for the EC2 instance
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.NodeJS_ASG_vpc.id
  
  # Allow SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Allow ICMP access from anywhere
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "NodeJS_ASG_sg"
  }
}

# Launch configuration description
resource "aws_launch_configuration" "ASG_launch_config" {
  name                        = "NodeJS_ASG_Launch_config"
  image_id                    = var.image_id  #  AMI ID
  instance_type               = var.instance_type               # instance type
  key_name                    = var.key_name    # key name
  security_groups             = [aws_security_group.instance_sg.id]
  user_data                   = file("${path.module}/../../user-data/user-data.sh")

}

# Auto scaling group definition
resource "aws_autoscaling_group" "NodeJS_ASG" {
  name                      = "NodeJS_ASG"
  vpc_zone_identifier       = ["${aws_subnet.pub_sub1.id}", "${aws_subnet.pub_sub2.id}"]
  launch_configuration      = aws_launch_configuration.ASG_launch_config.name
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_grace_period = 300
  health_check_type         = "EC2"
  target_group_arns         = [aws_lb_target_group.ASG_target_group.arn]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
    ]

  metrics_granularity = "1Minute"

  tag {
    key                 = "Name"
    value               = "NodeJS_ASG_Instance" # name for EC2 instances created by ASG
    propagate_at_launch = true
  }

}

# Target group definition
resource "aws_lb_target_group" "ASG_target_group" {
  name        = "ASG-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.NodeJS_ASG_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

# Attach target group to your auto-scaling group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.NodeJS_ASG.name
  lb_target_group_arn  = aws_lb_target_group.ASG_target_group.arn
}

# Security group for the ELB
resource "aws_security_group" "elb_sg" {
  vpc_id = aws_vpc.NodeJS_ASG_vpc.id
  
  # Allow HTTP and HTTPS traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "NodeJS_ASG_ELBSG"
  }
}

# Elastic load balancer creation
resource "aws_lb" "ASG_load_balancer" {
  name               = "NodeJS-ASG-ELB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_sg.id]
  subnets            = [aws_subnet.pub_sub1.id, aws_subnet.pub_sub2.id]
  
  tags = {
    Name = "NodeJS_ASG_ELB"
  }
}

# Configure listeners for the ELB, forward traffic to target group
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.ASG_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ASG_target_group.arn
  }
}

