
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

# -- set a seed

set.seed(11)

# -- include required packages

require(ggplot2)
require(caret)
require(data.table)
require(randomForest)

# Copy diamonds to a data table.

dia <- as.data.table(diamonds)

# Function for converting price to price range.
# Price range a : < 1000, b : [1000, 2000), c: [2000, 3000],
# d: [3000, 6000), e: [6000, 10000), f: >= 10000.

prcRange <- data.table(code = letters[1:6],
                      txt = c( "Less than 1,000 USD.",
                               "Between 1,000 and 1,999 USD.",
                               "Between 2,000 and 2,999 USD.",
                               "Between 3,000 and 5,999 USD.",
                               "Between 6,000 and 9,999 USD.",
                               "More than 10,000 USD."
                               ), key = "code")

prange <- function(prc) {
ifelse(prc >= 10000, "f",
       ifelse(prc >= 6000, "e",
              ifelse(prc >= 3000, "d",
                     letters[floor(prc/1000) + 1])))
}

# Function getModel loads a trained model from file, if the file
# exists. Else it generates a model and returns it.

getModel <- function() {
    
# First try to load model from file.
    
if(file.exists("diamonds_rf.fit") )
{
    load("diamonds_rf.fit")
    return(fit) 
}

# If file does not exist, create the model.

# create a vector of price (outcome)

price <- dia[, as.factor(prange(price))]

# The prediction will be based on the 4Cs (carat, cut, color, clarity),
# depth and table.

preds <- dia[,list(carat, cut, color, clarity, depth, table)]
preds1 <- dia[,list(carat, cut, color, clarity)]

# Create a traindt training dataset and testdt testing dataset by using
# the createDataPartition function from the caret package.
# Change output of createDataPartition from matrix to vector.

inTrain <- as.vector(createDataPartition(y = price, p = 0.9, list = FALSE))

traindt <- preds[inTrain]
testdt <- preds[-inTrain]

# Similarly, partition the predicted variable price into training and test.

trainPrice <- price[inTrain]
testPrice <- price[-inTrain]

# Specify training control parameters: cv = cross validation
# number = 3 (number of folds).

fitCtl <- trainControl(method = "none", classProbs = TRUE)

# Create a random forest based prediction model.

fit <- train(trainPrice ~ ., data = traindt,
              method = "rf",
              trControl = fitCtl,
              tuneGrid = data.frame(mtry = 6),    
              verbose = FALSE )

predPrice <- predict(fit, newdata=testdt)
confusionMatrix(predPrice, testPrice)
tt <- data.table(predPrice, testPrice)

return(fit)
}

predictPrice <- function(fit, carat1, cut1, color1, clarity1, 
                         depth1, table1) {
    
# The vectors for cut, color, and clarity.

cutV <- c("Fair", "Good", "Very Good", "Premium", "Ideal")
colorV <- c("J", "I", "H", "G", "F", "E", "D") 
clarityV <- c("I1", "SI2", "SI1", "VS2", "VS1", "VVS2", "VVS1", "IF")

dt1 <- data.table(carat = carat1, cut = cutV[as.integer(cut1)], 
                 color = colorV[as.integer(color1)], 
                 clarity = clarityV[as.integer(clarity1)], 
                 depth = depth1, table = table1)
    
predCd <- as.character(predict(fit, newdata= dt1))
prcRange[predCd][,txt]
}



library(shiny)

shinyServer(function(input, output) {

#   output$distPlot <- renderPlot({
# 
#     # generate bins based on input$bins from ui.R
#     x    <- faithful[, 2]
#     bins <- seq(min(x), max(x), length.out = input$bins + 1)
# 
#     # draw the histogram with the specified number of bins
#     hist(x, breaks = bins, col = 'darkgray', border = 'white')
# 
#   })
    
  oPred <- reactive( {
          predictPrice(fit, input$carat, input$cut, 
                  input$color, input$clarity, input$depth, 
                  input$table)
  })
  
  output$pred <- renderText({oPred()})

})
