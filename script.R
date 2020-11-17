calculateSLA <- function() {
  
  library(lubridate)
  library(data.table)
  
  starttime <- now()
  zero <- paste("Starting!", starttime)
  
  print(zero)
  
  
  # Set up the basic conditions
  locations <- c("metro manila", "luzon", "visayas", "mindanao")
  locationSLA <- matrix(c(3, 5, 7, 7, 5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7), nrow = 4, ncol = 4)
  
  publicholiday <- c("8/3/2020", "25/3/2020", "30/3/2020", "31/3/2020")
  publicholiday <- dmy(publicholiday)
  
  # Read the data into R
  collist <- c("orderid", "pickup", "firstattempt", "secondattempt", "buyeraddress", "selleraddress")
  classlist <- c("character", "numeric", "numeric", "numeric", "character", "character")
  
  delivery <- fread("delivery_orders_march.csv", header = TRUE, sep = ",", col.names = collist, colClasses = classlist, strip.white = TRUE, stringsAsFactors = FALSE)
  
  # Clean the data
  delivery[, pickup := as_date(as_datetime(pickup, tz="Asia/Manila"))]
  delivery[, firstattempt := as_date(as_datetime(firstattempt, tz="Asia/Manila"))]
  delivery[, secondattempt := as_date(as_datetime(secondattempt, tz="Asia/Manila"))]
  delivery[, buyeraddress := tolower(buyeraddress)]
  delivery[, selleraddress := tolower(selleraddress)]
  
  # First Stage is about reading and cleaning data in preparation
  # (explained in comments in order to not modify the code)
  one <- paste("First Stage Done", now())
  
  print(one)
  
  
  # Find out all relevant holidays (including public holidays and Sundays)
  firstdate <- c(delivery[order(pickup), pickup][1], 
                 delivery[order(firstattempt), firstattempt][1],
                 delivery[order(secondattempt), secondattempt][1])
  
  lastdate <- c(delivery[order(-pickup), pickup][1],
                delivery[order(-firstattempt), firstattempt][1],
                delivery[order(-secondattempt), secondattempt][1])
  
  firstdate <- sort(firstdate)[1]
  lastdate <- sort(lastdate, decreasing = TRUE)[1]
  
  holidayall <- c(publicholiday)
  
  while(firstdate <= lastdate) {
    if (wday(firstdate) == 1) holidayall <- c(holidayall, firstdate)
    firstdate <- firstdate + days(1)
  }
  
  holidayall <- sort(unique(holidayall))
  
  # Code the addresses into location indexes
  for (locationindex in 1:length(locations)) {
    location <- locations[[locationindex]]
    delivery[, buyeraddress := fifelse(grepl(paste0(location, "$"), buyeraddress), as.character(locationindex), buyeraddress)]
    delivery[, selleraddress := fifelse(grepl(paste0(location, "$"), selleraddress), as.character(locationindex), selleraddress)]
  }
  
  # Convert the character columns into numeric columns
  delivery[, buyeraddress := as.numeric(buyeraddress)]
  delivery[, selleraddress := as.numeric(selleraddress)]  
  
  # Second Stage is about processing the data to make calculations easier after this
  # (explained in comments in order to not modify the code)
  two <- paste("Second Stage Done", now())
  
  print(two)
  
  
  # Calculate how long each delivery takes
  delivery[, ':=' (firstdelivery = firstattempt - pickup, 
                   seconddelivery = fifelse(is.na(secondattempt), as.difftime(0, units="days"), secondattempt - firstattempt))]
  
  # Adjust for holidays
  for (day in holidayall) {
    delivery[, ':=' (firstdelivery = fifelse(day >= pickup & day <= firstattempt, firstdelivery - as.difftime(1, units="days"), firstdelivery),
                     seconddelivery = fifelse(!is.na(secondattempt) & (day >= firstattempt & day <= secondattempt), seconddelivery - as.difftime(1, units="days"), seconddelivery))]
  }
  
  # Delete columns that are no longer needed
  delivery[, c("firstattempt", "secondattempt", "pickup") := NULL]
  
  # Convert the date columns into numeric columns
  delivery[, firstdelivery := as.numeric(firstdelivery)]
  delivery[, seconddelivery := as.numeric(seconddelivery)]  
  
  # Calculate the SLA for the route taken by each order
  delivery[, routeSLA := mapply(function(seller, buyer) {locationSLA[seller, buyer]}, selleraddress, buyeraddress)]
  
  # Calculate whether the delivery is late
  delivery[, is_late := fifelse(firstdelivery > routeSLA | seconddelivery > 3, 1, 0)]
  
  # Clean up the data.table to its final form
  delivery[, c("buyeraddress", "selleraddress", "firstdelivery", "seconddelivery", "routeSLA") := NULL]
  
  # Third Stage is about calculating and arranging the result to its final form
  # (explained in comments in order to not modify the code)
  three <- paste("Third Stage Done", now())
  
  print(three)
  
  
  # Write the result to csv file
  write.csv(delivery, "submission-final.csv", row.names = FALSE, quote = FALSE)
  
  print("Summary:")
  print(zero)
  print(one)
  print(two)
  print(three)
  
  finished <- paste("Finished!", now()) 
  print(finished)
  
  # The log file will contain information about the script's execution
  logfile <- file("SLACalculation.log", "a")
  logheading <- paste("Final Script -", nrow(delivery), "rows", "-", as.character(starttime))
  writeLines(c(logheading, zero, one, two, three, finished, ""), logfile)
  close(logfile)
  
  delivery
  
}