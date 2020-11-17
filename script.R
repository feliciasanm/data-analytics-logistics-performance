calculateSLA <- function() {
  
  library(lubridate)
  
  zero <- paste("Starting!", now())
  
  print(zero)
  
  locations <- c("metro manila", "luzon", "visayas", "mindanao")
  locationSLA <- matrix(c(3, 5, 7, 7, 5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7), nrow = 4, ncol = 4)
  
  holiday <- c(1, 8, 15, 22, 25, 29, 30, 31)
  
  
  collist <- c("orderid", "pickup", "firstattempt", "secondattempt", "buyeraddress", "selleraddress")
  classlist <- c("character", "numeric", "numeric", "numeric", "character", "character")
  
  delivery <- read.csv("delivery_orders_march.csv", col.names = collist, colClasses = classlist, stringsAsFactors = FALSE)
  
  pickup <- day(as_datetime(delivery$pickup, tz="Asia/Manila"))
  firstattempt <- day(as_datetime(delivery$firstattempt, tz="Asia/Manila"))
  secondattempt <- day(as_datetime(delivery$secondattempt, tz="Asia/Manila"))
  buyeraddress <- tolower(delivery$buyeraddress)
  selleraddress <- tolower(delivery$selleraddress)
  
  one <- paste("First Stage Done", now())
  
  print(one)
  
  for (row in 1:nrow(delivery)) {
    
    for (locationindex in 1:length(locations)) {
      location <- locations[[locationindex]]
      if (grepl(paste0(location, "$"), buyeraddress[[row]])) {
        buyeraddress[[row]] <- locationindex  
      }
      if (grepl(paste0(location, "$"), selleraddress[[row]])) {
        selleraddress[[row]] <- locationindex  
      }
    }
    
  }
  
  buyeraddress <- as.numeric(buyeraddress)
  selleraddress <- as.numeric(selleraddress)  
  
  two <- paste("Second Stage Done", now())
  
  print(two)
  
  result <- data.frame(orderid = delivery$orderid, is_late = c(0))
  
  for (row in 1:nrow(result)) {
    
    first <- firstattempt[[row]]
    second <- secondattempt[[row]]
    pick <- pickup[[row]]
    
    firstdelivery <- first - pick
    seconddelivery <- if (is.na(second)) {
      0
    } else {
      second-first
    }
    
    for (day in holiday) {
      if (day > pick && day < first) {
        firstdelivery <- firstdelivery - 1
      }
      if (!is.na(second) && (day > first && day < second)) {
        seconddelivery <- seconddelivery - 1
      }
    }
    
    routeSLA <- locationSLA[selleraddress[[row]], buyeraddress[[row]]]
    
    if (firstdelivery > routeSLA || seconddelivery > 3) {
      result$is_late[[row]] <- 1  
    }
    
    print(row)
    
  }
  
  three <- paste("Third Stage Done", now())
  
  print(three)
  
  write.csv(result, "submission.csv", row.names = FALSE, quote = FALSE)
  
  print(one)
  print(two)
  print(three)
  print(paste("Finished!", now()))
  
  result
  
}