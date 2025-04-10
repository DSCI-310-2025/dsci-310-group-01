# test-data_prep.R
# ----------------
# Unit tests for preprocessing functions in `data_prep.R`.
#
# Functions tested:
# - `calculate_age_years()`: converts DOB to age in years, handles NA and empty inputs
# - `assign_season()`: maps month values to seasonal categories, supports numeric and string input
# - `group_rare_categories()`: replaces rare values in a categorical column with a default label
# - `convert_to_factors()`: coerces specified columns to factor type
#
# This testthat file includes:
# - Normal usage tests
# - Edge cases (e.g., empty vectors, invalid column names)
# - Error handling tests


library(testthat)
library(tidyverse)

source("../../R/data_prep.R")  # Load the functions

# Test for calculate_age_years function
test_that("calculate_age_years works correctly", {
  # Test with a single date
  ref_date <- as.Date("2023-01-01")
  expect_equal(calculate_age_years("2020-01-01", ref_date), 3)
  
  # Test with vector of dates
  dates <- c("2013-01-01", "2018-01-01", "2021-01-01")
  expected <- c(10, 5, 2)
  expect_equal(calculate_age_years(dates, ref_date), expected)
  
  # Test with NA values
  dates_with_na <- c("2013-01-01", NA, "2021-01-01")
  expected_with_na <- c(10, NA_integer_, 2)
  expect_equal(calculate_age_years(dates_with_na, ref_date), expected_with_na)
  
  # Test with single character NA
  expect_equal(calculate_age_years(NA_character_, ref_date), NA_integer_)
  # Test with Date NA
  expect_equal(calculate_age_years(as.Date(NA), ref_date), NA_integer_)

  # Test with empty vector
  expect_equal(length(calculate_age_years(character(0), ref_date)), 0)
})

# Test for assign_season function
test_that("assign_season correctly maps months to seasons", {
  # Test mixed months
  expect_equal(
    assign_season(c("01", "04", "07", "10")), 
    c("Winter", "Spring", "Summer", "Fall")
  )
  
  # Test single-digit months
  expect_equal(assign_season(c("1", "2", "3")), c("Winter", "Winter", "Spring"))
  
  # Test numeric months
  expect_equal(assign_season(c(1, 4, 7, 10)), c("Winter", "Spring", "Summer", "Fall"))
  
  # Test invalid months
  expect_equal(assign_season(c("13", "00", NA)), c("Unknown", "Unknown", "Unknown"))
  
  # Test empty vector
  expect_equal(assign_season(character(0)), character(0))
})

# Test for group_rare_categories function
test_that("group_rare_categories correctly groups categories", {
  # Create test data
  test_data <- tibble(
    animal_type = c("dog", "cat", "reptile", "bird", "guinea pig"),
    count = c(10, 8, 3, 5, 2)
  )
  
  # Test grouping specific categories
  result <- group_rare_categories(test_data, "animal_type", c("reptile", "guinea pig"))
  expected <- c("dog", "cat", "Other", "bird", "Other")
  expect_equal(result$animal_type, expected)
  
  # Test with custom "other" name
  result <- group_rare_categories(test_data, "animal_type", c("reptile", "guinea pig"), "Rare")
  expected <- c("dog", "cat", "Rare", "bird", "Rare")
  expect_equal(result$animal_type, expected)
  
  # Test with no matching categories
  result <- group_rare_categories(test_data, "animal_type", c("fish", "hamster"))
  expect_equal(result$animal_type, test_data$animal_type)
  
  # Test with non-existent column
  expect_error(group_rare_categories(test_data, "species", c("reptile")))
})

# Test for convert_to_factors function
test_that("convert_to_factors correctly converts columns to factors", {
  # Create test data
  test_data <- tibble(
    animal_type = c("dog", "cat", "bird"),
    count = c(10, 8, 5),
    sex = c("M", "F", "M"),
    age = c(3, 5, 2)
  )
  
  # Test converting a single column
  result <- convert_to_factors(test_data, "animal_type")
  expect_s3_class(result$animal_type, "factor")
  expect_false(is.factor(result$count))
  
  # Test converting multiple columns
  result <- convert_to_factors(test_data, c("animal_type", "sex"))
  expect_s3_class(result$animal_type, "factor")
  expect_s3_class(result$sex, "factor")
  expect_false(is.factor(result$count))
  expect_false(is.factor(result$age))
  
  # Test with non-existent columns
  expect_error(convert_to_factors(test_data, c("animal_type", "color")))
  
  # Test with empty columns vector
  result <- convert_to_factors(test_data, character(0))
  expect_equal(result, test_data)
})
