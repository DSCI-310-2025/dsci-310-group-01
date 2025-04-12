library(docopt)
library(tidyverse)
library(animalAdoptR)


"
This script performs exploratory data analysis (EDA) on the cleaned longbeach dataset,
generating plots and summary tables to understand data distributions and trends.

Usage:
  03_eda.R --input=<input> --output_prefix=<output_prefix> --table_dir=<table_dir>

Options:
  --input=<input>                 Path to the cleaned dataset (CSV file).
  --output_prefix=<output_prefix>  Prefix for saving EDA plots.
  --table_dir=<table_dir>         Directory to save summary tables.
" -> doc

if (interactive()) {
  opt <- list(
    input = "data/processed/longbeach_cleaned.csv",
    output_prefix = "results/figures",
    table_dir = "results/tables"
  )
} else {
  opt <- docopt(doc)
}

# Load the cleaned dataset
data <- load_data(opt$input)

# Ensure output directories exist
ensure_dir_exists(opt$table_dir)
ensure_dir_exists(opt$output_prefix)

# --- Tables ---
save_count_table(data, "adopted", file.path(opt$table_dir, "adopted_distribution.csv"))
save_count_table(data, "animal_type", file.path(opt$table_dir, "animal_type_counts.csv"))
save_count_table(data, "intake_condition", file.path(opt$table_dir, "intake_condition_counts.csv"))
save_count_table(data, "intake_type", file.path(opt$table_dir, "intake_type_counts.csv"))

cat("Summary tables saved in", opt$table_dir, "\n")

# --- Plots ---
# 1. Adoption Rate Distribution
plot1 <- plot_adoption_distribution(data)
ggsave(filename = file.path(opt$output_prefix, "adoption_rate.png"), plot = plot1, width = 7, height = 7)

# 2. Adoption Rate by Animal Type
plot_grouped_adoption(
  data,
  group_col = "animal_type",
  title = "Adoption Rate by Animal Type",
  xlab = "Animal Type",
  output_path = file.path(opt$output_prefix, "adoption_by_animal_type.png")
)

# 3. Adoption Rate by Intake Condition
plot_grouped_adoption(
  data,
  group_col = "intake_condition",
  title = "Adoption Rate by Intake Condition",
  xlab = "Intake Condition",
  output_path = file.path(opt$output_prefix, "adoption_by_intake_condition.png")
)

# 4. Adoption Rate by Intake Type
plot_grouped_adoption(
  data,
  group_col = "intake_type",
  title = "Adoption Rate by Intake Type",
  xlab = "Intake Type",
  output_path = file.path(opt$output_prefix, "adoption_by_intake_type.png")
)

# 5. Age Distribution Plot
plot_age_distribution(
  data,
  output_path = file.path(opt$output_prefix, "age_distribution.png")
)

# 6. Monthly Adoption Trend Plot
plot6 <- ggplot(data, aes(x = month, fill = adopted)) +
  geom_bar() +
  labs(title = "Monthly Adoption Trend", x = "Month", y = "Count") +
  theme_minimal(base_size = 17) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
ggsave(filename = file.path(opt$output_prefix, "monthly_trends.png"), plot = plot6, width = 25, height = 10)

# 7. Age Boxplot (Additional EDA)
p_box <- ggplot(data, aes(y = age, x = adopted)) +
  geom_boxplot() +
  labs(title = "(Boxplot) Age Distribution by Adoption Status", x = "Adopted", y = "Age (Years)") +
  theme_minimal(base_size = 18) +
  theme(
    axis.text.x = element_text(size = 15),
    axis.text.y = element_text(size = 15),
    plot.title = element_text(size = 16, face = "bold")
  )
ggsave(filename = file.path(opt$output_prefix, "age_boxplot_additional.png"), plot = p_box, width = 8, height = 6)

# 8. Seasonal Adoption Trend
p_season <- ggplot(data, aes(x = season, fill = adopted)) +
  geom_bar() +
  labs(title = "Adoption Trends by Season", x = "Season", y = "Count") +
  theme_minimal(base_size = 18) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 18),
    axis.text.y = element_text(size = 18),
    legend.text = element_text(size = 18),
    legend.title = element_text(size = 18),
    plot.title = element_text(size = 20, face = "bold")
  )
ggsave(filename = file.path(opt$output_prefix, "adoption_trends_by_season_updated.png"), plot = p_season, width = 10, height = 8)


# Correlation Matrix Check (added for Milestone 4)
library(corrplot)

# Encode factor variables as numeric for correlation analysis
df_numeric <- data %>%
  mutate(across(where(is.factor), ~ as.numeric(as.factor(.)))) %>%
  select(where(is.numeric))

# Calculate correlation matrix
cor_matrix <- cor(df_numeric, use = "pairwise.complete.obs")

# Save correlation plot
corrplot_path <- file.path(opt$output_prefix, "correlation_heatmap.png")
png(corrplot_path, width = 1000, height = 900)
corrplot(cor_matrix, method = "color", tl.cex = 0.9, number.cex = 0.8, addCoef.col = "black")
dev.off()

cat("Correlation heatmap saved to:", corrplot_path, "\n")

cat("All EDA plots and tables are generated and saved.\n")
