resource "aws_prometheus_workspace" "prometheus" {
  alias = "${var.environment}-prometheus"

  tags = {
    Environment = var.environment
  }
}

resource "aws_grafana_workspace" "grafana" {
  name                     = "${var.environment}-grafana"
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["SAML"]
  permission_type          = "SERVICE_MANAGED"
  data_sources             = ["CLOUDWATCH", "PROMETHEUS"]
  role_arn                 = aws_iam_role.grafana_role.arn
}


