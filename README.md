# Future of Hiring – Job Market Pipeline with Azure Databricks & Power BI

## Project Overview
This project is an **end-to-end ETL (Extract, Transform, Load) pipeline** that automates the process of extracting **job market data in the United States** from the **Adzuna API**, transforming the raw data, and visualizing it using **Power BI**. The pipeline leverages **Azure Cloud Services**, including **Azure Functions, Data Factory, Databricks, and Delta Lake**, to provide scalable, efficient, and automated job market analytics.

This project is inspired by and adapted from **[Maksim Kazartsev's project](https://github.com/kazarmax/adzuna_etl_azure)**, which implemented a similar pipeline for job market data in **Canada**.

## Key Features
- **Automated Data Extraction**: Uses **Azure Functions** to fetch **real-time job listings** from the Adzuna API for jobs in the **United States**.
- **Secure Data Storage**: Stores raw job data in **Azure Data Lake Storage Gen2**, with **Azure Key Vault** managing API credentials securely.
- **Scalable ETL Pipeline**:
  - **Azure Data Factory** orchestrates data workflows, ensuring automation.
  - **Azure Databricks (PySpark)** transforms raw data and loads it into **Delta Lake**.
  - **Delta Lake** supports **incremental data loading** for efficiency.
- **Predictive Analytics**: Uses **Azure Databricks ML** to train models for forecasting **salary trends and hiring demand**.
- **Interactive Dashboards**: Connects **Power BI** to Delta Lake for **real-time job market insights**.

---

## Architecture Diagram
Below is an overview of the solution architecture:

1. **Azure Data Factory** triggers the pipeline on a schedule.
2. **Azure Functions** extract job listings from Adzuna API.
3. **Azure Data Lake Storage Gen2** stores raw job data.
4. **Azure Databricks (PySpark)** processes and cleans the data.
5. **Delta Lake** manages versioning and structured storage.
6. **Power BI** connects to Delta Lake to visualize job market trends.

---

## Tech Stack
### **Microsoft Azure Services:**
- **Azure Functions** – Fetches real-time job listings from the **Adzuna API**.
- **Azure Data Lake Storage Gen2** – Stores raw and processed job market data.
- **Azure Key Vault** – Manages API keys and sensitive credentials.
- **Azure Data Factory** – Orchestrates the entire ETL workflow.
- **Azure Databricks (PySpark)** – Transforms and analyzes data efficiently.
- **Delta Lake** – Ensures ACID transactions, schema enforcement, and versioning.
- **Power BI** – Visualizes insights with interactive dashboards.

### **Other Tools:**
- **Terraform** – Infrastructure as Code (IaC) for automating Azure resource deployment.
- **Python** – Used within **Azure Functions** and **Databricks Notebooks**.
- **Adzuna API** – Data source for job market listings.

---

## Setup & Deployment
### **1️⃣ Prerequisites**
- **Azure Account** with an active subscription.
- **Adzuna API Account** (Get credentials at [Adzuna Developer](https://developer.adzuna.com/)).
- **Terraform Installed** ([Install Terraform](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/infrastructure-as-code)).
- **Azure CLI Installed** ([Azure CLI Setup](https://learn.microsoft.com/en-us/cli/azure/)).
- **Power BI Desktop** ([Download Power BI](https://www.microsoft.com/en-us/power-platform/products/power-bi/downloads)).

### **2️⃣ Deploying Azure Resources with Terraform**
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/future-of-hiring.git
   cd future-of-hiring
   ```
2. Authenticate Terraform with **Azure Service Principal**:
   ```bash
   az ad sp create-for-rbac --name "myTerraformSP" --role Owner --scopes /subscriptions/<your-subscription-id>
   ```
   Copy the `appId`, `password`, `tenant`, and `subscriptionId` values.
3. Export credentials:
   ```bash
   export ARM_CLIENT_ID=<your_appId>
   export ARM_CLIENT_SECRET=<your-password>
   export ARM_TENANT_ID=<your-tenant>
   export ARM_SUBSCRIPTION_ID=<your-subscriptionId>
   ```
4. Initialize Terraform:
   ```bash
   terraform init
   ```
5. Apply the Terraform configuration:
   ```bash
   terraform apply
   ```

---

## ETL Pipeline Execution
### **Step 1: Azure Function for Data Extraction**
- Extracts **job market data** from the **Adzuna API**.
- Stores raw data as **JSON files** in **Azure Data Lake Storage Gen2**.
- Environment Variables configured in **Azure Key Vault**.

### **Step 2: Data Processing with Azure Databricks**
- **PySpark** transformations applied to clean data.
- Data deduplicated and stored in **Delta Lake** tables.

### **Step 3: Automating ETL in Azure Data Factory**
- **Triggers** execution every hour.
- Moves raw data from **JSON to Delta Lake**.
- Archives processed JSON files for **historical reference**.

### **Step 4: Power BI Visualization**
- Power BI connects to **Delta Lake Tables**.
- Provides **interactive analytics** on **job trends, salaries, and hiring demand**.

---

## Example Insights (Generated from Power BI)
- **Most in-demand roles**: Data Engineer, Machine Learning Engineer.
- **Top hiring locations**: New York, San Francisco, Seattle.
- **Salary trends over time**.
- **Company-wise job postings**.

---

## Contributing & Credits
### **Acknowledgments**
This project is based on the work of **Maksim Kazartsev**, who originally implemented a **similar ETL pipeline for Canada**. You can check out his project here: [GitHub Repository](https://github.com/kazarmax/adzuna_etl_azure).

### **Fair Use & Contribution**
- If you use this repository, **please give credit**.
- Modify the **Google Analytics tracking ID** if applicable.
- **Star this repo** ⭐ if you find it helpful!

---

## 📞 Contact
Feel free to reach out via:
- **[LinkedIn](https://www.linkedin.com/in/mohitsaigutha/)**
- **[Email](mailto:mohit.sai6@gmail.com)**

---

**© 2025 Mohit Sai Gutha** | Built with using **Azure, Databricks & Power BI**

