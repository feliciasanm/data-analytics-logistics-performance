# Code League 2020 - Logistics

Hi, this is my code for the fifth challenge in [Shopee Code League 2020](https://careers.shopee.sg/codeleague), which is Logistics (Performance), conducted on July 11, 2020. It was categorized under data analytics in the competition. The solution was written in R, using `lubridate` and `data.table` within the final code. Before discussing about the challenge itself and the code, a short background is in order.


## What is Shopee Code League (2020)?

Shopee Code League (2020) is a competition held by Shopee for coders around Asia region, to be exact Singapore, China, Indonesia, Malaysia, Philippines, Taiwan, Thailand, and Vietnam. The entire event was held between June 8 to August 8, consisting of eight main challenges and many workshops within the event. It was done completely online, usually using Kaggle as the platform, and it had two participation categories: Student and Open. I participated on the Open category, as one of my team members had already graduated. 

Logistics (Performance), which is discussed here, was the fifth of the eight main challenges in the competition. As I participated on the Open category, the one featured here will be the Open category's version.


## Logistics (Performance) Challenge

The objective of the challenge was to check whether orders were delivered late or not according to the Service Level Agreements (SLA) with the logistics providers. 

### Details of the Challenge

The orders all occurred in Philippines across various routes. The SLA can vary depending on the delivery routes, and the SLA was provided in an xlsx file. There were several tricky parts of the challenge:

1. The routes needed to be detected from seemingly user-provided buyer and seller address, which was bound to be rather messy as a result.

2. There were public holidays within the period of the provided data, which affected the calculation of the SLA.

3. The logistics providers could attempt delivery twice, which also affected the calculation of the SLA.

    If the delivery was successful on the first attempt, then the second attempt would be marked as NA. Both the first attempt and the second attempt would be bound by SLA, complicating the SLA calculation even further.
    
The calculation must take into consideration these factors, while being run on relatively large amount of data.

### Data

In this competition, the participants were given the SLA matrix in an xlsx file, which I encoded directly on the code. There were four locations involved, which were Metro Manila, Luzon, Visayas, and Mindanao, with 16 routes as a result of permutation. 

Furthermore, the main data consists of 3,176,313 rows, in a 721 MB (!) csv file, with six variables containing the necessary information to calculate whether the order had late delivery or not.

Column name     | Description
--------------- | -----------
`orderid`       | unique identifier of the order
`pickup`        | time of parcel pickup by the logistics provider, in epoch time GMT+8
`firstattempt`  | time of the first delivery attempt, in epoch time GMT+8
`secondattempt` | time of the second delivery attempt (if exists), in epoch time GMT+8, empty if it doesn't exist (NA when read by R)
`buyeraddress`  | address of the buyer, rather messy as it seems to be user-provided
`selleraddress` | address of the seller, rather messy as it seems to be user-provided

### Calculation

Given the SLA and various public holidays within the time period, we calculate whether orders are delivered late or not by the logistics providers.

### Objective

The objective of the challenge was to produce a csv file that labeled which orders are delivered on-time and which are late. The structure of the csv file was required to be as follows:

Column name | Description
----------- | -----------
`orderid`   | unique identifier of the order
`is_late`   | whether the order is late or not, 0 if not late, 1 if late


## Solution Code

The solution featured here is written in R. In my team, the R version was written by me, separate from other versions written by other team members. When I wrote the R code, the use of package was limited to `lubridate` and `dplyr`, with the final version using `data.table`, the rest written in base R (check my other repositories to see R code written using tidyverse). The entire solution code is encapsulated in a function named `calculateSLA` (or `SLACalculator` on the first iteration), which needs to be invoked to run the solution.

The competition was conducted until 4 pm, which was exactly when the working code was finished (without including the time needed to actually execute the code). The first code took a long time with the volume of data and included some shortcuts, so I took a few more days to write a complete and performant solution. These iterations are published here unmodified (other than possible additional comments) in code on this repository.

Several iterations are featured here in this repository. The original code took 2-3 hours to complete, getting around 0.88 out of 1 in Kaggle using late submission, while the final code took around 2 minutes, getting 1 out of 1 in Kaggle (a good chunk of the time is spent on reading the csv file into R). At least around 60 times speed up after using `data.table`! Note that I used the same Intel i7 laptop to run each iteration of the code. The

In addition to producing the result csv file, later iterations also outputted a calculation log that will look like this:

```
Final Script - 3176313 rows - 2020-07-14 16:50:31
Starting! 2020-07-14 16:50:31
First Stage Done 2020-07-14 16:51:20
Second Stage Done 2020-07-14 16:51:32
Third Stage Done 2020-07-14 16:51:42
Finished! 2020-07-14 16:51:49
```

## What I Learned From the Experience

I like this challenge a lot, as it had several tricks that I did not perceive at first (making it more fun!). Here are several things I learned from the challenge:

1. Thoroughly understand the profile of the problem and the data first

    While the overall step-by-step of the challenge did not seem too complicated for me compared to Challenge #1 ([featured in another repository](https://github.com/feliciasanm/data-analytics-order-brushing)), turned out the real difficulty with the challenge was the sheer time it took to calculate the result. If we did not use the right package (in this case I used `data.table` later), it will take forever and possibly more than the 3-hour duration of the competition to run the code itself. I should have suspected that something is amiss when the step-by-step seemed to be too straightforward!
    
2. Make it run, make it right, make it fast

    This expression absolutely resonates with me because of this experience. Because the time is so limited and I had to make space for the time to run the code (unsuccessfully), I was focused on getting the code running at first. Afterwards, I was concerned about how to get a 1/1 solution on the platform, so I scoured the forums to see what small ticks of the calculation were required to get the best solution. Around my last iteration, I converted the code from base R data frames to `data.table`, thus making it run fast.
  
3. It's a good idea to add some print statements

    When we have to process a large amount of data, it might be a good idea to add some print statements that will tell us when our code entered certain stages of the calculation. When I first ran my initial code, it took so long that I was worried that it accidentally ran into an infinite loop or it had some more obscure errors that did not pop up in initial development. It turned out that everything is okay, it's just that the code needed 3 hours to compute the result. I didn't know because my code didn't tell anything to its user until it is finished.  
      
    Therefore, on later iterations, I sprinkled print statements which told me which stage that the code was currently doing. Not only it reassured me that the code was doing okay, it also let me know exactly how long each stage and the entire calculation took, which was nice to watch as I made the code faster later :)
      
The challenges are quite exciting to do, and I look forward to join similar competitions in the future!

## To Do
* Adding comments to the code