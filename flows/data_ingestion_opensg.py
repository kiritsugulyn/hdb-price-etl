"""
This script:
1. Downloads JSON data from an API.
2. Writes the data into a Parquet file.
3. Uploads the Parquet file to a Google Cloud Storage (GCS) bucket with efficient settings.
4. Removes the local Parquet file after uploading.
"""

import os
import requests
import pandas as pd
from google.cloud import storage

def download_open_sg_data(dataset_id):
    """
    Downloads sg open data from the API and returns it as DataFrame.
    """
    s = requests.Session()
    initiate_download_response = s.get(
        f"https://api-open.data.gov.sg/v1/public/api/datasets/{dataset_id}/initiate-download",
        headers={"Content-Type":"application/json"},
        json={}
    )
    print(initiate_download_response.json()['data']['message'])

    max_polls = 5
    for i in range(max_polls):
        poll_download_response = s.get(
            f"https://api-open.data.gov.sg/v1/public/api/datasets/{dataset_id}/poll-download",
            headers={"Content-Type":"application/json"},
            json={}
        )
        if "url" in poll_download_response.json()['data']:
            print(poll_download_response.json()['data']['url'])
            download_url = poll_download_response.json()['data']['url']
            df = pd.read_csv(download_url)
            print(df.head())
            print("\nDataframe loaded!")
            return df
        if i == max_polls - 1:
            print(f"{i+1}/{max_polls}: No result found, possible error with dataset, please try again or let us know at https://go.gov.sg/datagov-supportform\n")
        else:
            print(f"{i+1}/{max_polls}: No result yet, continuing to poll\n")

def json_to_parquet(df, parquet_file):
    """
    Converts JSON data into a DataFrame and writes it to a Parquet file.
    """
    # Data type conversion
    if 'resale_price' in df:
        df['resale_price'] = df['resale_price'].astype('int')
        if 'remaining_lease' in df:
            df['remaining_lease'] = df['remaining_lease'].astype('string')
        else:
            df['remaining_lease'] = 'NaN'
    elif 'monthly_rent' in df:
        df['monthly_rent'] = df['monthly_rent'].astype('int')

    df.to_parquet(parquet_file, index=False)
    print(f"Data written to Parquet file: {parquet_file}")

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

def remove_local_file(file_path):
    """
    Removes a local file.
    """
    try:
        os.remove(file_path)
        print(f"Local file {file_path} removed successfully.")
    except OSError as e:
        print(f"Error removing file {file_path}: {e}")

def main():
    # --- Configuration ---
    dataset_id = ["d_ebc5ab87086db484f88045b47411ebc5", 
                  "d_43f493c6c50d54243cc1eab0df142d6a",
                  "d_2d5ff9ea31397b66239f245f57751537",
                  "d_ea9ed51da2787afaf8e51f827c304208", 
                  "d_8b84c4ee58e3cfc0ece0d773c8ca6abc", 
                  "d_c9f57187485a850908655db0e8cfe651"]  # Data from 1990 to now
    parquet_file = "data.parquet"
    bucket_name = "hdb_price_etl_staging"        
    destination_blob_name = ["resale_price_1990_1999.parquet",
                             "resale_price_2000_2012.parquet",
                             "resale_price_2012_2014.parquet",
                             "resale_price_2015_2016.parquet",
                             "resale_price_2017_now.parquet",
                             "rental_price_2021_now.parquet"]  # Desired destination path in GCS

    # Ensure the GCS credentials are set.
    if not os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
        print("Error: GOOGLE_APPLICATION_CREDENTIALS environment variable is not set.")
        return

    for i in range(len(dataset_id)):
        # Step 1: Download data from API.
        df = download_open_sg_data(dataset_id[i])

        # Step 2: Write the JSON data to a Parquet file.
        json_to_parquet(df, parquet_file)

        # Step 3: Upload the Parquet file to the GCS bucket.
        upload_to_gcs(bucket_name, parquet_file, destination_blob_name[i])

        # Step 4: Remove the local Parquet file after successful upload.
        remove_local_file(parquet_file)

if __name__ == "__main__":
    main()
