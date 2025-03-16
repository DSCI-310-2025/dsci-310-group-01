library(tidyverse)
library(caret)
library(randomForest)  # Load Random Forest for modeling
library(pROC)
library(docopt)

"
This script trains a Random Forest model to predict animal adoption.
It performs downsampling to balance classes, fits a model, evaluates performance, and saves the results.

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
data$adopted <- factor(data$adopted, levels = c("Yes", "No"))  # Ensure adopted is a factor

# Ensure output directories exist
dir.create(dirname(opt$output_model), recursive = TRUE, showWarnings = FALSE)
dir.create(dirname(opt$metrics), recursive = TRUE, showWarnings = FALSE)
dir.create(opt$figures_dir, recursive = TRUE, showWarnings = FALSE)

# Split into training and testing sets
set.seed(123)
train_index <- createDataPartition(data$adopted, p = 0.8, list = FALSE)
train_data <- data[train_index, ]
test_data <- data[-train_index, ]

test_data$adopted <- factor(test_data$adopted, levels = levels(train_data$adopted))

# Downsample training data to balance classes
train_data_downsampled <- downSample(x = train_data[, -which(names(train_data) == "adopted")], 
                                     y = train_data$adopted)
colnames(train_data_downsampled)[ncol(train_data_downsampled)] <- "adopted"  # Rename target column

# Train Random Forest model
rf_model <- randomForest(adopted ~ animal_type + age + sex + intake_condition + intake_type + season, 
                         data = train_data_downsampled, 
                         ntree = 100, 
                         mtry = 2, 
                         importance = TRUE)

print(rf_model)

# Predictions
predictions <- predict(rf_model, test_data)
predictions <- factor(predictions, levels = levels(test_data$adopted))
conf_matrix <- confusionMatrix(predictions, test_data$adopted)
print(conf_matrix)

# Confusion Matrix Visualization
conf_matrix_df <- as.data.frame(as.table(conf_matrix$table))
colnames(conf_matrix_df) <- c("Actual", "Predicted", "Count")

conf_matrix_plot <- ggplot(conf_matrix_df, aes(Actual, Predicted, fill = Count)) +
  geom_tile() +
  geom_text(aes(label = Count), color = "white", size = 8, fontface = "bold") +
  scale_fill_gradient(low = "#f1f1f1", high = "#1f77b4") +  # Light gray to blue
  theme_minimal() +
  labs(title = "Confusion Matrix Heatmap", x = "Actual Values", y = "Predicted Values") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
        axis.text.y = element_text(size = 12),
        axis.title = element_text(size = 14, face = "bold"),
        plot.title = element_text(size = 16, face = "bold"))

ggsave(filename = file.path(opt$figures_dir, "confusion_matrix.png"), plot = conf_matrix_plot)

# Save model
saveRDS(rf_model, opt$output_model)

# Save performance metrics
metrics <- data.frame(Accuracy = conf_matrix$overall["Accuracy"],
                      Sensitivity = conf_matrix$byClass["Sensitivity"],
                      Specificity = conf_matrix$byClass["Specificity"])
write_csv(metrics, opt$metrics)

# Feature Importance Plot
importance_df <- data.frame(Feature = rownames(importance(rf_model)), Importance = importance(rf_model)[, 1])

importance_plot <- ggplot(importance_df, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Feature Importance (Random Forest)", x = "Feature", y = "Importance") +
  theme_minimal()

ggsave(filename = file.path(opt$figures_dir, "feature_importance.png"), plot = importance_plot)

cat("Model training and evaluation complete. Results saved.\n")

### Output files will be saved in:
# - Trained model: models/longbeach_model.rds
# - Model performance metrics: results/metrics.csv
# - Plots: results/figures/feature_importance.png and results/figures/confusion_matrix.png

