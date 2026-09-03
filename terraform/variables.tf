variable "location" {
  description = "Azure region for the lab resources."
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Short project identifier used in tags."
  type        = string
  default     = "azure-enterprise-lab"
}