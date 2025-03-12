import json
import os
import requests
from datetime import datetime
import math
import azure.functions as func
from azure.storage.filedatalake import DataLakeServiceClient


# Initialize Function App
app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

# Getting Adzuna API creds
ADZUNA_APP_ID = os.getenv('ADZUNA_APP_ID')
ADZUNA_APP_KEY = os.getenv('ADZUNA_APP_KEY')

# Get environment variables (Set this in Azure Function App Configuration)
AZURE_STORAGE_ACCOUNT_NAME = os.getenv("AZURE_STORAGE_ACCOUNT_NAME")
AZURE_STORAGE_ACCOUNT_KEY =  os.getenv("AZURE_STORAGE_ACCOUNT_KEY")
FILESYSTEM_NAME = "raw-data"  # This is the container (or filesystem in ADLS Gen2)
DIRECTORY_NAME = "json"  # Folder inside ADLS Gen2

# Define the API endpoint and base parameters
url = "https://api.adzuna.com/v1/api/jobs/ca/search/"
base_params = {
    'app_id': ADZUNA_APP_ID,
    'app_key': ADZUNA_APP_KEY,
    'results_per_page': 50,  # Maximum allowed results per page
    'what_phrase': "data engineer",
    'max_days_old': 2,
    'sort_by': "date"
}


@app.route(route="generate_json")
def generate_json(req: func.HttpRequest) -> func.HttpResponse:
    print("Azure Function triggered to extract raw json data from Adzuna API.")

    # Initialize a list to store all job postings
    all_job_postings = []
    
    # Make the first request to determine the total number of pages
    print("Making the first request to determine the total number of pages")
    response = requests.get(f"{url}1", params=base_params)
    
    if response.status_code != 200:
        error_message = f"Error fetching page 1: {response.status_code}, {response.text}"
        print(error_message)
        return func.HttpResponse(error_message, status_code=response.status_code)

    data = response.json()  # Parse the JSON response
    total_results = data.get('count', 0)
    results_per_page = base_params['results_per_page']

    # Calculate the total number of pages
    total_pages = math.ceil(total_results / results_per_page)
    print(f"Total number of pages = {total_pages}")

    # Store the results from the first page
    all_job_postings.extend(data.get('results', []))

    # Loop through the remaining pages and request data from each
    print("Looping through the remaining pages to request data from each")
    for page in range(2, total_pages + 1):  # Start from page 2
        response = requests.get(f"{url}{page}", params=base_params)
        if response.status_code == 200:
            page_data = response.json()
            all_job_postings.extend(page_data.get('results', []))
        else:
            print(f"Error fetching page {page}: {response.status_code}, {response.text}")

    print(f"Total jobs retrieved: {len(all_job_postings)}")

    # Generate a filename with the current timestamp
    current_timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    file_name = f"adzuna_raw_data_{current_timestamp}.json"
    print(f"File name to store raw data: {file_name}")

    raw_json_data = json.dumps({"items": all_job_postings})
    raw_json_bytes = raw_json_data.encode('utf-8')
    data_length = len(raw_json_bytes)

    # Storing Adzuna JSON raw data to Azure
    print("Storing Adzuna JSON raw data to Azure")
    try:
        # Authenticate with ADLS Gen2
        service_client = DataLakeServiceClient(
            account_url=f"https://{AZURE_STORAGE_ACCOUNT_NAME}.dfs.core.windows.net",
            credential=AZURE_STORAGE_ACCOUNT_KEY
        )
        
        # Get File System (Container)
        file_system_client = service_client.get_file_system_client(FILESYSTEM_NAME)

        # Get or Create Directory
        directory_client = file_system_client.get_directory_client(DIRECTORY_NAME)
        try:
            directory_client.create_directory()
        except Exception as dir_err:
            print(f"Directory '{DIRECTORY_NAME}' might already exist: {dir_err}")
        
        # Upload JSON File
        file_client = directory_client.get_file_client(file_name)
        file_client.create_file()
        file_client.append_data(raw_json_bytes, offset=0, length=data_length)
        file_client.flush_data(data_length)

        print(f"File {file_name} successfully uploaded to ADLS Gen2.")
        return func.HttpResponse(
            f"JSON file '{file_name}' generated and uploaded successfully to ADLS Gen2.",
            status_code=200
        )

    except Exception as e:
        print(f"Error uploading file: {e}")
        return func.HttpResponse(f"Error generating or uploading JSON file to ADLS Gen2: {e}", status_code=500)