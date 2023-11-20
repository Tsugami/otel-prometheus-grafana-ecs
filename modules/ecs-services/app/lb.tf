resource "aws_security_group" "app_inbound_sg" {
  name        = "${local.name}-inbound-sg"
  description = "Allow HTTP from Anywhere into ALB"
  vpc_id      = var.aws_vpc.id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = local.container_port
    to_port     = local.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_alb" "app" {
  name               = "${local.name}-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.app_inbound_sg.id]
}

resource "aws_lb_target_group" "app" {
  name                 = "${local.name}-tg"
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.aws_vpc.id
  deregistration_delay = 5

  health_check {
    healthy_threshold = 2
    interval          = 10
    enabled           = true
    path              = "/"
  }
}

resource "aws_alb_listener" "app" {
  load_balancer_arn = aws_alb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.app.arn
    type             = "forward"
  }

}
