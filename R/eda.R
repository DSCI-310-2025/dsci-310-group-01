#' Save count table of a column
#' Counts the occurrences of unique values in a column and saves the result as a CSV file.
#' 
#' @param data A data frame
#' @param col_name Column to count
#' @param output_path File path to save CSV
#' @return No return value. Writes a CSV file to the specified path.
#'
#' @examples
#' save_count_table(df, "animal_type", "results/tables/animal_counts.csv")
#'
#' @export
save_count_table <- function(data, col_name, output_path) {
  count_table <- data %>% count(.data[[col_name]], sort = TRUE)
  write_csv(count_table, output_path)
}





#' Plot overall adoption distribution
#' Creates a bar plot showing the distribution of adoption outcomes (e.g., Yes/No).
#'
#' @param data A data frame that includes a column named "adopted".
#'
#' @return A ggplot object representing the adoption distribution.
#'
#' @examples
#' plot_adoption_distribution(df)
#'
#' @export
plot_adoption_distribution <- function(data) {
  ggplot(data, aes(x = adopted)) +
    geom_bar(fill = "steelblue") +
    geom_text(stat = 'count', aes(label = after_stat(count)), vjust = -0.5, size = 6) +
    labs(title = "Adoption Rate Distribution", x = "Adopted", y = "Count") +
    theme_minimal(base_size = 16)
}

#' Plot adoption distribution by group
#' Generates a grouped bar chart showing adoption counts by a specified grouping variable.
#'
#' @param data A data frame.
#' @param group_col A string specifying the column to group by (e.g., animal_type).
#' @param title A string for the plot title.
#' @param xlab A string for the x-axis label.
#' @param output_path File path to save the resulting plot as a PNG.
#' @return No return value. Saves the plot to the specified file path.
#'
#' @examples
#' plot_grouped_adoption(df, "animal_type", "Adoption by Animal Type", "Animal Type", "results/figures/adoption_by_type.png")
#'
#' @export
plot_grouped_adoption <- function(data, group_col, title, xlab, output_path) {
  p <- ggplot(data, aes(x = .data[[group_col]], fill = adopted)) +
    geom_bar(position = "dodge") +
    labs(title = title, x = xlab, y = "Count") +
    theme_minimal(base_size = 17) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  ggsave(output_path, plot = p, width = 10, height = 8)
}






#' Plot age distribution histogram
#' Creates a histogram showing how age varies with adoption outcomes.
#'
#' @param data A data frame with an "age" column and an "adopted" column.
#' @param output_path File path to save the resulting histogram
#' @return No returned value. Saves the plot to the specified file path.
#' @examples
#' plot_age_distribution(df, "results/figures/age_distribution.png")
#'
#' @export
plot_age_distribution <- function(data, output_path) {
  p <- ggplot(data, aes(x = age, fill = adopted)) +
    geom_histogram(bins = 30, alpha = 0.7, position = "identity", color = "black") +
    labs(title = "Age Distribution by Adoption Status", x = "Age (years)", y = "Count") +
    theme_minimal(base_size = 20)
  ggsave(output_path, plot = p, width = 15, height = 10)
}
