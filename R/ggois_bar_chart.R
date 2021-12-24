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
    dplyr::summarise(.waarde := sum({{x}}, na.rm = TRUE)) %>%
    dplyr::mutate(percent = .waarde/sum(.waarde)) %>%
    dplyr::group_by(.y)

  class(.data) <- c("bar_chart", class(.data))

  return(.data)

}
#' @importFrom forcats as_factor fct_reorder fct_relevel fct_other
#' @importFrom scales percent dollar_format
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
      ungroup %>%
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
      panel.grid.major.y = element_blank()
    )


  return(gg_ois)


}

#' @export
autotable <- function(object, ...) {
  UseMethod("autotable")
}

#' @importFrom gt gt fmt_percent
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
