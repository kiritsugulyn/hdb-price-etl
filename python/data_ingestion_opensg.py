"""
This script:
1. Downloads JSON data from OpenSG API.
2. Writes the data into a Parquet file.
"""

import requests
import pandas as pd

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

    col_rename = {}
    # BigQuery rule for column name
    for col in df.columns:
        if not (col[0].isalpha() or col[0] == "_"):
            col_rename[col] = "_" + col
    if col_rename:
        df.rename(columns=col_rename, inplace=True)

    df.to_parquet(parquet_file, index=False)
    print(f"Data written to Parquet file: {parquet_file}")


def main():
    # --- Configuration ---
    dataset_id = ["d_ebc5ab87086db484f88045b47411ebc5", 
                  "d_43f493c6c50d54243cc1eab0df142d6a",
                  "d_2d5ff9ea31397b66239f245f57751537",
                  "d_ea9ed51da2787afaf8e51f827c304208", 
                  "d_8b84c4ee58e3cfc0ece0d773c8ca6abc", 
                  "d_17f5382f26140b1fdae0ba2ef6239d2f"]  # Data from 1990 to now
   
    parquet_file = ["resale_price_1990_1999.parquet",
                    "resale_price_2000_2012.parquet",
                    "resale_price_2012_2014.parquet",
                    "resale_price_2015_2016.parquet",
                    "resale_price_2017_now.parquet",
                    "hdb_property_info.parquet"]  # Desired destination path in GCS

    for i in range(len(dataset_id)):
        # Step 1: Download data from API.
        df = download_open_sg_data(dataset_id[i])

        # Step 2: Write the JSON data to a Parquet file.
        json_to_parquet(df, parquet_file[i])

if __name__ == "__main__":
    main()
