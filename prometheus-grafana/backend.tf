terraform {
backend "s3"{
    bucket         = "terraformstateforpoc"
    key            = "techiev/prometheus-grafana-state/terraform.tfstate"
    encrypt        = true
    region         = "us-east-1"
  }
}