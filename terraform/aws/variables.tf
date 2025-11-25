variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}


variable "source_s3_bucket_name" {
  description = "Existing S3 bucket to be used as source for Athena queries"
  type        = string
  default     = "hdb-price-etl"
}

variable "staging_bucket_name" {
  description = "S3 bucket name to use for staging intermediate files"
  type        = string
  default     = "hdb-price-etl-staging"
}

variable "results_bucket_name" {
  description = "S3 bucket name to store Athena results"
  type        = string
  default     = "hdb-price-etl-results"
}

variable "glue_db_name" {
  description = "Glue catalog database name for Athena"
  type        = string
  default     = "hdb_price_etl"
}

variable "athena_workgroup_name" {
  description = "Athena workgroup name"
  type        = string
  default     = "hdb-price-etl-wg"
}

variable "glue_crawler_name" {
  description = "Name of the Glue crawler to create"
  type        = string
  default     = "hdb-price-etl-crawler"
}

variable "glue_crawler_role_name" {
  description = "Name of the IAM role to create for Glue crawler"
  type        = string
  default     = "hdb-price-etl-glue-crawler-role"
}


variable "aws_access_key_id" {
  description = "AWS access key id (sensitive). Prefer using environment vars or an untracked tfvars file."
  type        = string
  sensitive   = true
  default     = ""
}

variable "aws_secret_access_key" {
  description = "AWS secret access key (sensitive). Prefer using environment vars or an untracked tfvars file."
  type        = string
  sensitive   = true
  default     = ""
}



