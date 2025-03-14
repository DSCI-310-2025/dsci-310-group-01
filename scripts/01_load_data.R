# Load necessary libraries
library(tidyverse)
library(docopt)

# Define command-line interface
"This script loads raw longbeach data.

Usage:
  01_load_data.R --url=<url> --output_path=<output_path>

Options:
  --url=<url>                   URL of the dataset to download.
  --output_path=<output_path>   Path to save the downloaded dataset.
" -> doc

opt <- docopt(doc)

# Ensure the output directory exists
data_dir <- dirname(opt$output_path)
if (!dir.exists(data_dir)) {
  dir.create(data_dir, recursive = TRUE)
}

# Download the dataset
download.file(opt$url, destfile = opt$output_path, mode = "wb")
message("Data successfully downloaded and saved to ", opt$output_path)


# run the script in terminal (the root directory)
# Rscript scripts/01_load_data.R --url="https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-03-04/longbeach.csv" --output_path="data/raw/longbeach.csv"