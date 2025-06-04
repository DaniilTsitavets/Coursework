resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  filename = var.filename//must be defined
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = "10"

  vpc_config {
    subnet_ids = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = var.env_variables
  }

  layers = [
    "arn:aws:lambda:eu-north-1:913524929706:layer:psycopg2-py311:1"
  ]
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.function_name}-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policies" {
  for_each = toset(var.policy_arns)
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = each.value
}

resource "aws_security_group" "lambda_sg" {
  name        = "coursework-${var.function_name}-sg"
  description = "Security Group for Lambda"
  vpc_id      = var.vpc_id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "coursework-${var.function_name}-sg"
  }
}