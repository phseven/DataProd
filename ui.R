
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage( theme = "bootstrap.css",

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
        img(src = "Diamond.jpg", width = "221px", height = "140px"),
        h3("Price Your Diamond"),
        sliderInput("carat",
                    label = h5("Carat"),
                    min = 0.2,
                    max = 5.0,
                    step = 0.1,
                    format = "0.0",
                    value = 0.2),
        selectInput("cut", label = h5("Cut"), 
                    choices = list("Fair" = 1, "Good" = 2, 
                        "Very Good" = 3, "Premium" = 4,
                        "Ideal" = 5), 
                    selected = 1),
        selectInput("color", 
                    label = h5("Color"), 
                    choices = list("D (Most Expensive)" = 7, "E" = 6,
                        "F" = 5, "G" = 4, "H" = 3, "I" = 2,
                        "J (Least Expensive)" = 1), 
                    selected = 1),
        selectInput("clarity", 
                    label = h5("Clarity"), 
                    choices = list("IF (Most Expensive)" = 8, "VVS1" = 7,
                                   "VVS2" = 6, "VS1" = 5, "VS2" = 4, 
                                   "SI1" = 3, "SI2" = 2, 
                                   "I1 (Least Expensive)" = 1), 
                    selected = 1),
        sliderInput("depth",
                    label = h5("Depth (%)"),
                    min = 43,
                    max = 79,
                    step = 0.1,
                    format = "#0.0",
                    value = 62),
        sliderInput("table",
                    label = h5("Table (%)"),
                    min = 43,
                    max = 95,
                    step = 1,
                    format = "##",
                    value = 57)
    ),
    
    # Show a plot of the generated distribution
    
    mainPanel(
        div(
            h3("What is the Estimated Price of This Diamond ?"),
            div(),
            div(
                h3(htmlOutput("pred"))
            ),
            hr(),
            div()
        ),
        div(
            h4("How accurate is the price ?"),
            p("We run an advanced prediction algorithm on a database of 
               more than 50,000 diamonds to price the diamond you select.
               Given the wide variability in diamond prices in the 
               world market, our price range is still accurate in 
               more than 90% cases.")
            ),
        div(),
        hr(),
        div(
            h4("What determines a diamond's price ?"),
            p("The 4Cs (Carat, Cut, Color, Clarity), and to a lesser 
              extent, depth and table.")
            ),
        div(
            h5("Carat"),
            p("Carat specifies the weight of the diamond.",
                "Did you know that 1 carat is equal to 0.2 grams ?")
            ),
        div(
            h5("Cut"),
            p("Cut of a diamond determines its proportion, symmetry and 
                polish and can bring out the diamond's brilliance." )
            ),
        div(
            h5("Color"),
            p("A structurally perfect and chemically pure diamond is
            transparent and completely colorless (GIA grade D) and most
            expensive. GIA grades D-F are considered colorless, whereas 
            grades G-J are near colorless. GIA grade K-M fall under the 
            'faint yellow' group. The Color scale is shown below:"),
            p("D (best) > E > F > G > H > I > J (worst)  ")            
            ),
        div(
            h5("Clarity"),
            p("Most diamonds have minor internal inclusions or surface 
              blemishes. A diamond without any inclusions or blemishes is very
              very rare and has a Clarity grade of flawless (FL). A diamond 
              without an internal inclusion and only minor blemishes is 
              graded internally flawless (IF) and can be expensive. The
              Clarity scale is as follows:"),
            p("FL (best) > IF > VVS1 > VVS2 > VS1 > VS2 > SI1 > SI2 > 
              I1 (worst)")
            ),
        div(
            h5("Depth"),
            p("The total depth (z) as a percentage (%) of average diameter 
            ((length (x) + width (y)/2). The Ideal Depth is between 58-60%,
            whereas Depth under 57% or over 66% is considered Poor.")
            ),
        div(
            h5("Table"),
            p("The width of the top of the diamond relative to its widest 
            point (%). Ideal range is 53 - 58%, whereas anything over 70% is
            considered Poor.")
          ),
        div()
    )
  )
))
