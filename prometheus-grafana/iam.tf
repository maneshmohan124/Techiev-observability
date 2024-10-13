data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
}

output "account_id" {
  value = local.account_id
}

resource "aws_iam_role_policy" "amp_write_access_policy" {
  name = "${var.environment}.amp_write_access_policy"
  role = aws_iam_role.prometheus_role.id
  policy = file("./AWSAmpRolePolicy.json")
}

resource "aws_iam_role" "prometheus_role" {
  name = "${var.environment}.prometheus_role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "${var.oidc_provider_arn}"
        },  
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${var.oidc_provider_url}:sub":"system:serviceaccount:default:amp-iamproxy-ingest-service-account"
          }
        }
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "${var.oidc_provider_arn}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${var.oidc_provider_url}:sub":"system:serviceaccount:default:iamproxy-service-account"
          }
        }
      }
    ]
  }
EOF
}

resource "aws_iam_role" "grafana_role" {
  name = "${var.environment}.grafana_role"
  assume_role_policy = <<EOF
{
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Sid"    : "",
        "Principal" : {
          "Service" : "grafana.amazonaws.com"
        },

        "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": "${local.account_id}"
                },
                "StringLike": {
                    "aws:SourceArn": "arn:aws:grafana:${var.region}:${local.account_id}:/workspaces/*"
                }
            }         
      }
    ]
  }
 EOF
}

resource "aws_iam_role_policy" "AmazonGrafanaCloudWatchPolicy" {
  name = "${var.environment}.AmazonGrafanaCloudWatchPolicy"
  role = "${var.environment}.grafana_role"
  policy = file("./AWSCloudWatchPolicy.json")
}

resource "aws_iam_role_policy" "AWSManagedPrometheusWriteAccessPolicy" {
  name = "${var.environment}.amp_grafana_write_access_policy"
  role = aws_iam_role.grafana_role.id
  policy = file("./AWSAmpRolePolicy.json")
}