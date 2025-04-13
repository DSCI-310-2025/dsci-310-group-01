# dsci-310-group-01

# 🐾 Project: Animal Adoption Prediction 

> DSCI 310 Group 01  
> Contributors: Abner Bal, Kevin Jia, Yuwen Luo

A data science pipeline to predict animal adoption outcomes using intake, age, species, and health features.



## Project Overview
This project aims to predict whether an animal in the **Long Beach Animal Shelter** will be adopted based on its attributes.
We use **classification modeling** to determine factors that influence adoption outcomes.

## Problem Statement
Animal shelters receive a high number of incoming pets, and not all of them get adopted.  
Our goal is to build a **predictive model** that helps shelters understand what factors contribute to **higher adoption rates**.

### Dataset Used
- [Long Beach Animal Shelter Data (TidyTuesday, 2025-03-04)](https://github.com/rfordatascience/tidytuesday/blob/main/data/2025/2025-03-04/readme.md)
<!-- - **Source:** [City of Long Beach Animal Care Services](https://github.com/rfordatascience/tidytuesday/blob/main/data/2025/2025-03-04) -->

## Key Insights
Our Random Forest classification model achieved an relative high accuracy in predicting animal adoption outcomes. The analysis revealed that sex/reproductive status, age, and intake type are the most influential factors in determining whether an animal will be adopted.

## Project Structure and Design

This project follows a modular design pattern:

- Core data analysis functions have been abstracted into the [`animalAdoptR`](https://github.com/DSCI-310-2025/animalAdoptR) package
- Analysis workflow is organized into discrete steps:
  - `scripts/`: Contains the individual R scripts for each analysis stage
  - `data/`: Stores raw and processed datasets
  - `models/`: Contains trained models
  - `results/`: Holds generated figures and tables
  - `dataValidation/`: Contains scripts for data validation checks
  - `reports/`: Holds the final analysis report in multiple formats
- `Makefile` orchestrates the entire analysis pipeline, ensuring reproducibility

## How to Run the Analysis

### Usage
This project uses a **Docker container** to ensure a reproducible computational environment.

- Clone the Repository and navigate to the root of this project repository and run
```sh
git clone https://github.com/DSCI-310-2025/dsci-310-group-01.git
cd dsci-310-group-01
```

### Option 1: Run with Docker Compose

**Start the Docker container**  
   Ensure Docker Desktop is installed and running. Then run:
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
 ---


## Makefile Workflow

We use a `Makefile` to automate the entire data analysis pipeline.


### To run the full pipeline

  This project uses a **Makefile** to automate the full analysis pipeline.
  ```bash
  make all
  ```
  This will: Download the dataset, Clean and preprocess the data, Perform exploratory data analysis (EDA), Train the model, Generate the final report (HTML and PDF)

 ### To clean all generated files
 ```bash
 make clean
 ```
 This will delete all intermediate and final outputs, resetting the project.


## Dependencies
- **R version:** 4.3.1 (installed inside Docker)
- **Jupyter Lab** (included in the Docker container)
- **Installed R packages:**
  - `IRkernel` (v1.3.0)
  - `tidyverse` (v2.0.0)
  - `caret` (v6.0-94)
  - `randomForest` (v4.7-1.1)
  - `e1071` (v1.7-14)
  - `pROC` (v1.18.5)
  - `docopt` (v0.7.1)
  - `rmarkdown` (v2.22)
  - `testthat` (v3.1.10)
  - `corrplot` (v0.92)
  - `animalAdoptR` (v0.1.0) - Custom package for animal shelter data analysis

All dependencies are installed automatically when running the Docker container.

## Contributing

We welcome contributions! Please follow the [CONTRIBUTING.md](./CONTRIBUTING.md) file to get started.


## Licenses
This project is **dual-licensed**: [see the license file here](LICENSE.md)

- The **code** (e.g., R scripts, workflows) is licensed under the [MIT License](https://opensource.org/license/MIT).
- The **non-code materials** (e.g., documentation, reports, figures) are licensed under the [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).



## Disclaimer:
We use only a selected subset of the dataset and perform several cleaning and feature engineering steps before modeling.



