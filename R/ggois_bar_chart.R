#' @title helper function to make a bar chart
#' @param .data a data.frame tibble or data.table
#' @param y dependent variable in the equation
#' @param x the independent variable in the equaion

#' @export
#' @param object a ggois object
ggois_bar_chart <- function(.data, ...) UseMethod("ggois_bar_chart")

#' @export
#' @importFrom dplyr select mutate summarise
ggois_bar_chart.data.frame <- function(.data, y, x, ...){

  `%>%` <- dplyr::`%>%`

  .data_labels <-
    .data %>%
    select({{y}}, {{x}}) %>%
    names


  .data <-
    .data %>%
    dplyr::group_by(.y = {{y}}) %>%
    dplyr::summarise(.waarde := sum({{x}}, na.rm = TRUE)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(percent = .waarde/sum(.waarde)) %>%
    dplyr::group_by(.y)

  #.data_labels <- c(.data_labels, "waarde", "percentage")

  attr(.data$.y, "label") <- .data_labels[1]
  attr(.data$.waarde, "label") <- .data_labels[2]
  attr(.data$percent, "label") <- .data_labels[2]

  class(.data) <- c("bar_chart", class(.data))

  return(.data)

}
#' @importFrom forcats as_factor fct_reorder fct_relevel fct_other
#' @importFrom scales percent dollar_format
#' @param object a ggois object
#' @export
autoplot.bar_chart <- function(object, percent = FALSE, ...){

  # check if grey value is added (see gray_check.R) ---

  gray_check <- gray_shades(object, .y, dim_output = TRUE, ...)

  if(is.na(gray_check[1])){
    geen_antwoord <- ggplot2::scale_fill_manual(values = c("#71BDEE"))

  }
  else{

    brew_gray <- grDevices::colorRampPalette(c('gray85', 'gray91'))

    gray_add <- brew_gray(length(gray_check))

    kleur <- c(gray_add, "#71BDEE")

    geen_antwoord <- ggplot2::scale_fill_manual(values = kleur)

  }

  gray_check <-  unlist(ifelse(is.na(gray_check), list(NULL), gray_check))

  # adjust factor level (.y) ----

  if(is.numeric(object$.y)){
    object <- object %>%
      mutate(.y = as_factor(.y))
  }

  if(percent){

    object <-
      object %>%
      dplyr::ungroup() %>%
      mutate(.y = forcats::fct_reorder(.y, percent))

    aes_spliced <- ggplot2::aes(
      x = percent,
      y = .y,
      fill = .highlight
    )


    x_as <- ggplot2::scale_x_continuous(labels = scales::percent,
                                        expand = c(0.0001,0.01))

  }else{

    object <-
      object %>%
      dplyr::ungroup() %>%
      mutate(.y = forcats::fct_reorder(.y, .waarde))

    aes_spliced <- ggplot2::aes(
      x = .waarde,
      y = .y,
      fill = .highlight
    )


    x_as <- ggplot2::scale_x_continuous(labels = scales::dollar_format(prefix = "",
                                                                       big.mark = ".",
                                                                       decimal.mark = ","),
                                        expand = c(0.01,0.1))


  }

  object <-
    object %>%
    mutate(.y = forcats::fct_relevel(.y,
                                     gray_check,
                                     after = 0),
           .highlight = forcats::fct_other(.y,
                                          keep = gray_check,
                                          other_level = "named"))


  # get ggplot2 pipe ----

  `%+%` <- ggplot2::`%+%`

  # create base chart ----

  base_chart <- ggplot2::ggplot(data = object)

  gg_ois <-
    base_chart %+%
    aes_spliced %+%
    ggplot2::geom_col() %+%
    theme_ois() %+%
    ggplot2::labs(x = NULL,
                  y = NULL) %+%
    ggplot2::theme(legend.position = "none") %+%
    geen_antwoord %+%
    x_as %+%
    ggplot2::theme(
      panel.grid.major.y = element_blank(),
      panel.grid.major.x = ggplot2::element_line(size = 1.2)
    )


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
autotable.bar_chart <- function(object, ...){


  gray_check <- gray_shades(object, .y, dim_output = TRUE, ...)

  gray_check <-  unlist(ifelse(is.na(gray_check), list(NULL), gray_check))

  object <-
    object %>%
    ungroup %>%
    mutate(.y = as_factor(.y),
           .y = forcats::fct_reorder(.y, -.waarde),
           .y = forcats::fct_relevel(.y,
                                     gray_check,
                                     after = Inf))


  object %>%
    dplyr::arrange(.y) %>%
    gt::gt() %>%
    gt::fmt_percent(percent,
                    decimals = 0L)

}

#' @export
#' @param object a ggois object
autovega <- function(object, ...){
  UseMethod("autovega")
}

#' @import vegawidget
#' @import jsonlite
#' @export
#' @param object a ggois object
#' @param height the height of the vega object
#' @param titel the title of the vegaplot

autovega.bar_chart <- function(object, height = NULL, ...){

  bar_json$encoding$tooltip[[1]]$title <- attr(object$.y, "label")
  bar_json$encoding$tooltip[[2]]$title <- attr(object$.waarde, "label")

  bar_json$data$values <-
    object %>%
    rename(naam = .y,
           waarde = .waarde) %>%
    arrange(- waarde) %>%
    jsonlite::toJSON() %>%
    jsonlite::parse_json()

  if(is.null(height)){

  }
  else{
    bar_json$height <- height
  }

  bar_json[["config"]] <- vega_config

  bar_json %>%
    vegawidget::as_vegaspec() %>%
    vegawidget::vegawidget()

}
