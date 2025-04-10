# test-data_loading.R
# --------------------
# Unit tests for functions in `data_loading.R`:
# - `ensure_dir_exists()`: checks whether the directory is created or skipped
# - `load_data()`: tests proper loading of a CSV file, including error handling
#
# This testthat file includes:
# - Normal use cases (file exists, valid directory)
# - Error handling (nonexistent files)
# - Temporary file and directory creation to isolate test environment

library(testthat)
source("../../R/data_loading.R")  # Load the functions

test_that("ensure_dir_exists creates directory when it doesn't exist", {
  # Create a temporary directory path like "/tmp/Rtmpabcdef/test_ensure_directory"
  temp_dir <- file.path(tempdir(), "test_ensure_directory")
  # Clean up any existing directory for a clean test
  if (dir.exists(temp_dir)) {
    unlink(temp_dir, recursive = TRUE)
  }
  # Test the function
  ensure_dir_exists(temp_dir)
  expect_true(dir.exists(temp_dir)) # Check that the directory was created
  unlink(temp_dir, recursive = TRUE) # Deletes (unlink) the directory and all its contents
})

test_that("ensure_dir_exists does nothing when directory already exists", {
  # Create a temporary directory path
  temp_dir <- file.path(tempdir(), "test_existing_directory")
  # Create the directory first
  dir.create(temp_dir, recursive = TRUE, showWarnings = FALSE)
  # Test the function on an existing directory (should not error)
  expect_no_error(ensure_dir_exists(temp_dir))
  expect_true(dir.exists(temp_dir)) # The directory should exist

  unlink(temp_dir, recursive = TRUE)
})



test_that("load_data correctly loads CSV files", {
  # Create a temporary CSV file: "/tmp/Rtmpabcdef/test_data/test.csv"
  temp_dir <- file.path(tempdir(), "test_data")
  dir.create(temp_dir, recursive = TRUE, showWarnings = FALSE)
  temp_file <- file.path(temp_dir, "test.csv")
  
  # Create a test dataset
  test_data <- data.frame(
    id = 1:3,
    value = c("a", "b", "c")
  )
  write.csv(test_data, temp_file, row.names = FALSE)
  
  # Test loading with verbose = FALSE to avoid output during tests
  dat <- load_data(temp_file, verbose = FALSE)
  # Check that the data was loaded correctly
  expect_equal(nrow(dat), 3)
  expect_equal(ncol(dat), 2)
  expect_equal(as.numeric(dat$id), 1:3)
  expect_equal(dat$value, c("a", "b", "c"))

  unlink(temp_dir, recursive = TRUE)
})

# Test with a non-existent file and expect an error
test_that("load_data errors when file doesn't exist", {
  expect_error(load_data("non_existent_file.csv"), "File does not exist")
})