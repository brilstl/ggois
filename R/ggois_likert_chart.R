#' @title helper function to make a likert chart
#' @param .data a data.frame tibble or data.table
#' @param y dependent variable in the equation
#' @param x the independent variable in the equation
#' @param z the moderater variable in the equaion

#' @export
#' @param object a ggois object
ggois_likert_chart <- function(.data, ...) UseMethod("ggois_likert_chart")

#' @export
#' @importFrom dplyr select mutate summarise
ggois_likert_chart.data.frame <- function(.data, y, x, z = NULL, ...){

  `%>%` <- dplyr::`%>%`

  .data_names <-
    .data %>%
    dplyr::select(!!!vars({{y}}, {{z}}, {{x}})) %>%
    names

  .data <-
    .data %>%
    dplyr::group_by(!!!vars({{y}},{{z}}))

  groups <- dplyr::group_vars(.data)

  group_lenght <- length(groups)

  if(group_lenght > 1){
    names(groups) <- c(".y", ".z")
    new_names <- c(".y", ".z", ".x")
  }
  else{
    names(groups) <- c(".y")
    new_names <- c(".y", ".x")
  }

  .data <- .data %>%
    dplyr::count({{x}}, name = ".waarde") %>%
    dplyr::mutate(percent = .waarde/sum(.waarde)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(
      tidyselect::any_of(groups)
      ) %>%
    dplyr::rename(.x = {{x}}) %>%
    dplyr::group_by(
      dplyr::across(
        tidyselect::any_of(
          c(names(groups))
          )))


  for(i in seq_along(.data_names)){

   attr(.data[[new_names[i]]], "label") <-  .data_names[i]

  }

  class(.data) <- c("ggois_likert_chart", class(.data))

  return(.data)

}

#' @importFrom forcats as_factor fct_reorder fct_relevel fct_other
#' @importFrom scales percent dollar_format
#' @param object a ggois object
#' @export
autoplot.ggois_likert_chart <- function(object, percent = FALSE, ...){

  aes_spliced <- ggplot2::aes(
    x = percent,
    y = .y,
    fill = .x
    )

  x_as <- ggplot2::scale_x_continuous(labels = scales::percent,
                                      breaks = seq(0,1,.2))


  # get ggplot2 pipe ----

  `%+%` <- ggplot2::`%+%`

  # create base chart ----

  base_chart <- ggplot2::ggplot(data = object)

  # check for facet ----

  groups <- dplyr::group_vars(object)

  group_lenght <- length(groups)

  if(group_lenght > 1){
    add_facet <- facet_wrap(~ .z, ncol = 1L)
  }
  else{
    add_facet <- NULL
  }

  gg_ois <-
    base_chart %+%
    aes_spliced %+%
    ggplot2::geom_col() %+%
    theme_ois() %+%
    ggplot2::labs(x = NULL,
                  y = NULL) %+%
    x_as %+%
    scale_fill_manual(values = kleur_fun(length(unique(object$.x)),
                                         ...)) %+%
    add_facet %+%
    ggplot2::guides(fill = ggplot2::guide_legend(reverse = TRUE)) %+%
    ggplot2::theme(
      panel.grid.major.y = ggplot2::element_blank()
    ) %+%
    ggplot2::expand_limits(x = c(1, 1))


  return(gg_ois)


}

#' @export
#' @param object a ggois object
autotable <- function(object, ...) {
  UseMethod("autotable")
}

#' @importFrom gt gt fmt_percent
#' @param object a ggois object
#' @export
autotable.ggois_likert_chart <- function(object, ...){

  # check for facet ----

  groups <- dplyr::group_vars(object)

  group_lenght <- length(groups)

  object %>%
    dplyr::ungroup() %>%
    dplyr::rename(n = .waarde,
                  `%` = percent) %>%
    tidyr::pivot_wider(
      names_from = .x,
      names_glue = "{.x}_{.value}",
      values_from = n:`%`
    ) %>%
    select(sort(tidyselect::peek_vars())) %>%
    mutate(dplyr::across(
      where(is.numeric), replace_na, 0)) %>%
    {if(group_lenght > 1) dplyr::group_by(., dplyr::across(tidyselect::any_of(groups[2]))) else .} %>%
    gt::gt() %>%
    gt::cols_align(
      columns = dplyr::contains("_"),
      align = "center"
    ) %>%
    gt::tab_spanner_delim(
      columns = dplyr::contains("_"),
      delim = "_"
    ) %>%
    gt::fmt_percent(
      columns = dplyr::ends_with("%"),
      decimals = 0L
    ) %>%
    gt::cols_label(
      .y  = attr(object[[".y"]], "label")
    )

}
