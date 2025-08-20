variable "common_param" {
  type        = map(string)
  description = "Common parameters"
}

variable "sns_topic" {
  type        = any
  description = "SNS Topic for alert"
}
