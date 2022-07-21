variable "region" {
  default = "us-west-2"
}

variable "application_name" {
  type    = string
  default = "ibm-rest-api"
}

variable "aws-access-key-id" {
  type    = string
  default = ""
}

variable "aws-secret-access-key" {
  type    = string
  default = ""
}