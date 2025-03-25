library(docopt)
library(tidyverse)

source("R/data_loading.R")  # Load the functions

"
This script computes exploratory data analysis (EDA) on the cleaned longbeach dataset,
which generates various plots to help understand the data distribution and trends, and saves the figures.

Usage:
  03_eda.R --input=<input> --output_prefix=<output_prefix> --table_dir=<table_dir>

Options:
  --input=<input>               Path to the cleaned dataset (CSV file).
  --output_prefix=<output_prefix>  Prefix for saving EDA plots.
  --table_dir=<table_dir>       Directory to save summary tables.
" -> doc



if (interactive()) {
  opt <- list(input = "data/processed/longbeach_cleaned.csv",
              output_prefix = "results/figures",
              table_dir = "results/tables")
} else {
  opt <- docopt(doc)
}

# Load the cleaned dataset
data <- load_data(opt$input)

# Ensure tables & figures directories exist before saving outputs
ensure_dir_exists(opt$table_dir)
ensure_dir_exists(opt$output_prefix)


# Table: Save adoption outcomes distribution as a CSV
adopted_counts <- data %>% count(adopted)
write_csv(adopted_counts, file.path(opt$table_dir, "adopted_distribution.csv"))
cat("Adoption outcome distribution saved to:", file.path(opt$table_dir, "adopted_distribution.csv"), "\n")

# Tables: count frequency of each animal type, intake condition, and intake type
animal_counts <- data %>% count(animal_type, sort = TRUE)
intake_counts <- data %>% count(intake_condition, sort = TRUE)
intake_type_counts <- data %>% count(intake_type, sort = TRUE)
# Save tables for .qmd report
write_csv(animal_counts, file.path(opt$table_dir, "animal_type_counts.csv"))
write_csv(intake_counts, file.path(opt$table_dir, "intake_condition_counts.csv"))
write_csv(intake_type_counts, file.path(opt$table_dir, "intake_type_counts.csv"))
cat("Saved counts summary tables in", opt$table_dir, "\n")


# 1. Adoption Rate distribution plot
plot1 <- ggplot(data, aes(x = adopted)) +
  geom_bar(fill = "steelblue") +
  geom_text(stat = 'count', aes(label = after_stat(count)), vjust = -0.5, size = 6) +
  labs(title = "Adoption Rate Distribution", x = "Adopted", y = "Count") +
  theme_minimal(base_size = 16)
ggsave(filename = file.path(opt$output_prefix, "adoption_rate.png"), plot = plot1, width = 7, height = 7)

# 2. Adoption rate by animal type plot
plot2 <- ggplot(data, aes(x = animal_type, fill = adopted)) +
  geom_bar(position = "dodge") +
  labs(title = "Adoption Rate by Animal Type", x = "Animal Type", y = "Count") +
  theme_minimal(base_size = 17) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(filename = file.path(opt$output_prefix, "adoption_by_animal_type.png"), plot = plot2, width = 10, height = 8)

# 3. Adoption rate by intake condition plot 
plot3 <- ggplot(data, aes(x = intake_condition, fill = adopted)) +
    geom_bar(position = "dodge") +
    labs(title = "Adoption Rate by Intake Condition", x = "Intake Condition", y = "Count") +
    theme_minimal(base_size = 20) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 18),
          axis.text.y = element_text(size = 18),
          legend.text = element_text(size = 18),  # Increase legend text
          legend.title = element_text(size = 18),
          plot.title = element_text(size = 24, face = "bold"))
ggsave(filename = file.path(opt$output_prefix, "adoption_by_intake_condition.png"), plot = plot3, width = 16, height = 13)

# 4. Adoption rate by intake type plot
plot4 <- ggplot(data, aes(x = intake_type, fill = adopted)) +
    geom_bar(position = "dodge") +
    labs(title = "Adoption Rate by Intake Type", x = "Intake Type", y = "Count") +
    theme_minimal(base_size = 20) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 18),
          axis.text.y = element_text(size = 18),
          legend.text = element_text(size = 18),  # Increase legend text
          legend.title = element_text(size = 18),
          plot.title = element_text(size = 24, face = "bold"))
  ggsave(filename = file.path(opt$output_prefix, "adoption_by_intake_type.png"), plot = plot4, width = 15, height = 14)

# 5. Age distribution plot by adoption status
plot5 <- ggplot(data, aes(x = age, fill = adopted)) +
  geom_histogram(bins = 30, alpha = 0.7, position = "identity", color = "black") +
  labs(title = "Age Distribution by Adoption Status", x = "Age (years)", y = "Count") +
  theme_minimal(base_size = 20) +
  theme(axis.text.x = element_text(size = 22),
        axis.text.y = element_text(size = 20),
        legend.text = element_text(size = 20),
        legend.title = element_text(size = 20),
        plot.title = element_text(size = 22, face = "bold"))
ggsave(filename = file.path(opt$output_prefix, "age_distribution.png"), plot = plot5, width = 15, height = 10)

# 6. Monthly adoption trend plot
plot6 <- ggplot(data, aes(x = month, fill = adopted)) +
    geom_bar() +
    labs(title = "Monthly Adoption Trend", x = "Month", y = "Count") +
    theme_minimal(base_size = 17) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
  ggsave(filename = file.path(opt$output_prefix, "monthly_trends.png"), plot = plot6, width = 25, height = 10)


# Additional EDA: Boxplot Analysis for "AGE" outliers and Seasonal Trends

# Boxplot of Age Distribution by Adoption Status to finder outliers in "Age"
p_box <- ggplot(data, aes(y = age, x = adopted)) +
  geom_boxplot() +
  labs(title = "(Boxplot) Age Distribution by Adoption Status", x = "Adopted", y = "Age (Years)") +
  theme_minimal(base_size = 18) +
  theme(axis.text.x = element_text(size = 15), 
        axis.text.y = element_text(size = 15),
        plot.title = element_text(size = 16, face = "bold"))
ggsave(filename = file.path(opt$output_prefix, "age_boxplot_additional.png"), plot = p_box, width = 8, height = 6)

# Re-run the trend plot: Seasonal adoption trend plot
p_season <- ggplot(data, aes(x = season, fill = adopted)) +
  geom_bar() +
  labs(title = "Adoption Trends by Season", x = "Season", y = "Count") +
  theme_minimal(base_size = 18) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 18),  
        axis.text.y = element_text(size = 18),
        legend.text = element_text(size = 18),
        legend.title = element_text(size = 18),
        plot.title = element_text(size = 20, face = "bold"))
ggsave(filename = file.path(opt$output_prefix, "adoption_trends_by_season_updated.png"), plot = p_season, width = 10, height = 8)

cat("All EDA plots and tables are generated and saved.\n")

# run the script in terminal (the root directory)
# Rscript scripts/03_eda.R --input="data/processed/longbeach_cleaned.csv"     --output_prefix="results/figures"     --table_dir="results/tables"
