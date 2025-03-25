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

test_that("Function train_rf_model trains a random forest model", {
  data <- load_data("data/processed/longbeach_transformed.csv", verbose = FALSE)
  data$adopted <- factor(data$adopted, levels = c("Yes", "No"))

  set.seed(123)
  data_down <- downSample(x = data[, -which(names(data) == "adopted")],
                          y = data$adopted)
  colnames(data_down)[ncol(data_down)] <- "adopted"

  model <- train_rf_model(data_down)
  expect_s3_class(model, "randomForest")
})

test_that("evaluate_model returns metrics and confusion matrix", {
  data <- load_data("data/processed/longbeach_transformed.csv", verbose = FALSE)
  data$adopted <- factor(data$adopted, levels = c("Yes", "No"))

  set.seed(123)
  i <- createDataPartition(data$adopted, p = 0.8, list = FALSE)
  train_data <- data[i, ]
  test_data <- data[-i, ]

  train_down <- downSample(x = train_data[, -which(names(train_data) == "adopted")],
                           y = train_data$adopted)
  colnames(train_down)[ncol(train_down)] <- "adopted"

  model <- train_rf_model(train_down)
  results <- evaluate_model(model, test_data)
  expect_named(results, c("confusion_matrix", "accuracy", "sensitivity", "specificity"))
  expect_s3_class(results$confusion_matrix, "confusionMatrix")
  expect_type(results$accuracy, "double")
})

test_that("plot_confusion_matrix saves file", {
  data <- load_data("data/processed/longbeach_transformed.csv", verbose = FALSE)
  data$adopted <- factor(data$adopted, levels = c("Yes", "No"))

  set.seed(123)
  i <- createDataPartition(data$adopted, p = 0.8, list = FALSE)
  train_data <- data[i, ]
  test_data <- data[-i, ]

  train_down <- downSample(x = train_data[, -which(names(train_data) == "adopted")],
                           y = train_data$adopted)
  colnames(train_down)[ncol(train_down)] <- "adopted"

  model <- train_rf_model(train_down)
  cm <- evaluate_model(model, test_data)$confusion_matrix

  tmp_path <- tempfile(fileext = ".png")
  plot_confusion_matrix(cm, tmp_path)
  expect_true(file.exists(tmp_path))
  unlink(tmp_path)
})

test_that("plot_feature_importance saves file", {
  data <- load_data("data/processed/longbeach_transformed.csv", verbose = FALSE)
  data$adopted <- factor(data$adopted, levels = c("Yes", "No"))

  set.seed(123)
  data_down <- downSample(x = data[, -which(names(data) == "adopted")],
                          y = data$adopted)
  colnames(data_down)[ncol(data_down)] <- "adopted"

  model <- train_rf_model(data_down)

  tmp_path <- tempfile(fileext = ".png")
  plot_feature_importance(model, tmp_path)
  expect_true(file.exists(tmp_path))
  unlink(tmp_path)
})
