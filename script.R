calculateSLA <- function() {
  
  library(lubridate)
  library(data.table)
  
  starttime <- now()
  zero <- paste("Starting!", starttime)
  
  print(zero)
  
  
  # Set up the basic conditions
  locations <- c("metro manila", "luzon", "visayas", "mindanao")
  locationSLA <- matrix(c(3, 5, 7, 7, 5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7), nrow = 4, ncol = 4)
  
  holiday <- c(1, 8, 15, 22, 25, 29, 30, 31)
  
  # Read the data in
  collist <- c("orderid", "pickup", "firstattempt", "secondattempt", "buyeraddress", "selleraddress")
  classlist <- c("character", "numeric", "numeric", "numeric", "character", "character")
  
  delivery <- fread("delivery_orders_march.csv", header = TRUE, sep = ",", col.names = collist, colClasses = classlist, strip.white = TRUE, stringsAsFactors = FALSE)
  
  # Clean the data
  delivery[, pickup := day(as_datetime(pickup, tz="Asia/Manila"))]
  delivery[, firstattempt := day(as_datetime(firstattempt, tz="Asia/Manila"))]
  delivery[, secondattempt := day(as_datetime(secondattempt, tz="Asia/Manila"))]
  delivery[, buyeraddress := tolower(buyeraddress)]
  delivery[, selleraddress := tolower(selleraddress)]
  
  
  one <- paste("First Stage Done", now())
  
  print(one)
  
  
  # Code the addresses into location indexes
  for (locationindex in 1:length(locations)) {
    location <- locations[[locationindex]]
    delivery[, buyeraddress := fifelse(grepl(paste0(location, "$"), buyeraddress), as.character(locationindex), buyeraddress)]
    delivery[, selleraddress := fifelse(grepl(paste0(location, "$"), selleraddress), as.character(locationindex), selleraddress)]
  }
  
  # Convert the character columns into numeric columns
  delivery[, buyeraddress := as.numeric(buyeraddress)]
  delivery[, selleraddress := as.numeric(selleraddress)]  
  
  
  two <- paste("Second Stage Done", now())
  
  print(two)
  
  
  # Calculate how long each delivery takes
  delivery[, ':=' (firstdelivery = firstattempt - pickup, 
                   seconddelivery = fifelse(is.na(secondattempt), 0, secondattempt - firstattempt))]
  
  # Adjust for holidays
  for (day in holiday) {
    delivery[, ':=' (firstdelivery = fifelse(day > pickup & day < firstattempt, firstdelivery - 1, firstdelivery),
                     seconddelivery = fifelse(!is.na(secondattempt) & (day > firstattempt & day < secondattempt), seconddelivery - 1, seconddelivery))]
  }
  
  # Delete columns that are no longer needed
  delivery[, c("firstattempt", "secondattempt", "pickup") := NULL]
  
  # Calculate the SLA for the route taken by each order
  delivery[, routeSLA := mapply(function(seller, buyer) {locationSLA[seller, buyer]}, selleraddress, buyeraddress)]
  
  # Calculate whether the delivery is late
  delivery[, is_late := fifelse(firstdelivery > routeSLA | seconddelivery > 3, 1, 0)]
  
  # Clean up the data.table to its final form
  delivery[, c("buyeraddress", "selleraddress", "firstdelivery", "seconddelivery", "routeSLA") := NULL]
  
  three <- paste("Third Stage Done", now())
  
  print(three)
  
  
  # Write the result to csv file
  write.csv(delivery, "submission-updated.csv", row.names = FALSE, quote = FALSE)
  
  print("Summary:")
  print(zero)
  print(one)
  print(two)
  print(three)
  
  finished <- paste("Finished!", now()) 
  print(finished)
  
  logfile <- file("SLACalculation.log", "a")
  logheading <- paste("Updated Script -", nrow(delivery), "rows", "-", as.character(starttime))
  writeLines(c(logheading, zero, one, two, three, finished, ""), logfile)
  close(logfile)
  
  delivery
  
}