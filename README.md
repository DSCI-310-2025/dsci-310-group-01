# dsci-310-group-01

# Project Title: Animal Adoption Prediction
Contributors: 
Abner Bal,
Kevin Jia,
Yuwen Luo


## Project Overview
This project aims to predict whether an animal in the **Long Beach Animal Shelter** will be adopted based on its attributes.
We use **classification modeling** to determine factors that influence adoption outcomes.

### **🔍 Problem Statement**
Animal shelters receive a high number of incoming pets, and not all of them get adopted.  
Our goal is to build a **predictive model** that helps shelters understand what factors contribute to **higher adoption rates**.

### **📊 Dataset Used**
- **Dataset:** [Long Beach Animal Shelter Data (TidyTuesday, 2025-03-04)](https://github.com/rfordatascience/tidytuesday/blob/main/data/2025/2025-03-04/readme.md)
<!-- - **Source:** [City of Long Beach Animal Care Services](https://github.com/rfordatascience/tidytuesday/blob/main/data/2025/2025-03-04) -->

## How to Run the Analysis
This project uses a **Docker container** to ensure a reproducible computational environment.

**1️. Clone the Repository**
```sh
git clone https://github.com/DSCI-310-2025/dsci-310-group-01.git
cd dsci-310-group-01
```
**2. Start the Docker Container**

Ensure Docker Desktop is installed and running. Then, in your terminal, navigate to the root of this project repository and run:
```sh
docker-compose up -d
```

**3. Retrieve the Jupyter Access Token**

Once the container has launched, retrieve the Jupyter Lab URL with the access token by running:
```sh
docker logs dsci-310-group-01-analysis-1
```

Copy the full URL from the output (e.g., **http://127.0.0.1:8888/tree?token=379908fc5210652a35167325ba496af32271f1bf80129edc**) and paste it into your web browser to access Jupyter Lab.

**4. Open & Run the Notebook**
Once in Jupyter Lab, navigate to `analysis.ipynb` and run the notebook to execute the analysis.

**5. Stop the Container (When Done)**
To stop and remove the container, run:
```sh
docker-compose down
```


## Dependencies
- **R version:** 4.3.1 (installed inside Docker)
- **Jupyter Lab** (included in the Docker container)
- **Installed R packages:**
  - `IRkernel` 
  - `tidyverse` 
  - `caret` 
  - `randomForest` 
  - `e1071` 
  - `pROC`

All dependencies are installed automatically when running the Docker container.


## Licenses
MIT License, [see the license file](LICENSE.md).


