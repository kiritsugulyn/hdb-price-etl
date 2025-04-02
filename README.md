# Singapore HDB Resale Price Data Dashboard

This repository outlines an ETL (Extract, Transform, Load) pipeline of Singapore HDB resale price data dashboard, leveraging various cloud and data engineering tools.  
  
[**Link to Dashboard**](https://lookerstudio.google.com/reporting/69d38486-089f-487e-9fb3-aec80884cb32)

## 📌 Overview
The HDB resale market in Singapore has evolved significantly since 1990 due to policy changes, economic trends, and demand shifts. This dashboard provides an interactive way to analyze resale price trends, helping users make informed decisions.

### Features
- 📈 **Historical Trends**: View resale price movements from 1990 to present.
- 🎛 **Customizable Filters**: Filter by town, flat type, floor range, lease remaining, etc.
- 🏙 **Top Priciest Areas**: Identify the top 10 highest-priced areas in Singapore based on resale transactions.
- 🗺 **Interactive Maps**: Visualize resale price trends geographically.

### Target Audience
- 🏠 **Homebuyers & Sellers**: Make informed resale decisions.
- 📈 **Investors**: Analyze market trends for potential returns.
- 📊 **Researchers & Analysts**: Study market dynamics and price trends.

### Usage
This dashboard serves as a **one-stop resource** for analyzing Singapore’s HDB resale market with **data-driven insights**.

### Data Source
- [HDB Resale Price Data](https://data.gov.sg/dataset/resale-flat-prices) from Data.gov.sg

## 🚀 ETL Pipeline Workflow

1️⃣ **Extract & Transform**  
   - A **Python** script downloads the data and converts it into Parquet format for efficient storage.  

2️⃣ **Load to Data Lake**  
   - The processed Parquet files are uploaded to **Google Cloud Storage (GCS)**.  

3️⃣ **Import to BigQuery**  
   - The stored data is imported into **Google BigQuery** for analytical querying.  

4️⃣ **Transform & Model**  
   - **dbt (Data Build Tool)** is used for analytic engineering, transforming raw data into structured insights.  

5️⃣ **Visualization**  
   - Data is visualized through **Looker Studio** dashboards.  

6️⃣ **Orchestration**  
   - **Kestra** manages and orchestrates the entire pipeline workflow.  

7️⃣ **Infrastructure as Code**  
   - **Terraform** provisions and manages cloud resources for deployment and scalability.  

## 🔧 Technologies Used  

- 🐍 **Python** – Data extraction and transformation  
- 🏞️ **Google Cloud Storage (GCS)** – Data lake storage  
- 🏢 **Google BigQuery** – Data warehouse for analytics  
- 🛠 **dbt (Data Build Tool)** – Data transformation and modeling  
- 📊 **Looker Studio** – Interactive data visualization  
- ⚙️ **Kestra** – Workflow orchestration and automation  
- 🌍 **Terraform** – Infrastructure as Code (IaC) for cloud deployment  

## 📜 Architecture Diagram
![alt text](<Arch Diagram.jpg>)

## 🛠️ Setup Instructions

### Pre-requisites

Ensure you have the following installed and configured before proceeding:

- **Google Cloud Platform (GCP)**
  - Created a project
  - Set up a service account with Cloud Storage and BigQuery access
  - Generated a credential JSON file and saved in your working environment
- **Python**
  - Installed in your working environment
- **Docker** 
  - Installed in your working environment
  - Set up docker compose 
- **Terraform**
  - Installed in your working environment  
- **Git**
  - Installed in your working environment  

### Steps
1️⃣ **Clone the Repository**  
```sh
git clone git@github.com:kiritsugulyn/hdb-price-etl.git
```
2️⃣ **Provision Cloud Infrustructure by Terraform**  
- Go to ``terraform`` folder.
- Update the ``variables.tf`` with your own GCP credential file location, project ID, project location, Cloud storage bucket name, and Bigquery dataset name.
- Run the following commands.
```sh
cd hdb-price-etl/terraform
terraform init
terraform apply
```
3️⃣ **Run Kestra using Docker Compose**  
```sh
cd hdb-price-etl/flows
docker-compose up -d
```
4️⃣ **Configure Namespace and KV Store in Kestra**  
- Open Kestra in ``localhost:8080``.  
- Create a **Flow** with the script ``flows/data_ingestion.yml``.
- Update the namespace in the flow with your own namespace.  
- Create the following key-value pairs in the **KV Store** under the same namespace (all values are string type):
  - ``GCP_PROJECT_ID``: Your GCP project ID
  - ``GCP_LOCATION``: Your GCP project location
  - ``GCP_BUCKET_NAME``: Your GCP Cloud Storage bucket name
  - ``GCP_DATASET``: You GCP BigQuery Dataset name
  - ``GCP_CREDS``: Your GCP credential JSON

5️⃣ **Execute Data Ingestion in Kestra**  
- Create a python file in the **Files** under the same namespace with the script ``flows/data_ingestion_opensg.py``. Name it as ``data_ingestion_opensg.py``.
- Execute the **Flow** ``data-ingestion`` in Kestra.  
  - After successful execution, 6 Parquet files are in your Cloud Storage bucket.

6️⃣ **Execute Data Import from Cloud Storage to BigQuery**
- Create a **Flow** with the script ``flows/bq_create_table.yml``
  - Update namespace to be the same as the previous steps.
- Execute the **Flow** ``bq_create_table`` in Kestra.  
  - After successful execution, two external tables and two partitioned tables are created under your BigQuery Dataset.

7️⃣ **Execute Data Import from Cloud Storage to BigQuery**
- Create a **Flow** with the script ``flows/dbt_build.yml``
  - Update namespace to be the same as the previous steps.
  - (Optional) Update the url in sync task if you prefer to use your own Github repository.
- Execute the **Flow** ``dbt_build`` in Kestra.  
  - After successful execution, two staging views and one fact table are created under your BigQuery Dataset.

8️⃣ **Create Dashboard in Looker Studio**
- In the Looker Studio, link data source to ``fact_hdb_resale`` in your BigQuery Dataset.
- Create dashboard as you want.

## 🔮 Future Improvements
- Scheduling in Kestra for continuous data update
- Integration with other cloud providers
