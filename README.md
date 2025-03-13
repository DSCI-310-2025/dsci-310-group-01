# dsci-310-group-01

# Project Title: Animal Adoption Prediction
Contributors: 
Abner Bal,
Kevin Jia,
Yuwen Luo


## Project Overview
This project aims to predict whether an animal in the **Long Beach Animal Shelter** will be adopted based on its attributes.
We use **classification modeling** to determine factors that influence adoption outcomes.

### **Problem Statement**
Animal shelters receive a high number of incoming pets, and not all of them get adopted.  
Our goal is to build a **predictive model** that helps shelters understand what factors contribute to **higher adoption rates**.

### **Dataset Used**
- [Long Beach Animal Shelter Data (TidyTuesday, 2025-03-04)](https://github.com/rfordatascience/tidytuesday/blob/main/data/2025/2025-03-04/readme.md)
<!-- - **Source:** [City of Long Beach Animal Care Services](https://github.com/rfordatascience/tidytuesday/blob/main/data/2025/2025-03-04) -->

## Project Overview
This project aims to predict whether an animal in the **Long Beach Animal Shelter** will be adopted based on its attributes.  
We use **classification modeling** to determine factors that influence adoption outcomes.

### Key Insights
The analysis applied a **Random Forest classification model** and found that **age, and sex** are the most influential factors in predicting whether an animal will be adopted. 
These findings suggest that animal shelters could improve adoption rates by focusing on younger and healthier animals, promoting adoption events during peak seasons, and providing more visibility for animals with medical needs.


## How to Run the Analysis
This project uses a **Docker container** to ensure a reproducible computational environment.

- Clone the Repository and navigate to the root of this project repository and run
```sh
git clone https://github.com/DSCI-310-2025/dsci-310-group-01.git
cd dsci-310-group-01
```

### Option 1:
- Start the Docker Container
Ensure Docker Desktop is installed and running. Then, in your terminal run:
```sh
docker-compose up -d
```

- Once the container has launched, retrieve the Jupyter Lab URL with the access token by running:
```sh
docker logs dsci-310-group-01-analysis-1
```
- Copy the full URL from the output (e.g., *http://127.0.0.1:8888/tree?token=379908fc5210652a35167325ba496af32271f1bf80129edc*) and paste it into your web browser to access Jupyter Lab.

- Open & Run the Notebook
Once in Jupyter Lab, navigate to `analysis.ipynb` and run the notebook to execute the analysis.

- Stop the Container (When Done)
To stop and remove the container, run:
```sh
docker-compose down
```

### Option 2:
- Build the Docker Image after clone the repository
```sh
docker build -t dsci-310-analysis .
```

- Run the Container
```sh
docker run --rm -it -p 8888:8888 -v $(pwd):/home/jovyan/work dsci-310-analysis
```

- Open a browser and go to http://localhost:8888.

- Once in Jupyter Lab, navigate to `analysis.ipynb` and run the notebook to execute the analysis.

### Option 3:
- After clone the repository, pull from DockerHub:
```sh
docker pull yuwen07/dsci-310-group-01
```
```sh
docker run --rm -it -p 8888:8888 -v $(pwd):/home/jovyan/work yuwen07/dsci-310-group-01
```
- Then, open a browser and go to http://localhost:8888. to access the Jupyter Lab.


## Dependencies
- **R version:** 4.3.1 (installed inside Docker)
- **Jupyter Lab** (included in the Docker container)
- **Installed R packages:**
  - `IRkernel` 
  - `tidyverse` 
  - `caret` 
  - `randomForest` 
  - `e1071` 

All dependencies are installed automatically when running the Docker container.

## Licenses
This project is **dual-licensed**: [see the license file here](LICENSE.md)

- The **code** (e.g., R scripts, workflows) is licensed under the [MIT License](https://opensource.org/license/MIT).
- The **non-code materials** (e.g., documentation, reports, figures) are licensed under the [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).





