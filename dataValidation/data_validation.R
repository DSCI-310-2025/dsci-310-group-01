#' Run data validation checks
#'
#' This function performs a series of validation checks on the raw input data.
#' It checks for missing values, expected value ranges, factor types, class imbalance, etc.
#' Warnings will be shown for suspicious patterns, and execution may stop for critical issues.
#'
#' @param df A data frame containing the dataset to validate. Usually your cleaned or semi-cleaned dataset.
#'
#' @return Nothing. Prints warnings or errors if validation fails.
#'
#' @examples
#' # Load example data
#' data <- readr::read_csv("data/processed/longbeach_cleaned.csv")
#'
#' # Run validation
#' run_data_validation_checks(data)
#'
#' # Or after feature engineering
#' transformed <- readr::read_csv("data/processed/longbeach_transformed.csv")
#' run_data_validation_checks(transformed)
#'
#' @export
run_data_validation_checks <- function(df) {
  # Check dimensions
  if (ncol(df) < 10 || nrow(df) < 100) {
    warning("Data has unusually small dimensions: please verify source.")
  }
  # Check for missing in key columns
  if (any(is.na(df$outcome_type))) {
    warning("Missing values found in 'outcome_type': ", sum(is.na(df$outcome_type)))
  }
  # Check expected target values
  allowed <- c("Adoption", "Foster to Adopt", "Euthanasia", "Transfer", "Rescue", "Return to Owner")
  actual <- unique(df$outcome_type)
  unexpected <- setdiff(actual, allowed)
  if (length(unexpected) > 0) {
    warning(
      "Unexpected outcome_type values detected: ",
      paste(unexpected, collapse = ", "),
      "\nNote: This may be expected in raw data and will be handled during cleaning."
    ) 
  }

  # Check age class
  if (!"age" %in% colnames(df)) warning("No 'age' column found.")
  if (!is.numeric(df$age)) warning("'age' column is not numeric.")

  # Check factor columns
  cat_vars <- c("animal_type", "sex", "intake_condition", "intake_type")
  for (var in cat_vars) {
    if (!is.factor(df[[var]])) {
      warning(sprintf("'%s' should be a factor but is %s", var, class(df[[var]])[1]))
    }
  }
  # Check season variable (if exists)
  if ("season" %in% colnames(df)) {
    bad_vals <- setdiff(unique(df$season), c("Winter", "Spring", "Summer", "Fall", "Unknown"))
    if (length(bad_vals) > 0) {
      warning("Invalid season values detected: ", paste(bad_vals, collapse = ", "))
    }
  }
  # Check date columns
  date_cols <- c("dob", "intake_date", "outcome_date")
  for (col in date_cols) {
    if (!inherits(df[[col]], "Date")) {
      warning(sprintf("'%s' should be of class Date but is %s", col, class(df[[col]])[1]))
    }
  }

  # Class imbalance warning
  if ("adopted" %in% colnames(df)) {
    tab <- table(df$adopted)
    if ("Yes" %in% names(tab) && "No" %in% names(tab)) {
      ratio <- round(tab["No"] / tab["Yes"], 2)
      if (ratio > 2) {
        warning("Class imbalance: No:Yes ratio is ", ratio)
      }
    }
  }
  message("Data validation checks complete.")
}
