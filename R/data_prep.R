#' Calculate animal age in years from date of birth
#'
#' This function converts dates of birth to ages in years, handling both single dates
#' and vectors of dates, with proper NA handling.
#'
#' @param dob A Date object or character vector of birth dates in "YYYY-MM-DD" format
#' @param reference_date The reference date for age calculation, defaults to current date
#' @return An integer vector representing ages in years
#' @examples
#' # Single date
#' calculate_age_years("2015-01-01")
#' # Vector of dates
#' calculate_age_years(c("2010-05-15", "2018-10-20", ...))
#' # With custom reference date
#' calculate_age_years("2015-01-01", reference_date = "2020-01-01")
#' @export
calculate_age_years <- function(dob, reference_date = Sys.Date()) { 

  if (is.null(dob)) stop("`dob` cannot be NULL.")
  if (!is.character(dob) && !inherits(dob, "Date")) {
    stop("`dob` must be a character vector or Date object.")
  }
  if (!inherits(reference_date, "Date") && !is.character(reference_date)) {
    stop("`reference_date` must be a Date object or character string.")
  }


  # Return NA for one NA inputs
  if (length(dob) == 1 && is.na(dob)) {
    return(NA_integer_)
  }
  
  # For vectors, handle NA values
  if (length(dob) > 1) {
    result <- rep(NA_integer_, length(dob))
    non_na_indices <- !is.na(dob)
    
    # Only process non-NA values
    if (any(non_na_indices)) {
      # Convert to "Date" format if not already
      dates_to_process <- dob[non_na_indices]
      if (!inherits(dates_to_process, "Date")) {
        dates_to_process <- as.Date(dates_to_process, format = "%Y-%m-%d")
      }
      
      # Calculate age for non-NA values
      if (!inherits(reference_date, "Date")) {
        reference_date <- as.Date(reference_date)
      }
      
      age_in_days <- as.numeric(difftime(reference_date, dates_to_process, units = "days"))
      result[non_na_indices] <- as.integer(age_in_days / 365)
    }
    
    return(result)
  }
  
  # Process single non-NA value
  # Convert to "Date" format if not already
  if (!inherits(dob, "Date")) {
    dob <- as.Date(dob, format = "%Y-%m-%d")
  }
  if (!inherits(reference_date, "Date")) {
    reference_date <- as.Date(reference_date)
  }
  
  # Calculate age in years
  age_in_days <- as.numeric(difftime(reference_date, dob, units = "days"))
  age_in_years <- as.integer(age_in_days / 365)
  return(age_in_years)
}



########=================##########



#' Assign season based on month
#' Maps numeric or character month values to seasons (Winter, Spring, Summer, Fall).
#'
#'
#' @param month A character or numeric vector of months (1-12 or "01"-"12")
#' @return A character vector of corresponding seasons (Winter, Spring, Summer, Fall, or Unknown)
#' @examples
#' assign_season(c("01", "04", "07", "10"))
#' assign_season(c(1, 3, 8))
#' @export
assign_season <- function(month) {
  if (!is.character(month) && !is.numeric(month)) {
    stop("`month` must be a character or numeric vector.")  
  }

  # Handle empty input
  if (length(month) == 0) {
    return(character(0))
  }

  # Ensure month is in character format & ensure two digits
  month <- as.character(month)
  month <- ifelse(!is.na(month) & nchar(month) == 1, paste0("0", month), month)

  seasons <- case_when(
    month %in% c("12", "01", "02") ~ "Winter",
    month %in% c("03", "04", "05") ~ "Spring",
    month %in% c("06", "07", "08") ~ "Summer",
    month %in% c("09", "10", "11") ~ "Fall",
    TRUE ~ "Unknown"
  )
  return(seasons)
}

#' Group rare categories in a column
#' Replaces specified rare categories in a column with a custom label (e.g., "Other").
#'
#' @param data A data frame
#' @param column_name The name of the column to process
#' @param rare_categories A vector of category names to group
#' @param other_name The name to assign to grouped categories, defaults to "Other"
#' @return A modified data frame with the specified column modified
#' @examples
#' group_rare_categories(data, "animal_type", c("reptile", "guinea pig"))
#' @export
group_rare_categories <- function(data, column_name, rare_categories, other_name = "Other") {
  if (!column_name %in% names(data)) {
    stop(paste("Column", column_name, "not found in the data frame"))
  }

  if (!is.character(rare_categories)) {
    stop("`rare_categories` must be a character vector.")
  }
  if (!is.character(other_name) || length(other_name) != 1) {
    stop("`other_name` must be a single character string.")
  }

  
  result <- data %>%
    mutate(!!sym(column_name) := ifelse(!!sym(column_name) %in% rare_categories, 
                                        other_name, 
                                        !!sym(column_name)))

    return(result)
}








#' Convert multiple columns to factors + Converts specified columns in a data frame to factor type.
#'
#' @param data A data frame
#' @param columns A character vector of column names to convert to factors
#' @return A data frame with specified columns converted to factors
#' @examples
#' convert_to_factors(df, c("animal_type", "sex", "adopted"))
#' @export
convert_to_factors <- function(data, columns) {
  if (!is.character(columns)) {
    stop("`columns` must be a character vector.")
  }

  # Check if all columns exist in the data frame
  missing_cols <- columns[!columns %in% names(data)]
  if (length(missing_cols) > 0) {
    stop("The following columns do not exist in the data frame: ",
         paste(missing_cols, collapse = ", "))
  }
  
  # Convert each column to factor
  for (col in columns) {
    data[[col]] <- as.factor(data[[col]])
  }
  
  return(data)
}

