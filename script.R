SLACalculator <- function() {
  
  library(lubridate)
  library(dplyr)
  
  locations <- c("metro manila", "luzon", "visayas", "mindanao")

  locationvector <- c(3, 5, 7, 7, 5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7)
  locationmatrix <- matrix(locationvector, nrow = 4, ncol = 4)

  holiday <- c(1, 8, 15, 22, 25, 29, 30, 31)
  
  classlist <- c("character", "numeric", "numeric", "numeric", "character", "character")
  data <- read.csv("delivery_orders_march.csv", colClasses = classlist, stringsAsFactors = FALSE)
  colnames(data) <- c("orderid", "pickup", "firstattempt", "secondattempt", "buyeraddress", "selleraddress")
  data$pickup <- day(as_datetime(data$pickup, tz="Asia/Manila"))
  data$firstattempt <- day(as_datetime(data$firstattempt, tz="Asia/Manila"))
  data$secondattempt <- day(as_datetime(data$secondattempt, tz="Asia/Manila"))
  data$buyeraddress <- tolower(data$buyeraddress)
  data$selleraddress <- tolower(data$selleraddress)
  
  firstattempt <- data$firstattempt
  secondattempt <- data$secondattempt
  buyeraddress <- data$buyeraddress
  selleraddress <- data$selleraddress
  
  for (i in 1:nrow(data)) {
    if (is.na(secondattempt[[i]])) {
      secondattempt[[i]] <- firstattempt[[i]]
    }
    for (j in 1:length(locations)) {
      if (grepl(paste0(locations[[j]], "$"), buyeraddress[[i]])) {
        buyeraddress[[i]] <- j  
      }
      if (grepl(paste0(locations[[j]], "$"), selleraddress[[i]])) {
        selleraddress[[i]] <- j  
      }
    }
  }
  
  data$secondattempt <- secondattempt
  data$buyeraddress <- as.numeric(buyeraddress)
  data$selleraddress <- as.numeric(selleraddress)  
  
  delivery <- data.frame(orderid = data$orderid, firstdelivery = c(0), seconddelivery = c(0), routeSLA = c(0))

  firstdelivery <- 0
  seconddelivery <- 0
  
  for (i in 1:nrow(delivery)) {
    first <- data$firstattempt[[i]]
    second <- data$secondattempt[[i]]
    pickup <- data$pickup[[i]]
    
    firstdelivery <- first - pickup
    seconddelivery <- second - first
    
    for (day in holiday) {
      if (day > pickup && day < first) {
        firstdelivery <- firstdelivery - 1
      }
      if (day > first && day < second) {
        seconddelivery <- seconddelivery - 1
      }
    }
    delivery$firstdelivery[[i]] <- firstdelivery
    delivery$seconddelivery[[i]] <- seconddelivery
    
    delivery$routeSLA[[i]] <- locationmatrix[data$selleraddress[[i]], data$buyeraddress[[i]]]
  }
  
  result <- data.frame(orderid = delivery$orderid, is_late = c(0))
  
  for (i in 1:nrow(result)) {
    if (delivery$firstdelivery[[i]] > delivery$routeSLA[[i]] || delivery$seconddelivery[[i]] > 3) {
      result$is_late[[i]] <- 1  
    }
  }
  
  write.csv(result, "submission.csv", row.names = FALSE, quote = FALSE)
  
  result

}