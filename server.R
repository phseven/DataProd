
# Server logic for a Shiny web application to estimate diamond price.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

# --- Do basic Setup first -------

# -- clean start

rm(list = ls())

# -- set a seed

set.seed(11)

# -- include required packages

require(ggplot2)
require(caret)
require(data.table)
require(randomForest)

# Copy diamonds to a data table.

dia <- as.data.table(diamonds)

# --- End of Setup ----------

# --- Define the necessary functions ---

# prcRange datatable to convert price range code to text.
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

# Function for converting price to price range.
# Price range a : < 1000, b : [1000, 2000), c: [2000, 3000],
# d: [3000, 6000), e: [6000, 10000), f: >= 10000.

prange <- function(prc) {
   ifelse(prc >= 10000, "f",
       ifelse(prc >= 6000, "e",
              ifelse(prc >= 3000, "d",
                     letters[floor(prc/1000) + 1])))
}

# Function getModel generates a model and returns it.

getModel <- function() {
    
    # create a vector of price (outcome)

    price <- dia[, as.factor(prange(price))]

    # The prediction will be based on the 4Cs (carat, cut, color, clarity),
    # depth and table.
    
    preds <- dia[,list(carat, cut, color, clarity, depth, table)]
    
    
    # Create a traindt training dataset and testdt testing dataset by using
    # the createDataPartition function from the caret package.
    # Change output of createDataPartition from matrix to vector.
    
    inTrain <- as.vector(createDataPartition(y = price, p = 0.9, list = FALSE))
    
    traindt <- preds[inTrain]
    testdt <- preds[-inTrain]

    # Similarly, partition the predicted variable price into training and test.
    
    trainPrice <- price[inTrain]
    testPrice <- price[-inTrain]
    
    # Autotuning mtry parameter using k-fold cross validation is taking
    # inordinately long for k = 10. Manually cross validated, and mtry = 6
    # gives > 90% accuracy in test set, so will run with it.
    
    fitCtl <- trainControl(method = "none", classProbs = TRUE)
    
    # Create a random forest based prediction model.

    fit <- train(trainPrice ~ ., data = traindt,
                 method = "rf",
                 trControl = fitCtl,
                 tuneGrid = data.frame(mtry = 6),    
                 verbose = FALSE )

    # Predict price for test data to get confusion matrix.
    
    predPrice <- predict(fit, newdata=testdt)
    confusionMatrix(predPrice, testPrice)
    tt <- data.table(predPrice, testPrice)
    
    return(fit)
}			

# ---  End function getModel() ----

# Function takes a model and a set of predictors and estimates price.

predictPrice <- function(fit, carat1, cut1, color1, clarity1, 
                         depth1, table1) {
    
    # The vectors for cut, color, and clarity.
    
    cutV <- c("Fair", "Good", "Very Good", "Premium", "Ideal")
    colorV <- c("J", "I", "H", "G", "F", "E", "D") 
    clarityV <- c("I1", "SI2", "SI1", "VS2", "VS1", "VVS2", "VVS1", "IF")
    
    # Convert the input parameters to numbers and then load datatable dt1.
    
    dt1 <- data.table(carat = as.numeric(carat1), 
                      cut = cutV[as.integer(cut1)], 
                      color = colorV[as.integer(color1)], 
                      clarity = clarityV[as.integer(clarity1)], 
                      depth = as.numeric(depth1), 
                      table = as.numeric(table1)
    )
    
    # Predict the price.
    
    predCd <- as.character(predict(fit, newdata= dt1))
    
    # Convert the price code to the explanatory text.
    
    prcRange[predCd][,txt]

} 		

# ---  End function predictPrice() ----


# --- End defining all the necessary functions ----


# --- Main code starts here ---------

# This code is nonreactive and is executed once at application start.

# First try to load model from file. 

if(file.exists("diamonds_rf.fit") ) {
    
    # Load model fit.
    
    load("diamonds_rf.fit")
    
}
    
# if fit model is still not available, create it. This may take a while.
    
if( ! exists("fit")) {
    fit <- getModel() 
}
    

# Reactive part of the code related to shiny server.

library(shiny)

shinyServer(function(input, output) {

    # Predict the price by calling predictPrice function.
    
    oPred <- reactive( {
        predictPrice(fit, input$carat, input$cut, 
                     input$color, input$clarity, input$depth, 
                     input$table)
    })
    
    # Display the predicted price.
    
    output$pred <- renderText({oPred()})
    
})
