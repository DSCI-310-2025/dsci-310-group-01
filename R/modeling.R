# Load utility functions
source("R/data_loading.R")

#' Train a Random Forest model
#'
#' Trains a Random Forest model using the provided formula and data. Handles both standard
#' and dot notation in formula. Checks for missing variables and ensures reproducibility via seed.
#'
#' @param d A data frame containing the training data
#' @param formula Model formula to use for training (required)
#' @param ntree Number of trees to grow. Default: 100
#' @param mtry Number of variables randomly sampled at each split. Default: 2
#' @param seed Random seed for reproducibility. Default: 123
#' @return A trained randomForest model object
#' @examples
#' model <- train_rf_model(df, adopted ~ age + sex)
#'
#' @export
train_rf_model <- function(d, 
                          formula,
                          ntree = 100,
                          mtry = 2,
                          seed = 123) {
                            

  if (!is.data.frame(d)) {
    stop("`d` must be a data frame.")
  }
  if (!inherits(formula, "formula")) {
    stop("`formula` must be a valid formula object (e.g., adopted ~ age + sex).")
  }
  if (!is.numeric(ntree) || length(ntree) != 1 || ntree <= 0) {
    stop("`ntree` must be a single positive number.")
  }
  if (!is.numeric(mtry) || length(mtry) != 1 || mtry <= 0) {
    stop("`mtry` must be a single positive number.")
  }

  # Check if response variable exists
  response_var <- all.vars(formula)[1]
  if (!(response_var %in% names(d))) {
    stop("Response variable '", response_var, "' not found in data")
  }

  # Check for dot notation in formula
  formula_str <- paste(deparse(formula), collapse = "")
  using_dot_notation <- grepl("\\.", formula_str)
  
  # If NOT using dot notation, check individual predictors
  if (!using_dot_notation) {
    predictor_vars <- all.vars(formula)[-1]
    missing_cols <- predictor_vars[!predictor_vars %in% names(d)]
    if (length(missing_cols) > 0) {
      stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
    }
  }
  
  # Set seed for reproducibility
  set.seed(seed)
  
  # Train model
  model <- randomForest(
    formula = formula,
    data = d,
    ntree = ntree,
    mtry = mtry,
    importance = TRUE
  )
  
  return(model)
}






#' Evaluate a classification model
#'
#' This function evaluates a trained model on test data, computing confusion
#' matrix, metrics, and summary statistics for binary classification.
#'
#' @param model Trained model object (e.g., randomForest)
#' @param test_d A data frame containing the test data
#' @param target_col The name of the target column. Default: "adopted"
#' @param positive_level The positive class level. Default: "Yes"
#' @param negative_level The negative class level. Default: "No"
#' @return A list containing: confusion_matrix (the caret confusionMatrix object),
#'   metrics (dataframe with performance metrics), and cm_summary (confusion matrix summary)
#' @export
#' @examples
#' # Defult usage
#' results <- evaluate_rf_model(rf_model, test_data)
#' # Access components
#' metrics_df <- results$metrics
#' conf_matrix <- results$confusion_matrix
evaluate_rf_model <- function(model, test_d, target_col = "adopted", 
                           positive_level = "Yes", negative_level = "No") {
  if (!inherits(model, "randomForest")) {
    stop("`model` must be a randomForest object.")
  }
  if (!is.data.frame(test_d)) {
    stop("`test_d` must be a data frame.")
  }
  if (!is.character(target_col) || length(target_col) != 1) {
    stop("`target_col` must be a single character string.")
  }
                          
  # Validate inputs
  if (!target_col %in% names(test_d)) {
    stop("Target column '", target_col, "' not found in test data")
  }
  
  predictions <- predict(model, test_d)  # Make predictions
  
  # set factor levels to ensure consistency
  predictions <- factor(predictions, levels = c(positive_level, negative_level))
  test_d[[target_col]] <- factor(test_d[[target_col]], levels = c(positive_level, negative_level))
  
  # Compute confusion matrix
  conf_matrix <- caret::confusionMatrix(predictions, test_d[[target_col]])
  
  # Extract values from confusion matrix
  cm_table <- conf_matrix$table
  true_positive <- cm_table[positive_level, positive_level]
  false_negative <- cm_table[positive_level, negative_level]
  false_positive <- cm_table[negative_level, positive_level]
  true_negative <- cm_table[negative_level, negative_level]

  # Create confusion matrix summary dataframe
  cm_summary <- data.frame(
    Metric = c("True Positives", "False Negatives", "False Positives", "True Negatives"),
    Count = c(true_positive, false_negative, false_positive, true_negative)
  )
  # Create metrics dataframe
  metrics <- data.frame(
    Metric = c("Accuracy", "Sensitivity", "Specificity"),
    Value = c(
      conf_matrix$overall["Accuracy"],
      conf_matrix$byClass["Sensitivity"],
      conf_matrix$byClass["Specificity"]
    )
  )
  # Return all components
  return(list(
    confusion_matrix = conf_matrix,
    metrics = metrics,
    cm_summary = cm_summary
  ))
}





#' Plot confusion matrix as a heatmap
#' Creates a heatmap visualization of a confusion matrix. Optionally saves the plot to a file.
#'
#' @param cm A caret confusionMatrix object
#' @param path_saved File path to save the plot. If NULL, plot is only returned but not saved.
#' @param color_low Color for low values in gradient. Default: "#f1f1f1" (light gray)
#' @param color_high Color for high values in gradient. Default: "#1f77b4" (blue)
#' @param text_color Color for the text labels. Default: "white"
#' @param text_size Size for the text labels. Default: 8
#' @param title Plot title. Default: "Confusion Matrix Heatmap"
#' @param width Plot width in inches when saving. Default: 8
#' @param height Plot height in inches when saving. Default: 7
#' @return Invisibly returns the ggplot object.
#'
#' @examples
#' plot_confusion_matrix(cm)
#' plot_confusion_matrix(cm, path_saved = "cm_plot.png")
#'
#' @export
plot_confusion_matrix <- function(cm, path_saved = NULL, 
                                 color_low = "#f1f1f1", 
                                 color_high = "#1f77b4",
                                 text_color = "white",
                                 text_size = 8,
                                 title = "Confusion Matrix Heatmap",
                                 width = NULL,
                                 height = NULL) {
  # Check validate input
  if (!inherits(cm, "confusionMatrix")) {
    stop("The 'cm' parameter must be a confusionMatrix object from the caret package")
  }
  
  # Create data frame from "cm" for plotting
  df <- as.data.frame(as.table(cm$table))
  colnames(df) <- c("Actual", "Predicted", "Count")
  
  # Create the plot
  p <- ggplot(df, aes(Actual, Predicted, fill = Count)) +
    geom_tile() +
    geom_text(aes(label = Count), color = text_color, 
              size = text_size, fontface = "bold") +
    scale_fill_gradient(low = color_low, high = color_high) +
    theme_minimal() +
    labs(title = title, x = "Actual", y = "Predicted") +
    theme(
      axis.text = element_text(size = 15), 
      axis.title = element_text(size = 14, face = "bold"),
      plot.title = element_text(size = 16, face = "bold")
    )

  # Save the plot if path is provided
  if (!is.null(path_saved)) {
    ensure_dir_exists(dirname(path_saved))

    # Only pass width and height if they are not NULL
    if (!is.null(width) && !is.null(height)) {
      ggsave(filename = path_saved, plot = p, width = width, height = height)
    } else {
      ggsave(filename = path_saved, plot = p)
    }
    cat("Confusion Matrix Heatmap saved in:", path_saved, "\n")
  }
  
  # return(p)
  invisible(p) # Return the plot without displaying
}






#' Plot feature importance from a random forest model
#' Plots variable importance scores from a trained Random Forest model.
#' Optionally saves the plot to a file.
#'
#' @param model Trained random forest model
#' @param path_saved File path to save the plot. If NULL, plot is only returned but not saved.
#' @param fill_color Color for the bars. Default: "steelblue"
#' @param importance_type Type of importance to plot. Either "MeanDecreaseAccuracy" (1) or "MeanDecreaseGini" (2). Default: 1
#' @param title Plot title. Default: "Feature Importance"
#' @param width Plot width in inches when saving. Default: 10
#' @param height Plot height in inches when saving. Default: 8
#' @return Invisibly returns the ggplot object.
#'
#' @examples
#' plot_feature_importance(model)
#' plot_feature_importance(model, path_saved = "importance.png", importance_type = 2)
#' @export
plot_feature_importance <- function(model, path_saved = NULL,
                                   fill_color = "steelblue",
                                   importance_type = 1,
                                   title = "Feature Importance",
                                   width = NULL,
                                   height = NULL) {
  # Check validate input
  if (!inherits(model, "randomForest")) {
    stop("The 'model' parameter must be a randomForest object")
  }
  if (!importance_type %in% c(1, 2)) {
    stop("importance_type must be either 1 (MeanDecreaseAccuracy) or 2 (MeanDecreaseGini)")
  }

  # Create importance dataframe
  importance_df <- data.frame(
  Feature = rownames(importance(model)), 
  Importance = importance(model)[, importance_type]  # Use the parameter value
)
  
  # Create the plot
  p <- ggplot(importance_df, aes(x = reorder(Feature, Importance), y = Importance)) +
    geom_bar(stat = "identity", fill = fill_color) +
    coord_flip() +
    labs(
      title = title,
      x = "Feature",
      y = paste0("Importance (", 
                 ifelse(importance_type == 1, "MeanDecreaseAccuracy", "MeanDecreaseGini"),
                 ")")
    ) +
    theme_minimal() +
    theme(
      axis.text = element_text(size = 14),
      axis.title = element_text(size = 16, face = "bold"),
      plot.title = element_text(size = 18, face = "bold")
    )
  
  # Save the plot if path is provided
  if (!is.null(path_saved)) {
    ensure_dir_exists(dirname(path_saved))

    # Only pass width and height if they are not NULL
    if (!is.null(width) && !is.null(height)) {
      ggsave(filename = path_saved, plot = p, width = width, height = height)
    } else {
      ggsave(filename = path_saved, plot = p)
    }
    cat("Feature Importance Plot saved in:", path_saved, "\n")
  }
  
  # return(p)
  invisible(p) # Return the plot without displaying
}

