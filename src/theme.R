
font_selected <- "Quicksand"

# library(showtext)
# this_font <- font_add_google(name = font_selected)

#Light Colors
bg_color <- "#FFFFFF"
fg_color <- "#363636"
detail_color <- "#444444"

green_purple_theme <- list(
  "yellow" = "#F0E14C",
           "sgbus-green" = "#6bd425ff",
           "avocado" = "#618b25ff",
           "blue" = "#1F77B4",
           "dark-purple" = "#42113cff",
           "dark-purple-2" = "#370926ff",
           "gray1" = "#D3D3D3",
           "gray2" = "#A9A9A9"
)

cool_winter_theme <- list(
  "forest_green" = "#78B693",
  "baby_blue" = "#ABCEEF",
  "light_blue" = "#5688b0",
  "deep_blue" = "#3D587B",
  "light_gray" = "#D3D3D3",
  "mid_gray" = "#888797",
  "dark_gray" = "#464646",
  "pastel_orange" = "#e09346",
  "off_white" = "#E8ECEE"
)



beercolors <- list(
  "darkblue" = "#0F6A94",
  "light_blue" = "#4DC6FF",
  "bbco_blue" = "#2DA6E0",
  "dark_brown" = "#945100",
  "light_brown" = "#E08F2D",
  "fiddlehead_light_green" = "#769F54",
  "hillfarmstead_light_brown" = "#94886D",
  "zero_gravity_madonna_yellow" ="#E3AC3B",
  "switchback_turquise" = "#2C667A"
)


element_rect_round <- function(
    fill = NULL,
    colour = NULL,
    size = NULL,
    linetype = NULL,
    color = NULL,
    inherit.blank = FALSE,
    radius = unit(0.1, "snpc")
) {
  if (!is.null(color)) colour <- color
  structure(
    list(fill = fill,
         colour = colour,
         size = size,
         linetype = linetype,
         inherit.blank = inherit.blank,
         radius = radius),
    class = c("element_rect_round", "element_rect", "element")
  )
}


custom_theme <- function(p) {
  ggplot2::theme_bw() +
    ggplot2::theme(
      text = element_text(family = font_selected, size = 14),
      plot.background = element_rect(fill = bg_color, colour = NA),
      panel.background = element_rect(fill = bg_color, colour = NA),
      panel.border = element_blank(),# element_rect_round(color = detail_color, size = .5),
      plot.title = element_text(color = detail_color, hjust = 0),
      plot.subtitle = element_text(color = "grey", hjust = 0),
      axis.title.x = element_text(color = detail_color),
      axis.title.y = element_text(color = detail_color),
      axis.text.x = element_text(color = detail_color),
      axis.text.y = element_text(color = detail_color),
      axis.ticks = element_blank(),
      plot.caption = element_text(color = detail_color),
      legend.title = element_blank(),
      legend.background = element_rect(fill = bg_color, colour = NA),
      legend.text = element_text(color = detail_color),
      legend.box.background = element_rect(fill = bg_color, colour = NA),
      legend.key = element_blank(),
      strip.background = element_blank(),#element_rect(fill = bg_color, color = detail_color),
      strip.text = element_text(color = detail_color),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      legend.direction = "horizontal",
      legend.position = "top",
      axis.line.x = element_line(size = 2, lineend = "round", color = bg_color ),
      axis.line.x.top = element_line(size = 2, lineend = "round", color = bg_color )
    )
}


my_theme <- bs_theme(
  bg = bg_color,
  fg = fg_color,
  primary = fg_color,
  secondary = fg_color,
  base_font =  font_selected
)

