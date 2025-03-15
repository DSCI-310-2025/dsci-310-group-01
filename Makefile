# PHONY targets
.PHONY: all clean report

# Run full pipeline
all: data/raw/longbeach.csv \
	data/processed/longbeach_cleaned.csv data/processed/longbeach_transformed.csv 

# Step 1: Download raw data
data/raw/longbeach.csv: scripts/01_load_data.R
	@mkdir -p data/raw
	Rscript scripts/01_load_data.R --url="https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-03-04/longbeach.csv" --output_path=data/raw/longbeach.csv

# Step 2: Clean and transform data
data/processed/longbeach_cleaned.csv data/processed/longbeach_transformed.csv: scripts/02_clean_transform_data.R data/raw/longbeach.csv
	@mkdir -p data/processed results/tables
	Rscript scripts/02_clean_transform_data.R --input=data/raw/longbeach.csv --output_clean=data/processed/longbeach_cleaned.csv --output_transform=data/processed/longbeach_transformed.csv --table_dir=results/tables

# Clean generated files
clean:
	rm -f data/raw/*.csv 
	rm -f data/processed/*.csv 
	rm -rf results/tables/*
