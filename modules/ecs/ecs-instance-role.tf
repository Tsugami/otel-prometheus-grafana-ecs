data "aws_iam_policy_document" "EcsCloudWatchLogs" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "ecsInstanceRole" {
  name               = "ecsInstanceRole-${var.project_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json

  inline_policy {
    name   = "ecsInstanceRole-${var.project_name}"
    policy = data.aws_iam_policy_document.EcsCloudWatchLogs.json
  }


}

resource "aws_iam_instance_profile" "ecsInstanceRole" {
  name = aws_iam_role.ecsInstanceRole.name
  role = aws_iam_role.ecsInstanceRole.name
}

data "aws_iam_policy" "AmazonEC2ContainerServiceforEC2Role" {
  name = "AmazonEC2ContainerServiceforEC2Role"
}


resource "aws_iam_role_policy_attachment" "ecsInstanceRole" {
  role       = aws_iam_role.ecsInstanceRole.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerServiceforEC2Role.arn
}


# data "aws_iam_policy_document" "AWSDistroOpenTelemetryPolicy" {
#   version = "2012-10-17"

#   statement {
#     effect = "Allow"
#     actions = [
#       "logs:PutLogEvents",
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:DescribeLogStreams",
#       "logs:DescribeLogGroups",
#       "logs:PutRetentionPolicy",
#       "xray:PutTraceSegments",
#       "xray:PutTelemetryRecords",
#       "xray:GetSamplingRules",
#       "xray:GetSamplingTargets",
#       "xray:GetSamplingStatisticSummaries",
#       "cloudwatch:PutMetricData",
#       "ec2:DescribeVolumes",
#       "ec2:DescribeTags",
#       "ssm:GetParameters"
#     ]

#     resources = ["*"]
#   }
# }

# resource "aws_iam_policy" "AWSDistroOpenTelemetryPolicy" {
#   name   = "AWSDistroOpenTelemetryPolicy"
#   policy = data.aws_iam_policy_document.AWSDistroOpenTelemetryPolicy.json
# }

# data "aws_iam_policy_document" "ECSAssumeRolePolicy" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]
#     principals {
#       type = "Service"
#       identifiers = [
#         "ecs-tasks.amazonaws.com"
#       ]
#     }
#   }
# }

# resource "aws_iam_role" "ECSTaskRole" {
#   name               = "ECSTaskRole"
#   assume_role_policy = data.aws_iam_policy_document.ECSAssumeRolePolicy.json
# }

# resource "aws_iam_role_policy_attachment" "ECSTaskRoleOtelPolicy" {
#   role       = aws_iam_role.ECSTaskRole.name
#   policy_arn = aws_iam_policy.AWSDistroOpenTelemetryPolicy.arn
# }

# resource "aws_iam_role" "TaskExecutionRole" {
#   name               = "TaskExecutionRole"
#   assume_role_policy = data.aws_iam_policy_document.ECSAssumeRolePolicy.json
# }

# data "aws_iam_policy" "TaskExecutionRolePolicies" {
#   for_each = toset([
#     "CloudWatchLogsFullAccess",
#     "AmazonSSMReadOnlyAccess",
#     "AmazonECSTaskExecutionRolePolicy",
#     aws_iam_policy.AWSDistroOpenTelemetryPolicy.name
#   ])

#   name = each.key
# }

# resource "aws_iam_role_policy_attachment" "TaskExecutionRolePolicies" {
#   for_each   = data.aws_iam_policy.TaskExecutionRolePolicies
#   role       = aws_iam_role.TaskExecutionRole.name
#   policy_arn = each.value.arn
# }
