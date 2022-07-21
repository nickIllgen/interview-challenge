variable "region" {
  default = "us-west-2"
}

variable "application_name" {
  type    = string
  default = "ibm-rest-api"
}
variable "AWS_ACCESS_KEY_ID" {
  type = string
  default = ""
}
variable "AWS_SECRET_ACCESS_KEY" {
  type = string
  default = ""
}