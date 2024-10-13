variable "environment" {
description = "Deployment Environment"
default = "techiev-cluster"
}

variable "region" {
description = "Type the Region"
type        = string
}

variable "oidc_provider_arn" {
  description = "The OIDC provider arn"
  type        = string
}

variable "oidc_provider_url" {
  description = "The OIDC provider URL"
  type        = string
}