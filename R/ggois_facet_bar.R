#' @title helper function to make a facet bar
#' @param .data a data.frame tibble or data.table
#' @param y dependent variable in the equation
#' @param x the independent variable in the equation
#' @param z the moderater variable in the equaion

#' @export
#' @param object a ggois object
ggois_facet_bar <- function(.data, ...) UseMethod("ggois_facet_bar")

#' @export
#' @importFrom dplyr select mutate summarise
ggois_facet_bar.data.frame <- function(.data, y, x, z = NULL, ...){

  `%>%` <- dplyr::`%>%`

  .data <-
    .data %>%
    dplyr::group_by(!!!vars({{y}},{{z}}))

  groups <- dplyr::group_vars(.data)

  .data <- .data %>%
    dplyr::summarise(.waarde := sum({{x}}, na.rm = TRUE), .groups = "drop") %>%
    {if(length(groups) > 1) dplyr::group_by(.,{{y}}) else .} %>%
    dplyr::mutate(percent = .waarde/sum(.waarde)) %>%
    dplyr::group_by(!!!vars({{y}},{{z}}))

  class(.data) <- c("ggois_facet_bar", class(.data))

  return(.data)

}
