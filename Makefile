# PHONY targets
.PHONY: all clean data eda report

# Run full pipeline
all: data/raw/longbeach.csv \
	data/processed/longbeach_cleaned.csv data/processed/longbeach_transformed.csv \
	results/tables results/figures \
	reports/animal_adoption_analysis.html reports/animal_adoption_analysis.pdf

# Step 1: Download raw data
data/raw/longbeach.csv: scripts/01_load_data.R
	@mkdir -p data/raw
	Rscript scripts/01_load_data.R --url="https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-03-04/longbeach.csv" --output_path=data/raw/longbeach.csv
	echo "01_load_data.R done."

# Step 2: Clean and transform data
data/processed/longbeach_cleaned.csv data/processed/longbeach_transformed.csv: scripts/02_clean_transform_data.R data/raw/longbeach.csv
	@mkdir -p data/processed results/tables
	Rscript scripts/02_clean_transform_data.R --input=data/raw/longbeach.csv --output_clean=data/processed/longbeach_cleaned.csv --output_transform=data/processed/longbeach_transformed.csv --table_dir=results/tables
	echo "02_clean_transform_data.R done."

# Step 3: Generate EDA tables and plots
results/tables results/figures: scripts/03_eda.R data/processed/longbeach_cleaned.csv
	@mkdir -p results/figures results/tables
	Rscript scripts/03_eda.R --input=data/processed/longbeach_cleaned.csv --output_prefix=results/figures --table_dir=results/tables
	echo "03_eda.R done."


# Step 4: Train model and save results
models/longbeach_model.rds results/metrics.csv results/figures/feature_importance.png results/figures/confusion_matrix.png: scripts/04_modeling.R data/processed/longbeach_transformed.csv
	@mkdir -p models results/figures
	Rscript scripts/04_modeling.R --input=data/processed/longbeach_transformed.csv --output_model=models/longbeach_model.rds --metrics=results/metrics.csv --figures_dir=results/figures

# Step 5: Render final report (HTML and PDF)
reports/animal_adoption_analysis.html reports/animal_adoption_analysis.pdf: reports/animal_adoption_analysis.qmd results/tables results/figures
	quarto render reports/animal_adoption_analysis.qmd --to html
	quarto render reports/animal_adoption_analysis.qmd --to pdf
	echo "Reports generated: reports/animal_adoption_analysis.html and reports/animal_adoption_analysis.pdf"

# Clean generated files
clean:
	rm -f data/raw/*.csv 
	rm -f data/processed/*.csv 
	rm -rf results/tables results/figures
	rm -f models/*.rds
	rm -rf reports/animal_adoption_analysis.html reports/animal_adoption_analysis.pdf
	