library(tidyverse)
library(pROC)  # Ensure this package is loaded for ROC curve plotting
library(caret)
library(docopt)

"
This script trains a classification model to predict animal adoption.
It loads the transformed dataset, fits a model, evaluates performance, and saves the results.

Usage:
  04_modeling.R --input=<input> --output_model=<output_model> --metrics=<metrics> --figures_dir=<figures_dir>

Options:
  --input=<input>             Path to the transformed dataset (CSV file).
  --output_model=<output_model> Path to save the trained model.
  --metrics=<metrics>         Path to save model performance metrics.
  --figures_dir=<figures_dir> Directory to save figures.
" -> doc

opt <- docopt(doc)

# Load the dataset
cat("Loading transformed dataset from:", opt$input, "\n")
data <- read_csv(opt$input)
data$adopted <- factor(data$adopted, levels = c("Yes", "No"))  # Ensure adopted is a factor with correct levels

# Ensure output directories exist
dir.create(dirname(opt$output_model), recursive = TRUE, showWarnings = FALSE)
dir.create(dirname(opt$metrics), recursive = TRUE, showWarnings = FALSE)
dir.create(opt$figures_dir, recursive = TRUE, showWarnings = FALSE)

# Split into training and testing sets
set.seed(123)
train_index <- createDataPartition(data$adopted, p = 0.8, list = FALSE)
train_data <- data[train_index, ]
test_data <- data[-train_index, ]
test_data$adopted <- factor(test_data$adopted, levels = levels(train_data$adopted))  # Ensure test set has the same factor levels

# Train a logistic regression model
model <- train(adopted ~ ., data = train_data, method = "glm", family = "binomial")

# Predictions
pred_probs <- predict(model, test_data, type = "prob")[, "Yes"]  # Get probabilities for "Yes"
predictions <- predict(model, test_data)  # Get class predictions
predictions <- factor(predictions, levels = levels(test_data$adopted))  # Ensure predictions are factors with the correct levels
conf_matrix <- confusionMatrix(predictions, test_data$adopted)

# Save model
saveRDS(model, opt$output_model)

# Save performance metrics
metrics <- data.frame(Accuracy = conf_matrix$overall["Accuracy"],
                      Sensitivity = conf_matrix$byClass["Sensitivity"],
                      Specificity = conf_matrix$byClass["Specificity"])
write_csv(metrics, opt$metrics)

# Plot ROC Curve
roc_curve <- roc(test_data$adopted, pred_probs)  # Use probabilities, not class labels
ggplot(data.frame(TPR = roc_curve$sensitivities, FPR = 1 - roc_curve$specificities), aes(x = FPR, y = TPR)) +
  geom_line() +
  labs(title = "ROC Curve", x = "False Positive Rate", y = "True Positive Rate") +
  theme_minimal()
ggsave(filename = file.path(opt$figures_dir, "roc_curve.png"))

cat("Model training and evaluation complete. Results saved.\n")

### Output files will be saved in:
# - Trained model: models/longbeach_model.rds
# - Model performance metrics: results/metrics.csv
# - ROC curve visualization: results/figures/roc_curve.png
