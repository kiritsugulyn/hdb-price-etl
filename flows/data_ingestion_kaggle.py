import os
import kagglehub
import shutil
from google.cloud import storage


def upload_to_gcs(bucket_name, source_file, destination_blob_name):
    """
    Uploads a file to a Google Cloud Storage bucket.
    Uses a larger chunk size for efficient uploading.
    The upload will automatically replace the old file if one exists with the same name.
    """
    # Initialize a storage client.
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    # Set a higher chunk_size for efficient upload (e.g., 5 MB).
    chunk_size = 5 * 1024 * 1024  # 5 MB
    blob = bucket.blob(destination_blob_name, chunk_size=chunk_size)
    blob.upload_from_filename(source_file)
    print(f"File {source_file} uploaded to GCS bucket '{bucket_name}' as '{destination_blob_name}'.")


if __name__ == "__main__":
    bucket_name = "hdb_price_etl_staging"
    destination_blob_name = "condo_price_2018_2022.csv"
    temp_data_path = "./data"
    if os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
        path = kagglehub.dataset_download("gohyuchen/singapore-private-property-transactions")
        shutil.move(path, temp_data_path)
        files = os.listdir(temp_data_path)
        print(files)
        for file in files:
            upload_to_gcs(bucket_name, temp_data_path+"/"+file, file)
        shutil.rmtree(temp_data_path)
    else:
        print("Error: GOOGLE_APPLICATION_CREDENTIALS environment variable is not set.")
    