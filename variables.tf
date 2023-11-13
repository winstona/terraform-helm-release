variable "name" {

}

variable "create_namespace" {
  default = false
}

variable "namespace" {
  default = ""
}

variable "helm_repo_url" {
}

variable "helm_repo_type" {
  default = null
}

variable "helm_chart_name" {
  default = ""
}


variable "release_name" {
  default = ""
}


variable "refresh_interval" {
  default = "1h"
}

variable "values" {
  type    = string
  default = ""
}