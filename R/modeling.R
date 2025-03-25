#' Train a Random Forest model
#'
#' @param d A data frame, typically downsampled, containing the training data
#' @return A trained randomForest model object
#' @export
train_rf_model <- function(d) {
  set.seed(123)
  model <- randomForest(
    adopted ~ animal_type + age + sex + intake_condition + intake_type + season,
    data = d,
    ntree = 100,
    mtry = 2,
    importance = TRUE
  )
  return(model)
}

#' Evaluate a classification model
#'
#' @param model Trained model object
#' @param test_d A data frame containing the test data
#' @return A list containing the confusion matrix, accuracy, sensitivity, and specificity
#' @export
evaluate_model <- function(model, test_d) {
  predictions <- predict(model, test_d)
  predictions <- factor(predictions, levels = c("Yes", "No"))
  test_d$adopted <- factor(test_d$adopted, levels = c("Yes", "No"))

  cm <- caret::confusionMatrix(predictions, test_d$adopted)
  metrics <- list(
    confusion_matrix = cm,
    accuracy = cm$overall["Accuracy"],
    sensitivity = cm$byClass["Sensitivity"],
    specificity = cm$byClass["Specificity"]
  )
  return(metrics)
}

#' Plot and save confusion matrix heatmap
#'
#' @param cm A caret confusionmatrix object
#' @param path_saved File path to save the plot
#' @export
plot_confusion_matrix <- function(cm, path_saved) {
  df <- as.data.frame(as.table(cm$table))
  colnames(df) <- c("Actual", "Predicted", "Count")
  
  p <- ggplot(df, aes(Actual, Predicted, fill = Count)) +
    geom_tile() +
    geom_text(aes(label = Count), color = "white", size = 8, fontface = "bold") +
    scale_fill_gradient(low = "#f1f1f1", high = "#1f77b4") +
    theme_minimal() +
    labs(title = "Confusion Matrix Heatmap of the Model", x = "Actual", y = "Predicted") +
    theme(axis.text = element_text(size = 15), axis.title = element_text(size = 14, face = "bold"))

  ggsave(filename = path_saved, plot = p)
}

#' Plot and save feature importance plot
#'
#' @param model Trained random forest model
#' @param path_saved File path to save the plot
#' @export
plot_feature_importance <- function(model, path_saved) {
  importance_df <- data.frame(Feature = rownames(importance(model)), Importance = importance(model)[, 1])
  
  p <- ggplot(importance_df, aes(x = reorder(Feature, Importance), y = Importance)) +
    geom_bar(stat = "identity", fill = "steelblue") +
    coord_flip() +
    labs(title = "Feature Importance", x = "Feature", y = "Importance") +
    theme_minimal() +
    theme(
      axis.text = element_text(size = 14),
      axis.title = element_text(size = 16, face = "bold"),
      plot.title = element_text(size = 18, face = "bold")
    )

  ggsave(filename = path_saved, plot = p)
}
