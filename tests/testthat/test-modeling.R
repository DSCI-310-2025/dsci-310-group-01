# tests/testthat/test-modeling.R

# Set working directory to project root if needed
if (!file.exists("data/processed/longbeach_transformed.csv")) {
  setwd("../../")
}

library(testthat)
library(caret)
library(randomForest)
library(tidyverse)

source("R/modeling.R")
source("R/data_loading.R")

test_that("train_rf_model trains a random forest model with formula parameter", {
  data <- load_data("data/processed/longbeach_transformed.csv", verbose = FALSE)
  data$adopted <- factor(data$adopted, levels = c("Yes", "No"))

  set.seed(123)
  data_down <- downSample(x = data[, -which(names(data) == "adopted")],
                          y = data$adopted)
  colnames(data_down)[ncol(data_down)] <- "adopted"

  # Test with explicit formula
  formula <- adopted ~ animal_type + age + sex + intake_condition + intake_type + season
  model <- train_rf_model(data_down, formula)
  expect_s3_class(model, "randomForest")
  
  # Test error when column is missing
  bad_formula <- adopted ~ animal_type + age + nonexistent_column
  expect_error(train_rf_model(data_down, bad_formula), "Missing required columns")
})

# Add this to your existing tests for train_rf_model
test_that("train_rf_model handles dot notation in formula", {
  data <- load_data("data/processed/longbeach_transformed.csv", verbose = FALSE)
  data$adopted <- factor(data$adopted, levels = c("Yes", "No"))

  set.seed(123)
  data_down <- downSample(x = data[, -which(names(data) == "adopted")],
                          y = data$adopted)
  colnames(data_down)[ncol(data_down)] <- "adopted"

  # Test with dot notation
  dot_formula <- adopted ~ .
  model <- train_rf_model(data_down, dot_formula)
  expect_s3_class(model, "randomForest")
  
  # Test with missing response variable
  no_response_data <- data_down[, !names(data_down) %in% "adopted"]
  expect_error(train_rf_model(no_response_data, adopted ~ .), "Response variable 'adopted' not found in data")
})

test_that("evaluate_rf_model returns metrics and confusion matrix with custom target", {
  data <- load_data("data/processed/longbeach_transformed.csv", verbose = FALSE)
  data$adopted <- factor(data$adopted, levels = c("Yes", "No"))

  set.seed(123)
  i <- createDataPartition(data$adopted, p = 0.8, list = FALSE)
  train_data <- data[i, ]
  test_data <- data[-i, ]

  train_down <- downSample(x = train_data[, -which(names(train_data) == "adopted")],
                           y = train_data$adopted)
  colnames(train_down)[ncol(train_down)] <- "adopted"

  formula <- adopted ~ animal_type + age + sex + intake_condition + intake_type + season
  model <- train_rf_model(train_down, formula)
  
  # Test with default settings
  results <- evaluate_rf_model(model, test_data)
  expect_named(results, c("confusion_matrix", "metrics", "cm_summary"))
  expect_s3_class(results$confusion_matrix, "confusionMatrix")
  expect_equal(nrow(results$metrics), 3)
  expect_equal(nrow(results$cm_summary), 4)
  
  # Test with nonexistent target column
  expect_error(evaluate_rf_model(model, test_data, target_col = "nonexistent"), "not found in test data")
})

test_that("plot_confusion_matrix creates and optionally saves plot", {
  data <- load_data("data/processed/longbeach_transformed.csv", verbose = FALSE)
  data$adopted <- factor(data$adopted, levels = c("Yes", "No"))

  set.seed(123)
  i <- createDataPartition(data$adopted, p = 0.8, list = FALSE)
  train_data <- data[i, ]
  test_data <- data[-i, ]

  train_down <- downSample(x = train_data[, -which(names(train_data) == "adopted")],
                           y = train_data$adopted)
  colnames(train_down)[ncol(train_down)] <- "adopted"

  formula <- adopted ~ animal_type + age + sex + intake_condition + intake_type + season
  model <- train_rf_model(train_down, formula)
  cm <- evaluate_rf_model(model, test_data)$confusion_matrix

  # Test without saving
  p <- plot_confusion_matrix(cm)
  expect_s3_class(p, "ggplot")
  
  # Test with saving
  tmp_path <- tempfile(fileext = ".png")
  p_saved <- plot_confusion_matrix(cm, path_saved = tmp_path)
  expect_true(file.exists(tmp_path))
  expect_s3_class(p_saved, "ggplot")
  
  # Test with custom parameters
  p_custom <- plot_confusion_matrix(cm, color_low = "lightgreen", color_high = "darkgreen", 
                                   text_color = "black", title = "Custom Title")
  expect_s3_class(p_custom, "ggplot")
  
  # Clean up
  unlink(tmp_path)
  
  # Test error with wrong object type
  expect_error(plot_confusion_matrix("not_a_cm_object"), "must be a confusionMatrix object")
})

test_that("plot_feature_importance creates and optionally saves plot", {
  data <- load_data("data/processed/longbeach_transformed.csv", verbose = FALSE)
  data$adopted <- factor(data$adopted, levels = c("Yes", "No"))

  set.seed(123)
  data_down <- downSample(x = data[, -which(names(data) == "adopted")],
                          y = data$adopted)
  colnames(data_down)[ncol(data_down)] <- "adopted"

  formula <- adopted ~ animal_type + age + sex + intake_condition + intake_type + season
  model <- train_rf_model(data_down, formula)

  # Test without saving
  p <- plot_feature_importance(model)
  expect_s3_class(p, "ggplot")
  
  # Test with saving
  tmp_path <- tempfile(fileext = ".png")
  p_saved <- plot_feature_importance(model, path_saved = tmp_path)
  expect_true(file.exists(tmp_path))
  expect_s3_class(p_saved, "ggplot")
  
  # Test with importance_type = 2 (if available)
  if(ncol(importance(model)) >= 2) {
    p_gini <- plot_feature_importance(model, importance_type = 2)
    expect_s3_class(p_gini, "ggplot")
  }
  
  # Test with custom parameters
  p_custom <- plot_feature_importance(model, fill_color = "orange", title = "Custom Importance Plot")
  expect_s3_class(p_custom, "ggplot")
  
  # Clean up
  unlink(tmp_path)
  
  # Test error with wrong object type
  expect_error(plot_feature_importance("not_a_rf_model"), "must be a randomForest object")
  
  # Test error with invalid importance_type
  expect_error(plot_feature_importance(model, importance_type = 3), "must be either 1")
})

# run test in terminal: 
# Rscript -e "testthat::test_file('tests/testthat/test-modeling.R')"