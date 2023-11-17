resource "aws_ecs_capacity_provider" "main" {
  name = "${var.project_name}-ecs-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.main.arn
    managed_scaling {

      maximum_scaling_step_size = 5
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 60
    }
  }
}

resource "aws_autoscaling_group" "main" {
  name             = "${var.project_name}-ecs-asg"
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  vpc_zone_identifier = var.vpc_zone_identifier

  lifecycle {
    ignore_changes = [desired_capacity]
  }

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

resource "aws_launch_template" "this" {
  name_prefix            = "${aws_ecs_cluster.main.name}-ecs-template"
  image_id               = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.autoescaling_sg.id]
  user_data = base64encode(<<-EOT
        #!/bin/bash

        cat <<'EOF' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${aws_ecs_cluster.main.name}
        ECS_LOGLEVEL=debug
        ECS_ENABLE_TASK_IAM_ROLE=true
        EOF
      EOT
  )

  iam_instance_profile {
    name = "ecsInstanceRole"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ECS Instance - ${aws_ecs_cluster.main.name}"
    }
  }
}
