variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
}