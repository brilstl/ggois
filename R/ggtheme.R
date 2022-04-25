#' @title helper function to add the ois-style to ggplot2
#' @import ggplot2
#' @export
theme_ois <- function(){

    font <- "sans"

    ggplot2::theme_bw() +
      ggplot2::theme(
        axis.text = ggplot2::element_text(family = font, size = 20, face = "bold"),
        plot.caption = ggplot2::element_text(family = font, size = 14, face = "bold"),
        axis.title = ggplot2::element_text(family = font, hjust = 1, size = 14),
        plot.subtitle = ggplot2::element_text(family = font, size = 20),
        plot.title = ggplot2::element_text(family = font, lineheight = 1.5, size = 21, face = "bold"),
        panel.grid.major = ggplot2::element_blank(),
        strip.background = ggplot2::element_blank(),
        panel.grid.major.y = ggplot2::element_line(size = 1.2),
        panel.grid.minor.y = ggplot2::element_blank(),
        panel.grid.minor.x = ggplot2::element_blank(),
        legend.position= "bottom",
        legend.justification = "center",
        panel.border = ggplot2::element_rect(fill = "transparent", color = NA),
        legend.text = element_text(family = font, size = 20),
        legend.title = element_text(family = font, size = 20, face = "bold"),
        axis.ticks = ggplot2::element_blank(),
        panel.background = ggplot2::element_rect(fill = "transparent"),
        plot.background = ggplot2::element_rect(fill = "transparent", color = NA),
        legend.background = ggplot2::element_rect(fill = "transparent"),
        legend.box.background = ggplot2::element_rect(fill = "transparent", colour = "transparent"),
        strip.text = ggplot2::element_text(family = font, size = 20, face = "bold")
      )


}
