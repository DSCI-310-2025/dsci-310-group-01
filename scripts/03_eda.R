#!/usr/bin/env Rscript
"
This script computes exploratory data analysis (EDA) on the cleaned / transformed longbeach dataset,
which generates various plots to help understand the data distribution and trends, and saves the figures.

Usage:
  03_eda.R --input=<input> --output_prefix=<output_prefix>

Options:
  --input=<input>               Path to the cleaned dataset (CSV file).
  --output_prefix=<output_prefix>  Prefix for saving EDA plots.
" -> doc

if (interactive()) {
  opt <- list(input = "data/processed/longbeach_cleaned.csv",
              output_prefix = "results/eda")
} else {
  opt <- docopt(doc)
}

library(docopt)
library(tidyverse)

# Load the transformed dataset
cat("Loading transformed dataset from:", opt$input, "\n")
data <- read_csv(opt$input)
cat("Dataset dimensions:", dim(data)[1], "rows,", dim(data)[2], "columns\n")


# 1. Adoption Rate distribution plot
plot1 <- ggplot(data, aes(x = adopted)) +
  geom_bar(fill = "steelblue") +
  geom_text(stat = 'count', aes(label = after_stat(count)), vjust = -0.5, size = 6) +
  labs(title = "Adoption Rate Distribution", x = "Adopted", y = "Count") +
  theme_minimal(base_size = 20)
ggsave(filename = paste0(opt$output_prefix, "_adoption_rate.png"), plot = plot1, width = 7, height = 7)

# 2. Adoption rate by animal type plot
plot2 <- ggplot(data, aes(x = animal_type, fill = adopted)) +
  geom_bar(position = "dodge") +
  labs(title = "Adoption Rate by Animal Type", x = "Animal Type", y = "Count") +
  theme_minimal(base_size = 17) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(filename = paste0(opt$output_prefix, "_adoption_by_animal_type.png"), plot = plot2, width = 10, height = 8)

# 3. Age distribution plot by adoption status
plot3 <- ggplot(data, aes(x = age, fill = adopted)) +
  geom_histogram(bins = 30, alpha = 0.7, position = "identity", color = "black") +
  labs(title = "Age Distribution by Adoption Status", x = "Age (years)", y = "Count") +
  theme_minimal(base_size = 15)
ggsave(filename = paste0(opt$output_prefix, "_age_distribution.png"), plot = plot3, width = 15, height = 10)


# 4. Adoption rate by intake condition plot 
plot4 <- ggplot(data, aes(x = intake_condition, fill = adopted)) +
    geom_bar(position = "dodge") +
    labs(title = "Adoption Rate by Intake Condition", x = "Intake Condition", y = "Count") +
    theme_minimal(base_size = 16) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(filename = paste0(opt$output_prefix, "_adoption_by_intake_condition.png"), plot = plot4, width = 16, height = 13)


# 5. Monthly adoption trend plot
plot5 <- ggplot(data, aes(x = month, fill = adopted)) +
    geom_bar() +
    labs(title = "Monthly Adoption Trend", x = "Month", y = "Count") +
    theme_minimal(base_size = 17) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
  ggsave(filename = paste0(opt$output_prefix, "_monthly_trends.png"), plot = plot5, width = 25, height = 10)


# 6. Adoption rate by intake type plot
plot6 <- ggplot(data, aes(x = intake_type, fill = adopted)) +
    geom_bar(position = "dodge") +
    labs(title = "Adoption Rate by Intake Type", x = "Intake Type", y = "Count") +
    theme_minimal(base_size = 16) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  ggsave(filename = paste0(opt$output_prefix, "_adoption_by_intake_type.png"), plot = plot6, width = 15, height = 14)



# Additional EDA: Boxplot Analysis and Seasonal Trends

# Create a boxplot of Age Distribution by Adoption Status
p_box <- ggplot(data, aes(y = age, x = adopted)) +
  geom_boxplot() +
  labs(title = "Age Distribution by Adoption Status", x = "Adopted", y = "Age (Years)") +
  theme_minimal(base_size = 14)
ggsave(filename = paste0(opt$output_prefix, "_age_boxplot_additional.png"), plot = p_box, width = 8, height = 6)
cat("Saved additional Age Boxplot.\n")

# Remove unrealistic ages (age > 30) from the dataset
data <- data %>%
  filter(age <= 30)
cat("Removed unrealistic ages (age > 30). New dataset dimensions:", dim(data)[1], "rows.\n")

# Ensure 'month' is extracted correctly from 'outcome_date'
data <- data %>%
  mutate(month = format(as.Date(outcome_date, format = "%Y-%m-%d"), "%m"))
cat("Extracted month from outcome_date.\n")

# 7. Create a new 'season' column based on the month
data <- data %>%
  mutate(season = case_when(
    month %in% c("12", "01", "02") ~ "Winter",
    month %in% c("03", "04", "05") ~ "Spring",
    month %in% c("06", "07", "08") ~ "Summer",
    month %in% c("09", "10", "11") ~ "Fall",
    TRUE ~ "Unknown"
  ))
cat("Created new season column based on month.\n")

# Re-run the plot: Adoption Trends by Season
p_season <- ggplot(data, aes(x = season, fill = adopted)) +
  geom_bar() +
  labs(title = "Adoption Trends by Season", x = "Season", y = "Count") +
  theme_minimal(base_size = 14)
ggsave(filename = paste0(opt$output_prefix, "_adoption_trends_by_season_updated.png"), plot = p_season, width = 10, height = 8)


cat("All EDA plots generated and saved.\n")
