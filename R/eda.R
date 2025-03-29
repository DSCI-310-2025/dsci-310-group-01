#' Save count table of a column
#' @param data A data frame
#' @param col_name Column to count
#' @param output_path File path to save CSV
#' @export
save_count_table <- function(data, col_name, output_path) {
  count_table <- data %>% count(.data[[col_name]], sort = TRUE)
  write_csv(count_table, output_path)
}

#' Plot adoption distribution
#' @param data A data frame
#' @return ggplot object
#' @export
plot_adoption_distribution <- function(data) {
  ggplot(data, aes(x = adopted)) +
    geom_bar(fill = "steelblue") +
    geom_text(stat = 'count', aes(label = after_stat(count)), vjust = -0.5, size = 6) +
    labs(title = "Adoption Rate Distribution", x = "Adopted", y = "Count") +
    theme_minimal(base_size = 16)
}

#' Plot grouped adoption bar chart
#' @param data A data frame
#' @param group_col Column to group by
#' @param title Plot title
#' @param xlab X-axis label
#' @param output_path File path to save plot
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
#' @param data A data frame
#' @param output_path File path to save plot
#' @export
plot_age_distribution <- function(data, output_path) {
  p <- ggplot(data, aes(x = age, fill = adopted)) +
    geom_histogram(bins = 30, alpha = 0.7, position = "identity", color = "black") +
    labs(title = "Age Distribution by Adoption Status", x = "Age (years)", y = "Count") +
    theme_minimal(base_size = 20)
  ggsave(output_path, plot = p, width = 15, height = 10)
}
