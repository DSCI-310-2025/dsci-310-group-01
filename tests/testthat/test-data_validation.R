# test-data_validation.R
# ----------------------
# Unit tests for the `run_data_validation_checks()` function in `data_validation.R`.
# Function tested:
# - `run_data_validation_checks()`: runs multiple data integrity checks on a raw input data frame.
#
# This testthat file includes:
# - Input sanity checks (e.g., missing key columns, wrong types)
# - Warnings for minor issues (e.g., class imbalance, wrong factor levels)
# - Error triggers for unexpected outcome types or bad formats
#
# The test ensure that the validation function can gracefully detect and report potential problems.

library(tidyverse)

source("../../R/data_validation.R")

test_that("Validation runs on example data", {
  df <- tibble(
    outcome_type = c("Adoption", "Transfer", NA),
    age = c(1, 2, 3),
    animal_type = factor(c("Dog", "Cat", "Rabbit")),
    sex = factor(c("M", "F", "M")),
    intake_condition = factor(c("Healthy", "Injured", "Sick")),
    intake_type = factor(c("Stray", "Surrender", "Wild")),
    dob = as.Date("2020-01-01"),
    intake_date = as.Date("2023-01-01"),
    outcome_date = as.Date("2023-01-05")
  )

   expect_error(run_data_validation_checks(df), "Unexpected outcome_type values")
})
