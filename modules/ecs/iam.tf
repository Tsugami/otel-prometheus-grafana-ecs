data "aws_iam_policy_document" "AWSDistroOpenTelemetryPolicy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
      "logs:PutRetentionPolicy",
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries",
      "cloudwatch:PutMetricData",
      "ec2:DescribeVolumes",
      "ec2:DescribeTags",
      "ssm:GetParameters"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "AWSDistroOpenTelemetryPolicy" {
  name   = "AWSDistroOpenTelemetryPolicy"
  policy = data.aws_iam_policy_document.AWSDistroOpenTelemetryPolicy.json
}

data "aws_iam_policy_document" "ECSAssumeRolePolicy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ECSTaskRole" {
  name               = "ECSTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ECSAssumeRolePolicy.json
}

resource "aws_iam_role_policy_attachment" "ECSTaskRoleOtelPolicy" {
  role       = aws_iam_role.ECSTaskRole.name
  policy_arn = aws_iam_policy.AWSDistroOpenTelemetryPolicy.arn
}

resource "aws_iam_role" "TaskExecutionRole" {
  name               = "TaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ECSAssumeRolePolicy.json
}

data "aws_iam_policy" "TaskExecutionRolePolicies" {
  for_each = toset([
    "CloudWatchLogsFullAccess",
    "AmazonSSMReadOnlyAccess",
    "AmazonECSTaskExecutionRolePolicy",
    aws_iam_policy.AWSDistroOpenTelemetryPolicy.name
  ])

  name = each.key
}

resource "aws_iam_role_policy_attachment" "TaskExecutionRolePolicies" {
  for_each   = data.aws_iam_policy.TaskExecutionRolePolicies
  role       = aws_iam_role.TaskExecutionRole.name
  policy_arn = each.value.arn
}
