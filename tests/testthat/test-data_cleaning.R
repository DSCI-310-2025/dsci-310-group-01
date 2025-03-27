# test-data_cleaning.R
library(testthat)
library(tidyverse)

# Source the functions file (ensure the file is in the same directory or adjust accordingly)
source("../../R/data_cleaning.R")


# Create a sample dataset for testing purposes
sample_data <- tibble(
  outcome_type = c("adoption", "foster to adopt", NA, "adoption"),
  dob = c("2010-01-01", "2015-05-05", "2012-03-03", "2025-01-01"),  # Row 4: future date
  outcome_date = c("2020-06-15", "2020-07-20", "2020-08-01", "2020-06-15"),
  animal_id = c("A1", "A2", "A3", "A4"),
  animal_name = c("Max", "Bella", "Charlie", "Lucy"),
  secondary_color = c("Brown", "Black", "White", "Gray"),
  jurisdiction = c("LA", "LA", "LA", "LA"),
  latitude = c(33.0, 33.1, 33.2, 33.3),
  longitude = c(-118.0, -118.1, -118.2, -118.3),
  was_outcome_alive = c(TRUE, TRUE, TRUE, TRUE),
  outcome_subtype = c("sub1", "sub2", "sub3", "sub4"),
  reason_for_intake = c("Stray", "Owner Surrender", "Stray", "Stray"),
  crossing = c("No", "No", "No", "No"),
  animal_type = c("dog", "reptile", "cat", "dog"),
  sex = c("Male", "Female", "Male", "Female"),
  intake_condition = c("normal", "aged", "normal", "normal"),
  intake_type = c("stray", "foster", "stray", "stray")
)

test_that("clean_data function works correctly", {
  cleaned <- clean_data(sample_data)
  
  # Expect rows with missing outcome_type and future dob to be removed.
  # Row 3 (NA outcome_type) and Row 4 (future dob) should be dropped.
  expect_equal(nrow(cleaned), 2)
  
  # Check the 'adopted' column is correctly created
  expect_equal(cleaned$adopted, c("Yes", "Yes"))
  
  # Check that the age column exists and is an integer vector.
  expect_true("age" %in% names(cleaned))
  expect_true(is.integer(cleaned$age))
  
  # Check that season is computed correctly.
  # For outcome_date "2020-06-15" and "2020-07-20", season should be "Summer".
  expect_equal(cleaned$season, c("Summer", "Summer"))
})

test_that("transform_data function works correctly", {
  cleaned <- clean_data(sample_data)
  transformed <- transform_data(cleaned)
  
  # After filtering by age <= 30, there should be at least one row.
  expect_true(nrow(transformed) > 0)
  
  # Check that rare animal types are grouped correctly:
  # The animal_type "reptile" should become "Other".
  expect_equal(as.character(transformed$animal_type[transformed$animal_type != "dog"]), "Other")
  
  # Check that rare intake conditions are grouped correctly:
  # The intake_condition "aged" should be converted to "Other".
  expect_equal(as.character(transformed$intake_condition[transformed$intake_condition != "normal"]), "Other")
  
  # Check that rare intake types are grouped correctly:
  # The intake_type "foster" should be converted to "Other".
  expect_equal(as.character(transformed$intake_type[transformed$intake_type != "stray"]), "Other")
  
  # Check that the final dataset contains only the necessary columns.
  expected_columns <- c("animal_type", "age", "sex", "intake_condition", "intake_type", "season", "adopted")
  expect_equal(sort(names(transformed)), sort(expected_columns))
  
  # Ensure there are no missing values.
  expect_equal(sum(is.na(transformed)), 0)
})
