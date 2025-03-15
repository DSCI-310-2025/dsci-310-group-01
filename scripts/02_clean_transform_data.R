library(tidyverse)
library(docopt)

"This script cleans the raw longbeach dataset, performs preprocessing, 
transforming and feature engineering to prepare data for EDA and modeling.

Usage:
  02_clean_transform_data.R --input=<input> --output_clean=<output_clean> --output_transform=<output_transform> [--table_dir=<table_dir>]

Options:
  --input=<input>                 Path to the raw dataset (CSV file).
  --output_clean=<output_clean>   Path to save the cleaned dataset.
  --output_transform=<output_transform>  Path to save the transformed dataset.
  --table_dir=<table_dir>         Directory to save summary tables. [Optional argument]
" -> doc

opt <- docopt(doc)

# Check if output directories exist, create if needed
dir.create(dirname(opt$output_clean), recursive = TRUE, showWarnings = FALSE)
dir.create(dirname(opt$output_transform), recursive = TRUE, showWarnings = FALSE)

# Load dataset
cat("Loading dataset from:", opt$input, "\n")
longbeach <- read_csv(opt$input)
cat("Original dataset dimensions:", dim(longbeach)[1], "rows,", dim(longbeach)[2], "columns\n")

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
longbeach_cleaned$age <- as.numeric(difftime(Sys.Date(), 
                                             as.Date(longbeach_cleaned$dob, format="%Y-%m-%d"), 
                                             units="days")) / 365
# Convert Age to Integer
longbeach_cleaned$age <- as.integer(longbeach_cleaned$age)

# Create month and season features
longbeach_cleaned <- longbeach_cleaned %>%
  mutate(month = format(as.Date(outcome_date, format="%Y-%m-%d"), "%m"))

longbeach_cleaned <- longbeach_cleaned %>%
  mutate(season = case_when(
    month %in% c("12", "01", "02") ~ "Winter",
    month %in% c("03", "04", "05") ~ "Spring",
    month %in% c("06", "07", "08") ~ "Summer",
    month %in% c("09", "10", "11") ~ "Fall",
    TRUE ~ "Unknown"
  ))


# Save cleaned dataset
write_csv(longbeach_cleaned, opt$output_clean)
cat("Saving cleaned dataset to:", opt$output_clean, "\n")


# Part 2: Data transformation & Feature Engineering
cat("Starting data transformation and feature engineering. \n")

# Remove ages  > 30
longbeach_transformed <- longbeach_cleaned %>% filter(age <= 30)
cat("After removing ages > 30:", dim(longbeach_cleaned)[1], "rows\n")

# # Count frequency of each animal type and intake condition 
# animal_counts <- longbeach_transformed %>% count(animal_type, sort = TRUE)
# cat("Animal type distribution:", "\n")
# print(animal_counts)

# intake_counts <- longbeach_transformed %>% count(intake_condition, sort = TRUE)
# cat("Intake condition distribution:", "\n")
# print(intake_counts)

# # count frequency of each intake type
# intake_type_counts <- longbeach_transformed %>% count(intake_type, sort = TRUE)
# cat("Intake type distribution:", "\n")
# print(intake_type_counts)

# Group rare animal types (less than 200 instances)
rare_animal_types <- c("reptile", "guinea pig", "livestock", "amphibian")
longbeach_transformed <- longbeach_transformed %>%
  mutate(animal_type = ifelse(animal_type %in% rare_animal_types, "Other", animal_type))
cat("Group rare animal type\n")

# Group rare intake conditions (less than 200 instances)
rare_intake_conditions <- c("aged", "behavior moderate", "behavior mild", 
                           "behavior severe", "welfare seizures", "intakeexam")
longbeach_transformed <- longbeach_transformed %>%
  mutate(intake_condition = ifelse(intake_condition %in% rare_intake_conditions, "Other", intake_condition))
cat("Group rare intake conditions\n")

# Group rare intake types (with fewer than 200 instances)
rare_intake_types <- c("foster", "adopted animal return", "euthanasia required", "trap, neuter, return", "safe keep", "quarantine")
longbeach_transformed <- longbeach_transformed %>%
  mutate(intake_type = ifelse(intake_type %in% rare_intake_types, "Other", intake_type))
cat("Group rare intake types\n")

# Convert categorical variables to factors
longbeach_transformed$animal_type <- as.factor(longbeach_transformed$animal_type)
longbeach_transformed$sex <- as.factor(longbeach_transformed$sex)
longbeach_transformed$intake_condition <- as.factor(longbeach_transformed$intake_condition)
longbeach_transformed$intake_type <- as.factor(longbeach_transformed$intake_type)
longbeach_transformed$season <- as.factor(longbeach_transformed$season)
longbeach_transformed$adopted <- as.factor(longbeach_transformed$adopted)


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

# # save summary tables if `table_dir` is provided
# if (!is.null(opt$table_dir)) {
#   # Create table directory if it doesn't exist
#   dir.create(opt$table_dir, recursive = TRUE, showWarnings = FALSE)
  
#   # Save animal type and intake condition tables, and intake type counts
#   write_csv(animal_counts, file.path(opt$table_dir, "animal_type_counts.csv"))
#   write_csv(intake_counts, file.path(opt$table_dir, "intake_condition_counts.csv"))
#   write_csv(intake_type_counts, file.path(opt$table_dir, "intake_type_counts.csv"))
  
#   # Save adoption outcomes distribution
#   adopted_summary <- as.data.frame(table(longbeach_cleaned$adopted))
#   names(adopted_summary) <- c("adopted", "count")
#   write_csv(adopted_summary, file.path(opt$table_dir, "adopted_distribution.csv"))
  
#   cat("Adoption_Distribution & Counts saved to:", opt$table_dir, "\n")
# }

# run the script in terminal (the root directory)
# Rscript scripts/02_clean_transform_data.R --input="data/raw/longbeach.csv" --output_clean="data/processed/longbeach_cleaned.csv" --output_transform="data/processed/longbeach_transformed.csv" --table_dir="results/tables"
# Rscript scripts/02_clean_transform_data.R --input="data/raw/longbeach.csv"     --output_clean="data/processed/longbeach_cleaned.csv"     --output_transform="data/processed/longbeach_transformed.csv"