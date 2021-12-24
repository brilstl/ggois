#' @title Helper voor kleuren brewer voor OIS huisstijl die grijswaarde bepaald
#' @param .data het dataframe wat wordt meegeven aan de plot
#' @param fill de waarde waarmee de balken worden gevuld
#' @param cat_grijs steekwoorden die je als grijs wil tonen
#' @export
gray_shades <- function(.data, fill, cat_grijs = NA, dim_output = FALSE, ...){


  # check and assign 'gray' cat. ----

  kleur_lab <- .data %>%
    distinct({{fill}}) %>%
    arrange({{fill}}) %>%
    pull({{fill}})

  gray_check <- sum(
    grepl(
      c(cat_grijs),
      kleur_lab,
      ignore.case = TRUE
    ),
    na.rm = TRUE
  )

  kleur_n <- length(kleur_lab)

  kleur <- kleur_fun(kleur_n, ...)

  if(gray_check == 0){

    kleur <- kleur

  }
  else if(gray_check > 0){

    n_keep <- length(kleur) - gray_check

    brew_gray <- grDevices::colorRampPalette(c('gray85', 'gray91'))

    gray_add <- brew_gray(gray_check)

    kleur <- c(kleur[c(1:n_keep)], gray_add)

  }

  if(dim_output){

    gray_check <- as.character(
      kleur_lab[grepl(
        c(cat_grijs),
        as.character(kleur_lab),
        ignore.case = TRUE
      )]
    ) %>%
      unique

    return(gray_check)

  }
  else{

    return(kleur)

  }



}


