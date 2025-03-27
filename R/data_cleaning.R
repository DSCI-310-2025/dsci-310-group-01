# data_cleaning.R
# This file contains functions for cleaning and transforming the Long Beach dataset.

library(tidyverse)

#' Part 1: Clean Raw Data
#'
#' This function cleans the raw dataset by performing filtering,
#' removing unnecessary columns, and creating new features.
#'
#' @param data A data frame containing the raw data.
#'
#' @return A cleaned data frame with the following modifications:
#'   - Removes rows with missing outcome_type or dob.
#'   - Filters out rows where dob is after "2024-12-31".
#'   - Drops unnecessary columns.
#'   - Creates a new column 'adopted' based on outcome_type.
#'   - Calculates the age from dob.
#'   - Extracts month and season from outcome_date.
#'
#' @examples
#' cleaned_data <- clean_data(raw_data)
clean_data <- function(data) {
  cleaned <- data %>%
    filter(!is.na(outcome_type)) %>%  
    filter(!is.na(dob)) %>%           
    filter(as.Date(dob) <= as.Date("2024-12-31")) %>%  
    select(-animal_id, -animal_name, -secondary_color, -jurisdiction, -latitude,
           -longitude, -was_outcome_alive, -outcome_subtype, -reason_for_intake, -crossing)
  cat("After initial cleaning:", nrow(cleaned), "rows\n")
  
  # Print outcome summary
  outcome_summary <- cleaned %>% count(outcome_type, sort = TRUE)
  cat("Outcome Summary:\n")
  print(outcome_summary)
  
  # Create target variable 'adopted'
  cleaned <- cleaned %>%
    mutate(adopted = ifelse(outcome_type %in% c("adoption", "foster to adopt"), "Yes", "No"))
  
  cat("Target variable 'adopted' distribution:\n")
  print(table(cleaned$adopted))
  
  # Calculate age in integer years from dob
  cleaned$age <- as.numeric(difftime(Sys.Date(),
                                       as.Date(cleaned$dob, format = "%Y-%m-%d"),
                                       units = "days")) / 365
  cleaned$age <- as.integer(cleaned$age)
  
  # Extract month from outcome_date
  cleaned <- cleaned %>%
    mutate(month = format(as.Date(outcome_date, format = "%Y-%m-%d"), "%m"))
  
  # Create season feature based on month
  cleaned <- cleaned %>%
    mutate(season = case_when(
      month %in% c("12", "01", "02") ~ "Winter",
      month %in% c("03", "04", "05") ~ "Spring",
      month %in% c("06", "07", "08") ~ "Summer",
      month %in% c("09", "10", "11") ~ "Fall",
      TRUE ~ "Unknown"
    ))
  
  return(cleaned)
}




#' Part 2: Transform Cleaned Data
#'
#' This function will perform additional data transformations and feature engineering,
#' including filtering by age, grouping rare categories, converting columns to factors,
#' and selecting the final set of features for modeling.
#'
#' @param data A cleaned data frame (output from the clean_data function).
#'
#' @return A transformed data frame ready for exploratory data analysis and modeling.
#'
#' @examples
#' transformed_data <- transform_data(cleaned_data)
transform_data <- function(data) {
  transformed <- data %>%
    filter(age <= 30)
  
  cat("After removing ages > 30:", nrow(transformed), "rows\n")
  
  # Group rare animal types
  rare_animal_types <- c("reptile", "guinea pig", "livestock", "amphibian")
  transformed <- transformed %>%
    mutate(animal_type = ifelse(animal_type %in% rare_animal_types, "Other", animal_type))
  cat("Group rare animal type\n")
  
  # Group rare intake conditions
  rare_intake_conditions <- c("aged", "behavior moderate", "behavior mild",
                              "behavior severe", "welfare seizures", "intakeexam")
  transformed <- transformed %>%
    mutate(intake_condition = ifelse(intake_condition %in% rare_intake_conditions, "Other", intake_condition))
  cat("Group rare intake conditions\n")
  
  # Group rare intake types
  rare_intake_types <- c("foster", "adopted animal return", "euthanasia required",
                         "trap, neuter, return", "safe keep", "quarantine")
  transformed <- transformed %>%
    mutate(intake_type = ifelse(intake_type %in% rare_intake_types, "Other", intake_type))
  cat("Group rare intake types\n")
  
  # Convert specified columns to factors
  transformed$animal_type <- as.factor(transformed$animal_type)
  transformed$sex <- as.factor(transformed$sex)
  transformed$intake_condition <- as.factor(transformed$intake_condition)
  transformed$intake_type <- as.factor(transformed$intake_type)
  transformed$season <- as.factor(transformed$season)
  transformed$adopted <- as.factor(transformed$adopted)
  
  # Keep only necessary columns for modeling
  transformed <- transformed %>%
    select(animal_type, age, sex, intake_condition, intake_type, season, adopted)
  
  # Check for missing values
  missing_values <- colSums(is.na(transformed))
  cat("Missing values in transformed dataset:\n")
  print(missing_values)
  
  return(transformed)
}
