library(tidyverse)
library(caret)
library(randomForest)  # Load Random Forest for modeling
library(pROC)
library(docopt)
library(animalAdoptR)

# source("R/data_loading.R")  # Load the functions
# source("R/modeling.R")

"
This script trains a Random Forest model to predict animal adoption.
It performs downsampling to balance classes, fits a model, evaluates performance, and saves the results.

Usage:
  04_modeling.R --input=<input> --output_model=<output_model> --tables_dir=<tables_dir> --figures_dir=<figures_dir>

Options:
  --input=<input>             Path to the transformed dataset (CSV file).
  --output_model=<output_model> Path to save the trained model.
  --tables_dir=<tables_dir>   Directory to save table outputs (metrics and confusion matrix summary).
  --figures_dir=<figures_dir> Directory to save figures (confusion matrix and importance feature).
" -> doc

opt <- docopt(doc)

# Load the dataset
data <- load_data(opt$input)
data$adopted <- factor(data$adopted, levels = c("Yes", "No"))  # Ensure adopted is a factor, "Yes" = positive class

# Ensure output directories exist
ensure_dir_exists(dirname(opt$output_model))
ensure_dir_exists(opt$figures_dir)
ensure_dir_exists(opt$figures_dir)

# Split into training and testing sets
set.seed(123)
train_index <- createDataPartition(data$adopted, p = 0.8, list = FALSE)
train_data <- data[train_index, ]
test_data <- data[-train_index, ]


# Check for data leakage (duplicate IDs across train/test) (FOR DATA VALIDATION)
if ("animal_id" %in% names(train_data) && "animal_id" %in% names(test_data)) {
  overlap <- intersect(train_data$animal_id, test_data$animal_id)
  if (length(overlap) > 0) {
    stop("⚠️ Data leakage detected: Overlapping IDs between train and test sets:\n", paste(overlap, collapse = ", "))
  }
}



# test_data$adopted <- factor(test_data$adopted, levels = levels(train_data$adopted))
test_data$adopted <- factor(test_data$adopted, levels = c("Yes", "No")) # Explicitly reorder factor levels

# Downsample training data to balance classes
set.seed(123) # For reproducibility
train_data_downsampled <- downSample(x = train_data[, -which(names(train_data) == "adopted")], 
                                     y = train_data$adopted)
colnames(train_data_downsampled)[ncol(train_data_downsampled)] <- "adopted"  # Rename target column

# Train model using function
formula <- adopted ~ animal_type + age + sex + intake_condition + intake_type + season
rf_model <- train_rf_model(train_data_downsampled, formula = formula, seed = 123)
print(rf_model)

# Save model 
saveRDS(rf_model, opt$output_model)

# Evaluate model
results <- evaluate_rf_model(rf_model, test_data)

# Confusion Matrix Visualization
print(results$confusion_matrix)


# Save confusion matrix summary
cm_summary_path <- file.path(opt$tables_dir, "confusion_matrix_summary.csv")
write_csv(results$cm_summary, cm_summary_path)
cat("Confusion matrix summary saved to:", cm_summary_path, "\n")

# Save performance metrics
metrics_path <- file.path(opt$tables_dir, "metrics.csv")
write_csv(results$metrics, metrics_path)
cat("Saving model performance metrics to:", metrics_path, "\n")

# Plot and save confusion matrix
plot_confusion_matrix(
  cm = results$confusion_matrix,
  path_saved = file.path(opt$figures_dir, "confusion_matrix.png")
)
# graphics.off() # Close all open graphics devices

# Plot and save feature importance
plot_feature_importance(
  model = rf_model,
  path_saved = file.path(opt$figures_dir, "feature_importance.png")
)
# graphics.off() # Close all open graphics devices


cat("Model training and evaluation complete. Results saved.\n")

### Output files will be saved in:
# - Trained model: models/longbeach_model.rds
# - Tables: results/tables/metrics.csv and results/tables/confusion_matrix_summary.csv
# - Plots: results/figures/feature_importance.png and results/figures/confusion_matrix.png

