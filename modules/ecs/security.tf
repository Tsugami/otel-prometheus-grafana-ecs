resource "aws_security_group" "autoescaling_sg" {
  name        = format("%s-autoscaling-sg", var.project_name)
  description = "Autoscaling group security group"
  vpc_id      = var.aws_vpc.id

  egress {
    from_port = 0
    to_port   = 0

    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "asg_ingress_https" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"

  security_group_id = aws_security_group.autoescaling_sg.id
  type              = "ingress"
}
