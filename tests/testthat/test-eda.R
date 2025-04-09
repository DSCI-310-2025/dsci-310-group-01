# test-eda.R
# ----------
# Unit tests for EDA (exploratory data analysis) functions in `eda.R`.
#
# Functions tested:
# - `save_count_table()`: saves frequency table to CSV
# - `plot_adoption_distribution()`: creates a ggplot bar chart of adoption labels
# - `plot_grouped_adoption()`: generates and saves bar plot grouped by variable
# - `plot_age_distribution()`: creates and saves age histogram
#
# This test that file includes:
# - Output format checks (ggplot object, file existence)
# - Validation of saved table structure
# - Basic functionality tests on small test data



library(testthat)
library(tidyverse)
library(ggplot2)

source("../../R/eda.R")

# Dummy data
test_data <- tibble(
  adopted = c("Yes", "No", "Yes"),
  animal_type = c("dog", "cat", "dog"),
  age = c(2, 5, 7)
)

test_that("save_count_table works correctly", {
  temp_file <- tempfile(fileext = ".csv")
  save_count_table(test_data, "adopted", temp_file)
  result <- read_csv(temp_file)
  expect_equal(names(result), c("adopted", "n"))
  expect_equal(nrow(result), 2)
})

test_that("plot_adoption_distribution returns ggplot object", {
  p <- plot_adoption_distribution(test_data)
  expect_s3_class(p, "ggplot")
})

test_that("plot_grouped_adoption saves file", {
  temp_file <- tempfile(fileext = ".png")
  plot_grouped_adoption(test_data, "animal_type", "Title", "Animal Type", temp_file)
  expect_true(file.exists(temp_file))
})

test_that("plot_age_distribution saves file", {
  temp_file <- tempfile(fileext = ".png")
  plot_age_distribution(test_data, temp_file)
  expect_true(file.exists(temp_file))
})

