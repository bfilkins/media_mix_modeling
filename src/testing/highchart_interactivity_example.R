library(RColorBrewer)

ui <- shinyUI(
  fluidPage(
    column(width = 8, highchartOutput("hcontainer", height = "500px")), #verbatimTextOutput("t1"),
    highchartOutput('hcontainer2')
  )
)

server <- function(input, output) {
  irisi <- iris %>% mutate(mycolor= case_when(Species=="setosa" ~"red",
                                              Species=="versicolor" ~"green",  Species=="virginica" ~"blue"))
  mcolor <- unique(irisi$mycolor)
  
  # Define the number of colors you want
  nb.cols <- 10  ## define a large enough number here to pick from a palette or manaully set mycolor2 with your choice of colors
  mycolor1 <- colorRampPalette(brewer.pal(8, "Set2"))(nb.cols)
  mycolor2 <- c("red", "blue", "darkgreen", "brown", "grey", "black", "purple", "green", "darkblue", "steelblue", "orange", "maroon", "yellow",
                     "gray20",  "gray35", "gray50", "gray65", "gray80", "gray95", "cyan")
                     
  uSpecies <- unique(iris$Species)
  n <- length(uSpecies)
  mycolor <- mycolor2[1:n]  ##  choose from mycolor1, if necessary
  dfc <- data.frame(uSpecies, mycolor)
  
  output$hcontainer <- renderHighchart({
    legendMouseOverFunction <- JS("function(event) {Shiny.onInputChange('legendmouseOver', this.name);}")
    
    hchart(iris, "scatter", hcaes(x = `Sepal.Length`, y = `Sepal.Width`, group = Species ) ) %>%
      hc_colors(mycolor) %>%
      hc_plotOptions(series = list(events = list(mouseOver = legendMouseOverFunction)))
  })
  
  
  selected_species = eventReactive(input$legendmouseOver, {
    input$legendmouseOver
  })
  
  #output$t1 <- renderPrint({print(input$legendmouseOver)})
  
  output$hcontainer2 <- renderHighchart({
    req(selected_species())
    selected_species = selected_species()
    iris2 <- iris %>% filter(Species == selected_species)
    dfc2 = dfc %>% filter(uSpecies == selected_species)
    m2color <- unique(dfc2$mycolor)
    hchart(iris2, "scatter", hcaes(x = `Sepal.Length`, y = `Sepal.Width`, group = Species)) %>%
      hc_colors(m2color)
  })
}

shinyApp(ui, server)