terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

/* Source S3 bucket to store input data */
resource "aws_s3_bucket" "source" {
  bucket = var.source_s3_bucket_name
}

/* S3 bucket to use for staging intermediate files */
resource "aws_s3_bucket" "staging" {
  bucket = var.staging_bucket_name
}

/* New S3 bucket to store Athena query results */
resource "aws_s3_bucket" "results" {
  bucket = var.results_bucket_name
}

/* Athena workgroup configured to write results to the results bucket */
resource "aws_athena_workgroup" "wg" {
  name = var.athena_workgroup_name

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.results.bucket}"
    }
  }
}

/* Glue catalog database for Athena */
resource "aws_glue_catalog_database" "athena_db" {
  name = var.glue_db_name
}

/* IAM role for Glue crawler */
resource "aws_iam_role" "crawler_role" {
  name = var.glue_crawler_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

/* Minimal inline policy: Glue crawler needs read access to source bucket and Glue catalog permissions */
resource "aws_iam_role_policy" "crawler_policy" {
  name   = "glue-crawler-s3-access-${var.source_s3_bucket_name}"
  role   = aws_iam_role.crawler_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadSourceBucket"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.source_s3_bucket_name}",
          "arn:aws:s3:::${var.source_s3_bucket_name}/*"
        ]
      },
      {
        Sid    = "GlueCatalogAccess"
        Effect = "Allow"
        Action = [
          "glue:GetDatabase",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:GetTable",
          "glue:DeleteTable",
          "glue:PutDataCatalogEncryptionSettings",
          "glue:GetDataCatalogEncryptionSettings"
        ]
        Resource = "*"
      }
    ]
  })
}

/* Glue crawler to infer schema from the source S3 bucket */
resource "aws_glue_crawler" "crawler" {
  name         = var.glue_crawler_name
  database_name = aws_glue_catalog_database.athena_db.name

  role = aws_iam_role.crawler_role.arn

  s3_target {
    path = "s3://${var.source_s3_bucket_name}/"
    exclusions = [ "hdb_property_info.parquet" ]
  }

  # Use default classifier behavior; can add classifiers if needed
  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }
}

output "glue_crawler_name" {
  value = aws_glue_crawler.crawler.name
}

output "source_s3_bucket" {
  value = var.source_s3_bucket_name
}

output "staging_s3_bucket" {
  value = aws_s3_bucket.staging.bucket
}

output "athena_results_bucket" {
  value = aws_s3_bucket.results.bucket
}

output "glue_database" {
  value = aws_glue_catalog_database.athena_db.name
}

output "athena_workgroup" {
  value = aws_athena_workgroup.wg.name
}


