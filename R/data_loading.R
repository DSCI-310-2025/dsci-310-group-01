#' Ensure directory exists
#' 
#' Checks if a directory exists and creates it if it doesn't
#'
#' @param dir_path Character string specifying the directory path
#' @param recursive Logical. Should parent directories be created? Default TRUE
#' @param show_warnings Logical. Should warnings be shown? Default FALSE
#' @return Nothing, creates directory if it doesn't exist
#' @examples
#' ensure_dir_exists("results/figures")
#' ensure_dir_exists("data/processed", recursive = TRUE)
#'
#' 

#' @export
ensure_dir_exists <- function(dir_path, recursive = TRUE, show_warnings = FALSE) {
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = recursive, showWarnings = show_warnings)
  }
}





#' Load CSV and print dimensions
#'
#' @param path A string specifying the path to the CSV file
#' @param verbose logical: show information be printed to console (Default TRUE)
#' @return A tibble (data.frame) loaded from the file and print dimensions of the dataset if verbose is TRUE
#' 
#' @examples
#' data <- load_data("data/processed/longbeach_transformed.csv")
#' data <- load_data("data/processed/my_data.csv", verbose = FALSE)
#'
#' @export
load_data <- function(path, verbose = TRUE) {
  if (!is.character(path) || length(path) != 1) {
    stop("`path` must be a single character string.")
  }
  if (!is.logical(verbose) || length(verbose) != 1) {
    stop("`verbose` must be a single logical value (TRUE or FALSE).") 
  }
  # Check if file exists
  if (!file.exists(path)) {
    stop("File does not exist: ", path)
  }
  if (verbose) {
    cat("Loading dataset from:", path, "\n")
  }
  df <- readr::read_csv(path)
  if (verbose) {
    cat("Dataset dimensions:", nrow(df), "rows,", ncol(df), "columns\n")
  }
  return(df)
}