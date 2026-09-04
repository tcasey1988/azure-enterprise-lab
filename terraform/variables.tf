variable "location" {
  description = "Azure region for the lab resources."
  type        = string
  default     = "centralus"
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

variable "admin_username" {
  description = "Local administrator username for Windows lab VMs."
  type        = string
  default     = "aeladmin"
}

variable "admin_password" {
  description = "Local administrator password supplied through TF_VAR_admin_password."
  type        = string
  sensitive   = true
}

variable "admin_source_cidr" {
  description = "Public IPv4 CIDR allowed to connect to the management VM over RDP."
  type        = string
  sensitive   = true

  validation {
    condition     = can(cidrhost(var.admin_source_cidr, 0))
    error_message = "admin_source_cidr must be a valid CIDR, such as 203.0.113.25/32."
  }
}

variable "management_vm_size" {
  description = "Azure size assigned to the management VM."
  type        = string
  default     = "Standard_D2als_v7"
}
