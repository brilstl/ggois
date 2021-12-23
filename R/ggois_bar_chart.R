#' @title helper function to make a bar chart

#' @export
ggois_bar_chart <- function(.data, ...) UseMethod("ggois_bar_chart")

#' @export
#' @importFrom dplyr select mutate summarise
ggois_bar_chart.data.frame <- function(.data, y, x){

  `%>%` <- dplyr::`%>%`


  .data <-
    .data %>%
    dplyr::group_by(.y = {{y}}) %>%
    dplyr::summarise(.waarde := sum({{x}}, na.rm = TRUE),
                     .groups = "keep") %>%
    dplyr::mutate(percent = .waarde/sum(.waarde))

  class(.data) <- c("bar_chart", class(.data))

  return(.data)

}


autoplot.bar_chart <- function(object, ...){

  `%+%` <- ggplot2::`%+%`

  base_chart <- ggplot2::ggplot(data = object)

  aes_spliced <- ggplot2::aes(
    x = .waarde,
    y = .y
  )

  gg_ois <-
    base_chart %+%
    aes_spliced %+%
    geom_col() %+%
    theme_ois()


  return(gg_ois)


}
