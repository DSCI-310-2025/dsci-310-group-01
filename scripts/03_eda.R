#!/usr/bin/env Rscript
"
Usage:
  03.eda.R --input=<input_file> --output_prefix=<output_prefix>

Options:
  --input=<input_file>        
  --output_prefix=<prefix>   
" -> doc

library(docopt)
opts <- docopt(doc)

library(readr)
library(ggplot2)
library(dplyr)


data <- read_csv(opts$input)


# There is no 'age' and 'month' column, then compute age from dob, extract month from 'outcome_date'
data <- data %>%
  mutate(
    age = as.integer(as.numeric(difftime(Sys.Date(), as.Date(dob, format = "%Y-%m-%d"), units = "days")) / 365),
    month = format(as.Date(outcome_date, format = "%Y-%m-%d"), "%Y-%m")
  )


# 1. Adoption Rate distribution plot
plot1 <- ggplot(data, aes(x = adopted)) +
  geom_bar(fill = "steelblue") +
  geom_text(stat = 'count', aes(label = after_stat(count)), vjust = -0.5, size = 6) +
  labs(title = title = "Adoption Rate Distribution", x = "Adopted", y = "Count") +
  theme_minimal(base_size = 20)
ggsave(filename = paste0(opts$output_prefix, "_adoption_rate.png"), plot = plot1, width = 7, height = 7)

# 2. Adoption rate by animal type plot
plot2 <- ggplot(data, aes(x = animal_type, fill = adopted)) +
  geom_bar(position = "dodge") +
  labs(title = "Adoption Rate by Animal Type", x = "Animal Type", y = "Count") +
  theme_minimal(base_size = 17) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(filename = paste0(opts$output_prefix, "_adoption_by_animal_type.png"), plot = plot2, width = 10, height = 8)

# 3. Age distribution plot by adoption status
plot3 <- ggplot(data, aes(x = age, fill = adopted)) +
  geom_histogram(bins = 30, alpha = 0.7, position = "identity", color = "black") +
  labs(title = "Age Distribution by Adoption Status", x = "Age (years)", y = "Count") +
  theme_minimal(base_size = 15)
ggsave(filename = paste0(opts$output_prefix, "_age_distribution.png"), plot = plot3, width = 15, height = 10)


# 4. Adoption rate by intake condition plot 
plot4 <- ggplot(data, aes(x = intake_condition, fill = adopted)) +
    geom_bar(position = "dodge") +
    labs(title = "Adoption Rate by Intake Condition", x = "Intake Condition", y = "Count") +
    theme_minimal(base_size = 16) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(filename = paste0(opts$output_prefix, "_adoption_by_intake_condition.png"), plot = plot4, width = 16, height = 13)


# 5. Monthly adoption trend plot
plot5 <- ggplot(data, aes(x = month, fill = adopted)) +
    geom_bar() +
    labs(title = "Monthly Adoption Trend", x = "Month", y = "Count") +
    theme_minimal(base_size = 17) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
  ggsave(filename = paste0(opts$output_prefix, "_monthly_trends.png"), plot = plot5, width = 25, height = 10)


# 6. Adoption rate by intake type plot
plot6 <- ggplot(data, aes(x = intake_type, fill = adopted)) +
    geom_bar(position = "dodge") +
    labs(title = "Adoption Rate by Intake Type", x = "Intake Type", y = "Count") +
    theme_minimal(base_size = 16) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  ggsave(filename = paste0(opts$output_prefix, "_adoption_by_intake_type.png"), plot = plot6, width = 15, height = 14)


# 7. Boxplot of age by adoption status
plot7 <- ggplot(data, aes(x = adopted, y = age)) +
  geom_boxplot() +
  labs(title = "Age Boxplot by Adoption Status", x = "Adopted", y = "Age (years)") +
  theme_minimal(base_size = 14)
ggsave(filename = paste0(opts$output_prefix, "_age_boxplot.png"), plot = plot7, width = 8, height = 6)

cat("EDA plots generated and saved!\n")


