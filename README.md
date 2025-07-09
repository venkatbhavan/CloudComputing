#  Students Marks Viewer with Azure Blob Storage

This is a Flask web application that displays student marks based on an ID input. 
The data is stored as a CSV file in **Azure Blob Storage** and retrieved dynamically by the app each time a request is made.

##  Demo

🔗 [flaskmarksapp.azurewebsites.net](https://flaskmarksapp.azurewebsites.net)

---

##  Features

-  Flask Web Application with input-based mark retrieval
-  Data stored in Azure Blob Storage
-  Deployed to Azure App Service (Linux)
-  Infrastructure as Code via ARM template
-  Supports auto deployment via GitHub

---

# Tech Stack

| Layer        | Service / Tool                  |
|--------------|----------------------------------|
| Backend      | Python 3.10, Flask               |
| Storage      | Azure Blob Storage (CSV)         |
| Deployment   | Azure App Service (Linux)        |
| IaC          | ARM Template (JSON)              |

---

 # How we have created 

- Created a azure blob storage and stored marks.csv.
- Created a web application using Fast API and Python to fetch the marks using student id and DOB.
- Created a Azure resource group
  az group create --name flaskmarks-rg --location westeurope
- Created a ARM template for the following :
            App Service Plan (Linux, Free Tier)
            Web App (Flask app hosted on Linux using Python 3.10)
            Web App Configuration (Environment Variables)
  
- Run the ARM template using command
    az webapp deployment source config  --name flaskmarksapp  --resource-group flaskmarks-rg  --repo-url https://github.com/venkatbhavan/CloudComputing.git  --branch main  --manual-integration

- Linked github repo to azure for auto deployment
- Auto scaling is provided by App service
- Application will be running in the url provided by app service

  



