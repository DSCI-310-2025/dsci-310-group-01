library(tidyverse)
library(docopt)

source("R/data_loading.R")  # Load the functions
source("R/data_prep.R")

"This script cleans the raw longbeach dataset, performs preprocessing, 
transforming and feature engineering to prepare data for EDA and modeling.

Usage:
  02_clean_transform_data.R --input=<input> --output_clean=<output_clean> --output_transform=<output_transform> 

Options:
  --input=<input>                 Path to the raw dataset (CSV file).
  --output_clean=<output_clean>   Path to save the cleaned dataset.
  --output_transform=<output_transform>  Path to save the transformed dataset.
" -> doc

opt <- docopt(doc)

# Check if output directories exist, create if needed
ensure_dir_exists(dirname(opt$output_clean))
ensure_dir_exists(dirname(opt$output_transform))

# Load dataset
longbeach <- load_data(opt$input)

# Part 1: Data Cleaning & Preprocessing
longbeach_cleaned <- longbeach %>%
  filter(!is.na(outcome_type)) %>%  # Remove rows with missing outcome_type (target variable)
  filter(!is.na(dob)) %>%  # Remove rows with missing DOB
  filter(as.Date(dob) <= as.Date("2024-12-31")) %>% # Remove rows with future dates
  select(-animal_id, -animal_name, -secondary_color, -jurisdiction, -latitude, -longitude, -was_outcome_alive, -outcome_subtype, -reason_for_intake, -crossing) 
  # Drop unimportant columns 

cat("After initial cleaning:", dim(longbeach_cleaned)[1], "rows\n")

# View unique values and their counts in outcome_type
outcome_summary <- longbeach_cleaned %>% count(outcome_type, sort = TRUE)
print(outcome_summary)

# Create the adopted column (target variable) based on outcome_type
longbeach_cleaned <- longbeach_cleaned %>%
  mutate(adopted = ifelse(outcome_type %in% c("adoption", "foster to adopt"), "Yes", "No"))
cat("Target variable 'adopted' distribution:", "\n")
print(table(longbeach_cleaned$adopted))

# Convert DOB to Ages (integer)
longbeach_cleaned$age <- calculate_age_years(longbeach_cleaned$dob)


longbeach_cleaned <- longbeach_cleaned %>%
  mutate(month = format(as.Date(outcome_date, format = "%Y-%m-%d"), "%m"),
         season = assign_season(month))

# Save cleaned dataset
write_csv(longbeach_cleaned, opt$output_clean)
cat("Saving cleaned dataset to:", opt$output_clean, "\n")


# Part 2: Data transformation & Feature Engineering
cat("Starting data transformation and feature engineering. \n")

# Remove ages  > 30
longbeach_transformed <- longbeach_cleaned %>% filter(age <= 30)
cat("After removing ages > 30:", dim(longbeach_cleaned)[1], "rows\n")


# Group rare animal types (less than 200 instances)
rare_animal_types <- c("reptile", "guinea pig", "livestock", "amphibian")

# Group rare intake conditions (less than 200 instances)
rare_intake_conditions <- c("aged", "behavior moderate", "behavior mild", 
                           "behavior severe", "welfare seizures", "intakeexam")

# Group rare intake types (with fewer than 200 instances)
rare_intake_types <- c("foster", "adopted animal return", "euthanasia required", "trap, neuter, return", "safe keep", "quarantine")

# Group rare categories using the function
longbeach_transformed <- longbeach_transformed %>%
  group_rare_categories("animal_type", rare_animal_types) %>%
  group_rare_categories("intake_condition", rare_intake_conditions) %>%
  group_rare_categories("intake_type", rare_intake_types)

# Convert categorical variables to factors
columns_to_convert <- c("animal_type", "sex", "intake_condition", 
                        "intake_type", "season", "adopted")
longbeach_transformed <- convert_to_factors(longbeach_transformed, columns_to_convert)


# Feature selection - keep only necessary columns for modeling
longbeach_transformed <- longbeach_transformed %>%
  select(animal_type, age, sex, intake_condition, intake_type, season, adopted)

# Verify no missing values
missing_values <- colSums(is.na(longbeach_transformed))
cat("Check Missing values in transformed dataset:", "\n")
print(missing_values)

# Save transformed dataset
write_csv(longbeach_transformed, opt$output_transform)
cat("Saving transformed dataset to:", opt$output_transform, "\n")


# run the script in terminal (the root directory)
# Rscript scripts/02_clean_transform_data.R --input="data/raw/longbeach.csv"     --output_clean="data/processed/longbeach_cleaned.csv"     --output_transform="data/processed/longbeach_transformed.csv"