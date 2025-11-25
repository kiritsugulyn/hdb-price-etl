variable "credentials" {
  description = "My Credentials"
  default     = "~/.gc/de-zoomcamp-service-1.json"
}

variable "project" {
  description = "Project"
  default     = "versatile-being-445714-t8"
}

variable "region" {
  description = "Region"
  default     = "asia-southeast1"
}

variable "location" {
  description = "Project Location"
  default     = "asia-southeast1"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "hdb_price_etl_staging"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "hdb_price_etl_staging"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}