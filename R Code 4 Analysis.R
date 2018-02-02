Consistent with my approach, I initially planned to use the following control variables divided into 3 types to predict alumni median earnings after 10 years (MD_EARN_WNE_P10). 

--------------------------------------------------------------
Table 1:Control Variables Used to Predict Alumni Outcomes
---------------------------------------------------------------
Student characteristics                                                         | Type of College                                                | Location of College                   
--------------------------------------------------------------------------------|----------------------------------------------------------------|---------------------------------------
Enrollment of undergraduate students (UGDS)                                     |   Predominant undergraduate degree awarded (PREDDEG)           | City (CITY)
Share of enrolled students who are White (UGDS_WHITE)                           |   Number of Title IV students (NUM4__)                         | Region (REGION)
Share of enrolled students who are Black (UGDS_BLACK)                           |   Average cost of attendance (COSTT_4A)                        | Locale (LOCALE) 
Share of enrolled students who are Hispanic (UGDS_HISP)                         |   Control of institution (CONTROL)                             | 
Share of enrolled students who are Asian (UGDS_ASIAN)                           |   Percentage of degrees awarded in several stem fields (PCIP)  | 
Share of enrolled students who are non-resident aliens (UGDS_NRA)               |   Instructional expenditures per full-time equivalent student  |
Share of enrolled students who are Women (UGDS_WOMEN)                           |   Average faculty salary (AVGFACSAL)                           |
Average SAT score of admitted students (SAT_AVG_ALL)                            |   Average net price for Title IV institutions (NPT4__)         | 
Completion rate for first-time full-time students (C150_)                       |   Average net price for Title IV institutions(NPT4)            |
Share of undergraduates who are first-time full-time (PFTFTUG1_EF)              |   Number of Title IV students (NUM4)                           |
Share of students who received a federal loan while in school (LOAN_EVER)       |                                                                |
Share of students who received a pell grant while in school (PELL_EVER)         |                                                                |
Fraction of repayment cohort who are not in default, and with loan balances that have declined one year since entering repayment(RPY_IYR_RT)     |

More information on these variables can be found in the [Full Data documentation](https://collegescorecard.ed.gov/assets/FullDataDocumentation.pdf). The [Modified DataDictionary](https://github.com/DAboaba/An-Exploration-of-Value-Added-Methodology/blob/master/Modified%20DataDictionary.xlsx), should also be consulted to get a sense of what these variables are called in the dataset.

# Importation, Preparation, and Cleaning
## Importation
I was interested in exploring the mentioned issue for the 2012/2013 academic year because it appeared to be the year with the most data available. Thus, I needed to import [this](https://ed-public-download.app.cloud.gov/downloads/CollegeScorecard_Raw_Data.zip) dataset. 

Before beginning, install the follwing packages. 
```{r Set-up, message = FALSE, warning = FALSE, tidy = TRUE}
library(readr)   #Install the readr package
library(dplyr)   #Install the dplyr package
library(tidyr)   #Install the tidyr package
library(ggplot2) #Install the ggplot2 package
library(purrr) #Install the purrr package
```

To import the dataset;
```{r Main importation, message = FALSE, warning = FALSE, tidy = TRUE}
setwd("/Users/DMA/BOX\ STUFF/Columbia/Semester\ 2/Programming\ in\ R/Toolbox/CollegeScorecard_Raw_Data") #Set the working directory to wherever you have stored the downloaded data. 
CS2012_13 <- read_csv("MERGED2012_13_PP.csv") #Use the read_csv() function from the readr package to import the dataset into R.
```

## Preparation
### Preparation Part 1
After importing the dataset, three main issues became apparent. 

* The dataset contained far more variables than my question required.
  + This would have made it difficult to understand how to analyze the data. 
* Looking at the cohort map some of the variables I would like to include were included in the wrong dataset. For instance, some variables for 2012/2013 were put into the 2013/2014 dataset. 
  + This would have significantly limited the explanatory power of my analysis either because I had used past data, or I had used only a few variables.
* The dataset was missing some important variables, such as CONTROL.  
  + This would have significantly limited my ability to focus on subsets of the dataset that I believed were important. 

To address the issue of the large number of variables in the dataset, I removed variables I was not interested in studying. This step also partially addressed the second issue because I also took out variables that were incorrectly assigned to the 2012/2013 dataset rather than the 2011/2012 dataset. 
```{r Issue 1, message = FALSE, warning = FALSE, tidy = TRUE}
CS2012_13 <- select(CS2012_13, OPEID, OPEID6, INSTNM, MAIN, NUMBRANCH, CONTROL, REGION, SAT_AVG_ALL, AVGFACSAL, UGDS, UGDS_WHITE, UGDS_BLACK, UGDS_HISP, UGDS_ASIAN, UGDS_NRA, UGDS_WOMEN, PPTUG_EF, C150_4, C150_L4, PFTFTUG1_EF, RPY_1YR_RT, LOAN_EVER, PELL_EVER, MD_EARN_WNE_P10) #Dropped unnecessary variables
```

To finish addressing the second issue, and address the third issue, I imported the 2013/2014 and 2014/2015 datasets, kept the variables I was interested in and joined these datasets to the CS2012 dataset
```{r Issues 2 & 3, message = FALSE, warning = FALSE, tidy = TRUE}
setwd("/Users/DMA/BOX\ STUFF/Columbia/Semester\ 2/Programming\ in\ R/Toolbox/CollegeScorecard_Raw_Data") #Set the working directory to wherever you have stored the downloaded data. 

#Use the read_csv() function from the readr package to import the 2013/2014 and 2014/2015 datasets into R.
CS2013_14 <- read_csv("MERGED2013_14_PP.csv") 
CS2014_15 <- read_csv("MERGED2014_15_PP.csv")

#Dropped unnecessary variables from both datasets. 
CS2013_14 <- select(CS2013_14, OPEID, INSTNM, PREDDEG, TUITFTE, INEXPFTE, PCIP01, PCIP03, PCIP04, PCIP10, PCIP11, PCIP14, PCIP15, PCIP26, PCIP27, PCIP29, PCIP40, PCIP41, NPT4_PUB, NPT4_PRIV, NUM4_PUB, NUM4_PRIV, COSTT4_A, PCTPELL) 
CS2014_15 <- select(CS2014_15, OPEID, INSTNM, CURROPER, LOCALE, HBCU, PBI, ANNHI, TRIBAL, AANAPII, HSI, NANTI, MENONLY, WOMENONLY) 

#Joined the three datasets using the OPEID variable. Because only two can be joined at a time, joined the 2012/2013 datasets together then joined the result of that operation to the 2014/2015 dataset. 
CS2012 <- left_join(left_join(CS2012_13, CS2013_14, by = c("OPEID", "INSTNM")), CS2014_15, by = c("OPEID", "INSTNM")) 
"OPEID is the identification number used by the U.S. Department of Education to identify institutions. This is a an 8-digit number that distinguishes between institutions, branches, additional locations, and other entities that are part of the eligible institution"

#Remove extra datasets
rm(CS2012_13, CS2013_14, CS2014_15)
```


#### Preparation Part 2
The rationale behind importing data from the 2014/2015 dataset was to use several variables as a filter. In particular, I did not want to include colleges that were not currently operating. Additionally, colleges with multiple campuses posed a problem because it would needlessly complicate my research. Therefore, I removed these colleges and then removed the variables I had used for the filtering.
```{r Filtering out colleges,message = FALSE, warning = FALSE, tidy = TRUE}
CS2012 <- CS2012 %>% filter(CURROPER == 1, MAIN == 1, NUMBRANCH == 1) #Keep colleges that are currently operating and are main campuses with only one branch. 

CS2012 <- select(CS2012, -c(OPEID, OPEID6, MAIN, NUMBRANCH, CURROPER)) #Remove variables that were used to filter out institutions.
```

## Cleaning
### Cleaning Part 1
At this point the dataset has been adequately prepared. Consequently, I began to clean the dataset for final analysis. Several problems were obvious and I began working to address and mitigate these issues. 

The main issue that needed to be addressed was that the type of many of the variables was wrong. Because in the original dataset, missing data was recorded as "NULL", when the data was imported these variables were stored as character types. Thus, there were twp problems I had to address, incorrect types and NULL. At the same time, some of the variables I had were still not fully representative of what I wanted. 

In a previous project, I excluded any institutions without values for any of the variables I was interested in. However, this dramatically reduced the number of institutions in the dataset.  In another project, I decided to fill missing values with the median of that variable based on the CONTROL value of the institution .i.e. for institutions with a CONTROL value of 1 the median of this group was calculated and used to fill the value for institutuions with missing values for that group. However, that also biased the dataset. This time, I decided to use a more formal approach. 

First, I needed to convert all necessary columns to numeric. 
```{r Cleaning 1: Numeric Transformation, message = FALSE, warning = FALSE, tidy = TRUE}
#Convert all neccessary columns to numeric
##Some columns needed to be prepared beforehand

###The RPY_1YR_RT, LOAN_EVER, PELL_EVER, and MD_EARN_WNE variables had "PRIVACYSUPPRESSED" for some of the data. 
CS2012 <- CS2012 %>% filter(RPY_1YR_RT!="PrivacySuppressed", LOAN_EVER!="PrivacySuppressed", PELL_EVER!="PrivacySuppressed", MD_EARN_WNE_P10!="PrivacySuppressed") #filter out suppressed data

#Numeric Transformation
CS2012col <- CS2012 %>% select(-c(INSTNM, CONTROL, REGION)) #Create dataset with only columns for numeric transformation
CS2012col <- (map(CS2012col, as.numeric)) #Apply the as.numeric function over every column of the dataset
CS2012 <- cbind((CS2012 %>% select(INSTNM, CONTROL, REGION)), CS2012col) #Bind together the identifier columns and data columns and reassign to CS2012
CS2012 <- as_data_frame(CS2012) #To aid ease of manipulation converted the data frame into a tibble.
CS2012 <- unique(CS2012) #Deleting duplicated rows
```

I needed to combine the C150, NPT4, and NUM4 variables. They were separated based on the type of institution. If the institution was public it would have data for NPT4_PRIV but not for NPT4_PUB. I combine these variables below. I also excluded universities with 0 for any of these variables since that simply did not make sense. 
```{r Cleaning 2, message = FALSE, warning = FALSE, tidy = TRUE}
repmiss_combcol <- function (df, var1, var2, replacement) {
  df[[var1]][is.na(df[[var1]])] <- replacement
  df[[var2]][is.na(df[[var2]])] <- replacement
  df[[var1]] + df[[var2]]
}

#C150, NPT4, NUM4
CS2012[["C150"]] <- repmiss_combcol(df = CS2012, "C150_4", "C150_L4", replacement = 0)
CS2012[["NPT4"]] <- repmiss_combcol(df = CS2012, "NPT4_PRIV", "NPT4_PUB", replacement = 0)
CS2012[["NUM4"]] <- repmiss_combcol(df = CS2012, "NUM4_PRIV", "NUM4_PUB", replacement = 0)

CS2012 <- select(CS2012, -c(C150_L4, C150_4, NPT4_PUB, NPT4_PRIV, NUM4_PUB, NUM4_PRIV)) #Removing variables that are now unnecessary

# About 200 universities had very little data so they were removed. Will figure out what to do with them later
Excluded <- filter(CS2012, C150 == 0 | NPT4 == 0 | NUM4 == 0 | is.na(REGION))
CS2012 <- filter(CS2012, C150 != 0 | NPT4 != 0 | NUM4 != 0, !is.na(REGION))
```

The "PICPxy" variables, where x and y are numbers ranging from 0 to 9, represent the percentage of degrees an institution awarded in several STEM fields. These variables were taken from a larger list of degrees an institution awarded in several fields. I used this [STEM Degree list](http://stemdegreelist.com) to narrow down the variables. Because I was interested in the total percentage of degrees an institution awarded in STEM generally. I added up the percentages and created a new variable.
```{r Cleaning 4, message = FALSE, warning = FALSE, tidy = TRUE}
#Creating a new combination variable
CS2012 <- CS2012 %>% mutate(PCIPSTEM = PCIP01 + PCIP03 + PCIP04 + PCIP10 + PCIP11 + PCIP14 + PCIP15 + PCIP26 + PCIP27 + PCIP29 + PCIP40 + PCIP41)

#Removing the old variables
CS2012 <- select(CS2012, -c(PCIP01, PCIP03, PCIP04, PCIP10, PCIP11, PCIP14, PCIP15, PCIP26, PCIP27, PCIP29, PCIP40, PCIP41))
```


I am not interested in the specific mission of the school, just whether it serves minorities. I added up the dummy variables (HBCU, PBI, ANNHI, TRIBAL, AANAPII, HSI, NANTI, MENONLY, WOMENOLY) and created a new variable (MINORITY). 
```{r Cleaning 4b, message = FALSE, warning = FALSE, tidy = TRUE}
#Creating a new combination variable
CS2012 <- CS2012 %>% mutate(MINORITY = HBCU + PBI + ANNHI + TRIBAL + AANAPII + HSI + NANTI + MENONLY + WOMENONLY)

#Removing the old variables
CS2012 <- select(CS2012, -c(HBCU, PBI, ANNHI, TRIBAL, AANAPII, HSI, NANTI, MENONLY, WOMENONLY))
```

After this, I filled missing data using a Formal Imputation Methodology.
```{r Formal Imputation Methodology: Recoding, message = FALSE, warning = FALSE, tidy = TRUE}
#Gelman argues that  a good approach for situations like this (where multiple variables have missing values) is to fit a regression to the observed cases and then use that to predict the missing cases. However, if we were to use the resulting deterministic imputations, we would be falsely implying that most of these nonrespondents had values in the middle of the range. To fix this we can add the prediction error into the regression to put the uncertainty back into the imputations. Several variables had no missing values MINORITY, NUM4, NPT4, C150, LOCALE, PREDDEG, REGION, CONTROL, INSTNM

#With the exception of INSTNM, these variables were used to predict the following variables. As each variable was predicted and completed, it was added to the regression to help predict the next variable. I imputed values for those with the least amount of missing values first. Thus, the variables with the most amount of missing values were predicted using the most data available at that point. 

#The dataset was filled based on the group to which the institution belonged. To make this simple, I first split the data into 3 groups based on CONTROL for Interpolation.
CS2012C1 <- CS2012 %>% filter(CONTROL == 1)
CS2012C2 <- CS2012 %>% filter(CONTROL == 2)
CS2012C3 <- CS2012 %>% filter(CONTROL == 3)
```


```{r Formal Imputation C1: Recoding, message = FALSE, warning = FALSE, tidy = TRUE}
attach(CS2012C1) #Attaching the dataset so we can easily call on variables

impute <- function(a, a.impute){
  ifelse(is.na(a), a.impute, a)
}

#For TUITFTE
lm.imp.TUITFTE <- lm(TUITFTE ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY, data = CS2012C1)
pred.TUITFTE <- rnorm(1, predict(lm.imp.TUITFTE, CS2012C1), sigma(lm.imp.TUITFTE)) #where the number of missing observations is the first number
TUITFTE.imp <- impute(TUITFTE, pred.TUITFTE)
CS2012C1$TUITFTE <- TUITFTE.imp

#For INEXPFTE
lm.imp.INEXPFTE <- lm(INEXPFTE ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE, data = CS2012C1)
pred.INEXPFTE <- rnorm(1, predict(lm.imp.INEXPFTE, CS2012C1), sigma(lm.imp.INEXPFTE)) 
INEXPFTE.imp <- impute(INEXPFTE, pred.INEXPFTE)
CS2012C1$INEXPFTE <- INEXPFTE.imp

#For PELL_EVER
lm.imp.PELL_EVER <- lm(PELL_EVER ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE, data = CS2012C1)
pred.PELL_EVER <- rnorm(1, predict(lm.imp.PELL_EVER, CS2012C1), sigma(lm.imp.PELL_EVER))
PELL_EVER.imp <- impute(PELL_EVER, pred.PELL_EVER)
CS2012C1$PELL_EVER <- PELL_EVER.imp

#For LOAN_EVER
lm.imp.LOAN_EVER <- lm(LOAN_EVER ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER, data = CS2012C1)
pred.LOAN_EVER <- rnorm(1, predict(lm.imp.LOAN_EVER, CS2012C1), sigma(lm.imp.LOAN_EVER))
LOAN_EVER.imp <- impute(LOAN_EVER, pred.LOAN_EVER)
CS2012C1$LOAN_EVER <- LOAN_EVER.imp

#For UGDS
lm.imp.UGDS <- lm(UGDS ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER, data = CS2012C1)
pred.UGDS <- rnorm(3, predict(lm.imp.UGDS, CS2012C1), sigma(lm.imp.UGDS))
UGDS.imp <- impute(UGDS, pred.UGDS)
CS2012C1$UGDS <- UGDS.imp

#For UGDS_ASIAN
lm.imp.UGDS_ASIAN <- lm(UGDS_ASIAN ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS, data = CS2012C1)
pred.UGDS_ASIAN <- rnorm(3, predict(lm.imp.UGDS_ASIAN, CS2012C1), sigma(lm.imp.UGDS_ASIAN))
UGDS_ASIAN.imp <- impute(UGDS_ASIAN, pred.UGDS_ASIAN)
CS2012C1$UGDS_ASIAN <- UGDS_ASIAN.imp

#For UGDS_BLACK
lm.imp.UGDS_BLACK <- lm(UGDS_BLACK ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN, data = CS2012C1)
pred.UGDS_BLACK <- rnorm(3, predict(lm.imp.UGDS_BLACK, CS2012C1), sigma(lm.imp.UGDS_BLACK))
UGDS_BLACK.imp <- impute(UGDS_BLACK, pred.UGDS_BLACK)
CS2012C1$UGDS_BLACK <- UGDS_BLACK.imp

#For UGDS_HISP
lm.imp.UGDS_HISP <- lm(UGDS_HISP ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK, data = CS2012C1)
pred.UGDS_HISP <- rnorm(3, predict(lm.imp.UGDS_HISP, CS2012C1), sigma(lm.imp.UGDS_HISP))
UGDS_HISP.imp <- impute(UGDS_HISP, pred.UGDS_HISP)
CS2012C1$UGDS_HISP <- UGDS_HISP.imp

#For UGDS_NRA
lm.imp.UGDS_NRA <- lm(UGDS_NRA ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP, data = CS2012C1)
pred.UGDS_NRA <- rnorm(3, predict(lm.imp.UGDS_NRA, CS2012C1), sigma(lm.imp.UGDS_NRA))
UGDS_NRA.imp <- impute(UGDS_NRA, pred.UGDS_NRA)
CS2012C1$UGDS_NRA <- UGDS_NRA.imp

#For UGDS_WHITE
lm.imp.UGDS_WHITE <- lm(UGDS_WHITE ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA, data = CS2012C1)
pred.UGDS_WHITE <- rnorm(3, predict(lm.imp.UGDS_WHITE, CS2012C1), sigma(lm.imp.UGDS_WHITE))
UGDS_WHITE.imp <- impute(UGDS_WHITE, pred.UGDS_WHITE)
CS2012C1$UGDS_WHITE <- UGDS_WHITE.imp

#For UGDS_WOMEN
lm.imp.UGDS_WOMEN <- lm(UGDS_WOMEN ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE, data = CS2012C1)
pred.UGDS_WOMEN <- rnorm(3, predict(lm.imp.UGDS_WOMEN, CS2012C1), sigma(lm.imp.UGDS_WOMEN))
UGDS_WOMEN.imp <- impute(UGDS_WOMEN, pred.UGDS_WOMEN)
CS2012C1$UGDS_WOMEN <- UGDS_WOMEN.imp

#For PCIPSTEM
lm.imp.PCIPSTEM <- lm(PCIPSTEM ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN, data = CS2012C1)
pred.PCIPSTEM <- rnorm(3, predict(lm.imp.PCIPSTEM, CS2012C1), sigma(lm.imp.PCIPSTEM))
PCIPSTEM.imp <- impute(PCIPSTEM, pred.PCIPSTEM)
CS2012C1$PCIPSTEM <- PCIPSTEM.imp

#For PPTUG_EF
lm.imp.PPTUG_EF <- lm(PPTUG_EF ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM, data = CS2012C1)
pred.PPTUG_EF <- rnorm(3, predict(lm.imp.PPTUG_EF, CS2012C1), sigma(lm.imp.PPTUG_EF))
PPTUG_EF.imp <- impute(PPTUG_EF, pred.PPTUG_EF)
CS2012C1$PPTUG_EF <- PPTUG_EF.imp

#For PCTPELL
lm.imp.PCTPELL <- lm(PCTPELL ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF, data = CS2012)
pred.PCTPELL <- rnorm(4, predict(lm.imp.PCTPELL, CS2012C1), sigma(lm.imp.PCTPELL))
PCTPELL.imp <- impute(PCTPELL, pred.PCTPELL)
CS2012C1$PCTPELL <- PCTPELL.imp

#For RPY_1YR_RT
lm.imp.RPY_1YR_RT <- lm(RPY_1YR_RT ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL, data = CS2012C1)
pred.RPY_1YR_RT <- rnorm(22, predict(lm.imp.RPY_1YR_RT, CS2012C1), sigma(lm.imp.RPY_1YR_RT))
RPY_1YR_RT.imp <- impute(RPY_1YR_RT, pred.RPY_1YR_RT)
CS2012C1$RPY_1YR_RT <- RPY_1YR_RT.imp

#For AVGFACSAL*3 missing
lm.imp.AVGFACSAL <- lm(AVGFACSAL ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL + RPY_1YR_RT, data = CS2012C1)
pred.AVGFACSAL <- rnorm(483, predict(lm.imp.AVGFACSAL, CS2012C1), sigma(lm.imp.AVGFACSAL))
AVGFACSAL.imp <- impute(AVGFACSAL, pred.AVGFACSAL)
CS2012C1$AVGFACSAL <- AVGFACSAL.imp

#For COSTT4_A*89
lm.imp.COSTT4_A <- lm(COSTT4_A ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL + RPY_1YR_RT + AVGFACSAL, data = CS2012C1)
pred.COSTT4_A <- rnorm(511, predict(lm.imp.COSTT4_A, CS2012C1), sigma(lm.imp.COSTT4_A))
COSTT4_A.imp <- impute(COSTT4_A, pred.COSTT4_A)
CS2012C1$COSTT4_A <- COSTT4_A.imp

#For PFTFTUG1_EF
lm.imp.PFTFTUG1_EF <- lm(PFTFTUG1_EF ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL + RPY_1YR_RT + AVGFACSAL + COSTT4_A, data = CS2012C1)
pred.PFTFTUG1_EF <- rnorm(566, predict(lm.imp.PFTFTUG1_EF, CS2012C1), sigma(lm.imp.PFTFTUG1_EF))
PFTFTUG1_EF.imp <- impute(PFTFTUG1_EF, pred.PFTFTUG1_EF)
CS2012C1$PFTFTUG1_EF <- PFTFTUG1_EF.imp

#For SAT_AVG_ALL
lm.imp.SAT_AVG_ALL <- lm(SAT_AVG_ALL ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL + RPY_1YR_RT + AVGFACSAL + COSTT4_A + PFTFTUG1_EF, data = CS2012C1)
pred.SAT_AVG_ALL <- rnorm(1644, predict(lm.imp.SAT_AVG_ALL, CS2012C1), sigma(lm.imp.SAT_AVG_ALL))
SAT_AVG_ALL.imp <- impute(SAT_AVG_ALL, pred.SAT_AVG_ALL)
CS2012C1$SAT_AVG_ALL <- SAT_AVG_ALL.imp

#For MD_EARN_WNE_P10
lm.imp.MD_EARN_WNE_P10 <- lm(MD_EARN_WNE_P10 ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL + RPY_1YR_RT + AVGFACSAL + COSTT4_A + PFTFTUG1_EF + SAT_AVG_ALL, data = CS2012C1)
pred.MD_EARN_WNE_P10 <- rnorm(161, predict(lm.imp.MD_EARN_WNE_P10, CS2012C1), sigma(lm.imp.MD_EARN_WNE_P10))
MD_EARN_WNE_P10.imp <- impute(MD_EARN_WNE_P10, pred.MD_EARN_WNE_P10)
CS2012C1$MD_EARN_WNE_P10 <- MD_EARN_WNE_P10.imp
```


```{r Formal Imputation C2: Recoding, message = FALSE, warning = FALSE, tidy = TRUE}
attach(CS2012C2) #Attaching the dataset so we can easily call on variables

impute <- function(a, a.impute){
  ifelse(is.na(a), a.impute, a)
}

#For TUITFTE
lm.imp.TUITFTE <- lm(TUITFTE ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY, data = CS2012C2)
pred.TUITFTE <- rnorm(1, predict(lm.imp.TUITFTE, CS2012C2), sigma(lm.imp.TUITFTE)) #where the number of missing observations is the first number
TUITFTE.imp <- impute(TUITFTE, pred.TUITFTE)
CS2012C2$TUITFTE <- TUITFTE.imp

#For INEXPFTE
lm.imp.INEXPFTE <- lm(INEXPFTE ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE, data = CS2012C2)
pred.INEXPFTE <- rnorm(1, predict(lm.imp.INEXPFTE, CS2012C2), sigma(lm.imp.INEXPFTE)) 
INEXPFTE.imp <- impute(INEXPFTE, pred.INEXPFTE)
CS2012C2$INEXPFTE <- INEXPFTE.imp

#For PELL_EVER
lm.imp.PELL_EVER <- lm(PELL_EVER ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE, data = CS2012C2)
pred.PELL_EVER <- rnorm(1, predict(lm.imp.PELL_EVER, CS2012C2), sigma(lm.imp.PELL_EVER))
PELL_EVER.imp <- impute(PELL_EVER, pred.PELL_EVER)
CS2012C2$PELL_EVER <- PELL_EVER.imp

#For LOAN_EVER
lm.imp.LOAN_EVER <- lm(LOAN_EVER ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER, data = CS2012C2)
pred.LOAN_EVER <- rnorm(1, predict(lm.imp.LOAN_EVER, CS2012C2), sigma(lm.imp.LOAN_EVER))
LOAN_EVER.imp <- impute(LOAN_EVER, pred.LOAN_EVER)
CS2012C2$LOAN_EVER <- LOAN_EVER.imp

#For UGDS
lm.imp.UGDS <- lm(UGDS ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER, data = CS2012C2)
pred.UGDS <- rnorm(3, predict(lm.imp.UGDS, CS2012C2), sigma(lm.imp.UGDS))
UGDS.imp <- impute(UGDS, pred.UGDS)
CS2012C2$UGDS <- UGDS.imp

#For UGDS_ASIAN
lm.imp.UGDS_ASIAN <- lm(UGDS_ASIAN ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS, data = CS2012C2)
pred.UGDS_ASIAN <- rnorm(3, predict(lm.imp.UGDS_ASIAN, CS2012C2), sigma(lm.imp.UGDS_ASIAN))
UGDS_ASIAN.imp <- impute(UGDS_ASIAN, pred.UGDS_ASIAN)
CS2012C2$UGDS_ASIAN <- UGDS_ASIAN.imp

#For UGDS_BLACK
lm.imp.UGDS_BLACK <- lm(UGDS_BLACK ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN, data = CS2012C2)
pred.UGDS_BLACK <- rnorm(3, predict(lm.imp.UGDS_BLACK, CS2012C2), sigma(lm.imp.UGDS_BLACK))
UGDS_BLACK.imp <- impute(UGDS_BLACK, pred.UGDS_BLACK)
CS2012C2$UGDS_BLACK <- UGDS_BLACK.imp

#For UGDS_HISP
lm.imp.UGDS_HISP <- lm(UGDS_HISP ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK, data = CS2012C2)
pred.UGDS_HISP <- rnorm(3, predict(lm.imp.UGDS_HISP, CS2012C2), sigma(lm.imp.UGDS_HISP))
UGDS_HISP.imp <- impute(UGDS_HISP, pred.UGDS_HISP)
CS2012C2$UGDS_HISP <- UGDS_HISP.imp

#For UGDS_NRA
lm.imp.UGDS_NRA <- lm(UGDS_NRA ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP, data = CS2012C2)
pred.UGDS_NRA <- rnorm(3, predict(lm.imp.UGDS_NRA, CS2012C2), sigma(lm.imp.UGDS_NRA))
UGDS_NRA.imp <- impute(UGDS_NRA, pred.UGDS_NRA)
CS2012C2$UGDS_NRA <- UGDS_NRA.imp

#For UGDS_WHITE
lm.imp.UGDS_WHITE <- lm(UGDS_WHITE ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA, data = CS2012C2)
pred.UGDS_WHITE <- rnorm(3, predict(lm.imp.UGDS_WHITE, CS2012C2), sigma(lm.imp.UGDS_WHITE))
UGDS_WHITE.imp <- impute(UGDS_WHITE, pred.UGDS_WHITE)
CS2012C2$UGDS_WHITE <- UGDS_WHITE.imp

#For UGDS_WOMEN
lm.imp.UGDS_WOMEN <- lm(UGDS_WOMEN ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE, data = CS2012C2)
pred.UGDS_WOMEN <- rnorm(3, predict(lm.imp.UGDS_WOMEN, CS2012C2), sigma(lm.imp.UGDS_WOMEN))
UGDS_WOMEN.imp <- impute(UGDS_WOMEN, pred.UGDS_WOMEN)
CS2012C2$UGDS_WOMEN <- UGDS_WOMEN.imp

#For PCIPSTEM
lm.imp.PCIPSTEM <- lm(PCIPSTEM ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN, data = CS2012C2)
pred.PCIPSTEM <- rnorm(3, predict(lm.imp.PCIPSTEM, CS2012C2), sigma(lm.imp.PCIPSTEM))
PCIPSTEM.imp <- impute(PCIPSTEM, pred.PCIPSTEM)
CS2012C2$PCIPSTEM <- PCIPSTEM.imp

#For PPTUG_EF
lm.imp.PPTUG_EF <- lm(PPTUG_EF ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM, data = CS2012C2)
pred.PPTUG_EF <- rnorm(3, predict(lm.imp.PPTUG_EF, CS2012C2), sigma(lm.imp.PPTUG_EF))
PPTUG_EF.imp <- impute(PPTUG_EF, pred.PPTUG_EF)
CS2012C2$PPTUG_EF <- PPTUG_EF.imp

#For PCTPELL
lm.imp.PCTPELL <- lm(PCTPELL ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF, data = CS2012)
pred.PCTPELL <- rnorm(4, predict(lm.imp.PCTPELL, CS2012C2), sigma(lm.imp.PCTPELL))
PCTPELL.imp <- impute(PCTPELL, pred.PCTPELL)
CS2012C2$PCTPELL <- PCTPELL.imp

#For RPY_1YR_RT
lm.imp.RPY_1YR_RT <- lm(RPY_1YR_RT ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL, data = CS2012C2)
pred.RPY_1YR_RT <- rnorm(22, predict(lm.imp.RPY_1YR_RT, CS2012C2), sigma(lm.imp.RPY_1YR_RT))
RPY_1YR_RT.imp <- impute(RPY_1YR_RT, pred.RPY_1YR_RT)
CS2012C2$RPY_1YR_RT <- RPY_1YR_RT.imp

#For AVGFACSAL*3 missing
lm.imp.AVGFACSAL <- lm(AVGFACSAL ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL + RPY_1YR_RT, data = CS2012C2)
pred.AVGFACSAL <- rnorm(483, predict(lm.imp.AVGFACSAL, CS2012C2), sigma(lm.imp.AVGFACSAL))
AVGFACSAL.imp <- impute(AVGFACSAL, pred.AVGFACSAL)
CS2012C2$AVGFACSAL <- AVGFACSAL.imp

#For COSTT4_A*89
lm.imp.COSTT4_A <- lm(COSTT4_A ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL + RPY_1YR_RT + AVGFACSAL, data = CS2012C2)
pred.COSTT4_A <- rnorm(511, predict(lm.imp.COSTT4_A, CS2012C2), sigma(lm.imp.COSTT4_A))
COSTT4_A.imp <- impute(COSTT4_A, pred.COSTT4_A)
CS2012C2$COSTT4_A <- COSTT4_A.imp

#For PFTFTUG1_EF
lm.imp.PFTFTUG1_EF <- lm(PFTFTUG1_EF ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL + RPY_1YR_RT + AVGFACSAL + COSTT4_A, data = CS2012C2)
pred.PFTFTUG1_EF <- rnorm(566, predict(lm.imp.PFTFTUG1_EF, CS2012C2), sigma(lm.imp.PFTFTUG1_EF))
PFTFTUG1_EF.imp <- impute(PFTFTUG1_EF, pred.PFTFTUG1_EF)
CS2012C2$PFTFTUG1_EF <- PFTFTUG1_EF.imp

#For SAT_AVG_ALL
lm.imp.SAT_AVG_ALL <- lm(SAT_AVG_ALL ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL + RPY_1YR_RT + AVGFACSAL + COSTT4_A + PFTFTUG1_EF, data = CS2012C2)
pred.SAT_AVG_ALL <- rnorm(1644, predict(lm.imp.SAT_AVG_ALL, CS2012C2), sigma(lm.imp.SAT_AVG_ALL))
SAT_AVG_ALL.imp <- impute(SAT_AVG_ALL, pred.SAT_AVG_ALL)
CS2012C2$SAT_AVG_ALL <- SAT_AVG_ALL.imp

#For MD_EARN_WNE_P10
lm.imp.MD_EARN_WNE_P10 <- lm(MD_EARN_WNE_P10 ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL + RPY_1YR_RT + AVGFACSAL + COSTT4_A + PFTFTUG1_EF + SAT_AVG_ALL, data = CS2012C2)
pred.MD_EARN_WNE_P10 <- rnorm(161, predict(lm.imp.MD_EARN_WNE_P10, CS2012C2), sigma(lm.imp.MD_EARN_WNE_P10))
MD_EARN_WNE_P10.imp <- impute(MD_EARN_WNE_P10, pred.MD_EARN_WNE_P10)
CS2012C2$MD_EARN_WNE_P10 <- MD_EARN_WNE_P10.imp
```


```{r Formal Imputation C3: Recoding, message = FALSE, warning = FALSE, tidy = TRUE}
attach(CS2012C3) #Attaching the dataset so we can easily call on variables

impute <- function(a, a.impute){
  ifelse(is.na(a), a.impute, a)
}

#For TUITFTE
lm.imp.TUITFTE <- lm(TUITFTE ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY, data = CS2012C3)
pred.TUITFTE <- rnorm(1, predict(lm.imp.TUITFTE, CS2012C3), sigma(lm.imp.TUITFTE)) #where the number of missing observations is the first number
TUITFTE.imp <- impute(TUITFTE, pred.TUITFTE)
CS2012C3$TUITFTE <- TUITFTE.imp

#For INEXPFTE
lm.imp.INEXPFTE <- lm(INEXPFTE ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE, data = CS2012C3)
pred.INEXPFTE <- rnorm(1, predict(lm.imp.INEXPFTE, CS2012C3), sigma(lm.imp.INEXPFTE)) 
INEXPFTE.imp <- impute(INEXPFTE, pred.INEXPFTE)
CS2012C3$INEXPFTE <- INEXPFTE.imp

#For PELL_EVER
lm.imp.PELL_EVER <- lm(PELL_EVER ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE, data = CS2012C3)
pred.PELL_EVER <- rnorm(1, predict(lm.imp.PELL_EVER, CS2012C3), sigma(lm.imp.PELL_EVER))
PELL_EVER.imp <- impute(PELL_EVER, pred.PELL_EVER)
CS2012C3$PELL_EVER <- PELL_EVER.imp

#For LOAN_EVER
lm.imp.LOAN_EVER <- lm(LOAN_EVER ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER, data = CS2012C3)
pred.LOAN_EVER <- rnorm(1, predict(lm.imp.LOAN_EVER, CS2012C3), sigma(lm.imp.LOAN_EVER))
LOAN_EVER.imp <- impute(LOAN_EVER, pred.LOAN_EVER)
CS2012C3$LOAN_EVER <- LOAN_EVER.imp

#For UGDS
lm.imp.UGDS <- lm(UGDS ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER, data = CS2012C3)
pred.UGDS <- rnorm(3, predict(lm.imp.UGDS, CS2012C3), sigma(lm.imp.UGDS))
UGDS.imp <- impute(UGDS, pred.UGDS)
CS2012C3$UGDS <- UGDS.imp

#For UGDS_ASIAN
lm.imp.UGDS_ASIAN <- lm(UGDS_ASIAN ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS, data = CS2012C3)
pred.UGDS_ASIAN <- rnorm(3, predict(lm.imp.UGDS_ASIAN, CS2012C3), sigma(lm.imp.UGDS_ASIAN))
UGDS_ASIAN.imp <- impute(UGDS_ASIAN, pred.UGDS_ASIAN)
CS2012C3$UGDS_ASIAN <- UGDS_ASIAN.imp

#For UGDS_BLACK
lm.imp.UGDS_BLACK <- lm(UGDS_BLACK ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN, data = CS2012C3)
pred.UGDS_BLACK <- rnorm(3, predict(lm.imp.UGDS_BLACK, CS2012C3), sigma(lm.imp.UGDS_BLACK))
UGDS_BLACK.imp <- impute(UGDS_BLACK, pred.UGDS_BLACK)
CS2012C3$UGDS_BLACK <- UGDS_BLACK.imp

#For UGDS_HISP
lm.imp.UGDS_HISP <- lm(UGDS_HISP ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK, data = CS2012C3)
pred.UGDS_HISP <- rnorm(3, predict(lm.imp.UGDS_HISP, CS2012C3), sigma(lm.imp.UGDS_HISP))
UGDS_HISP.imp <- impute(UGDS_HISP, pred.UGDS_HISP)
CS2012C3$UGDS_HISP <- UGDS_HISP.imp

#For UGDS_NRA
lm.imp.UGDS_NRA <- lm(UGDS_NRA ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP, data = CS2012C3)
pred.UGDS_NRA <- rnorm(3, predict(lm.imp.UGDS_NRA, CS2012C3), sigma(lm.imp.UGDS_NRA))
UGDS_NRA.imp <- impute(UGDS_NRA, pred.UGDS_NRA)
CS2012C3$UGDS_NRA <- UGDS_NRA.imp

#For UGDS_WHITE
lm.imp.UGDS_WHITE <- lm(UGDS_WHITE ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA, data = CS2012C3)
pred.UGDS_WHITE <- rnorm(3, predict(lm.imp.UGDS_WHITE, CS2012C3), sigma(lm.imp.UGDS_WHITE))
UGDS_WHITE.imp <- impute(UGDS_WHITE, pred.UGDS_WHITE)
CS2012C3$UGDS_WHITE <- UGDS_WHITE.imp

#For UGDS_WOMEN
lm.imp.UGDS_WOMEN <- lm(UGDS_WOMEN ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE, data = CS2012C3)
pred.UGDS_WOMEN <- rnorm(3, predict(lm.imp.UGDS_WOMEN, CS2012C3), sigma(lm.imp.UGDS_WOMEN))
UGDS_WOMEN.imp <- impute(UGDS_WOMEN, pred.UGDS_WOMEN)
CS2012C3$UGDS_WOMEN <- UGDS_WOMEN.imp

#For PCIPSTEM
lm.imp.PCIPSTEM <- lm(PCIPSTEM ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN, data = CS2012C3)
pred.PCIPSTEM <- rnorm(3, predict(lm.imp.PCIPSTEM, CS2012C3), sigma(lm.imp.PCIPSTEM))
PCIPSTEM.imp <- impute(PCIPSTEM, pred.PCIPSTEM)
CS2012C3$PCIPSTEM <- PCIPSTEM.imp

#For PPTUG_EF
lm.imp.PPTUG_EF <- lm(PPTUG_EF ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM, data = CS2012C3)
pred.PPTUG_EF <- rnorm(3, predict(lm.imp.PPTUG_EF, CS2012C3), sigma(lm.imp.PPTUG_EF))
PPTUG_EF.imp <- impute(PPTUG_EF, pred.PPTUG_EF)
CS2012C3$PPTUG_EF <- PPTUG_EF.imp

#For PCTPELL
lm.imp.PCTPELL <- lm(PCTPELL ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF, data = CS2012)
pred.PCTPELL <- rnorm(4, predict(lm.imp.PCTPELL, CS2012C3), sigma(lm.imp.PCTPELL))
PCTPELL.imp <- impute(PCTPELL, pred.PCTPELL)
CS2012C3$PCTPELL <- PCTPELL.imp

#For RPY_1YR_RT
lm.imp.RPY_1YR_RT <- lm(RPY_1YR_RT ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL, data = CS2012C3)
pred.RPY_1YR_RT <- rnorm(22, predict(lm.imp.RPY_1YR_RT, CS2012C3), sigma(lm.imp.RPY_1YR_RT))
RPY_1YR_RT.imp <- impute(RPY_1YR_RT, pred.RPY_1YR_RT)
CS2012C3$RPY_1YR_RT <- RPY_1YR_RT.imp

#For AVGFACSAL*3 missing
lm.imp.AVGFACSAL <- lm(AVGFACSAL ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL + RPY_1YR_RT, data = CS2012C3)
pred.AVGFACSAL <- rnorm(483, predict(lm.imp.AVGFACSAL, CS2012C3), sigma(lm.imp.AVGFACSAL))
AVGFACSAL.imp <- impute(AVGFACSAL, pred.AVGFACSAL)
CS2012C3$AVGFACSAL <- AVGFACSAL.imp

#For COSTT4_A*89
lm.imp.COSTT4_A <- lm(COSTT4_A ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL + RPY_1YR_RT + AVGFACSAL, data = CS2012C3)
pred.COSTT4_A <- rnorm(511, predict(lm.imp.COSTT4_A, CS2012C3), sigma(lm.imp.COSTT4_A))
COSTT4_A.imp <- impute(COSTT4_A, pred.COSTT4_A)
CS2012C3$COSTT4_A <- COSTT4_A.imp

#For PFTFTUG1_EF
lm.imp.PFTFTUG1_EF <- lm(PFTFTUG1_EF ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL + RPY_1YR_RT + AVGFACSAL + COSTT4_A, data = CS2012C3)
pred.PFTFTUG1_EF <- rnorm(566, predict(lm.imp.PFTFTUG1_EF, CS2012C3), sigma(lm.imp.PFTFTUG1_EF))
PFTFTUG1_EF.imp <- impute(PFTFTUG1_EF, pred.PFTFTUG1_EF)
CS2012C3$PFTFTUG1_EF <- PFTFTUG1_EF.imp

#For SAT_AVG_ALL
lm.imp.SAT_AVG_ALL <- lm(SAT_AVG_ALL ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL + RPY_1YR_RT + AVGFACSAL + COSTT4_A + PFTFTUG1_EF, data = CS2012C3)
pred.SAT_AVG_ALL <- rnorm(1644, predict(lm.imp.SAT_AVG_ALL, CS2012C3), sigma(lm.imp.SAT_AVG_ALL))
SAT_AVG_ALL.imp <- impute(SAT_AVG_ALL, pred.SAT_AVG_ALL)
CS2012C3$SAT_AVG_ALL <- SAT_AVG_ALL.imp

#For MD_EARN_WNE_P10
lm.imp.MD_EARN_WNE_P10 <- lm(MD_EARN_WNE_P10 ~ CONTROL + REGION + PREDDEG + LOCALE + C150 + NPT4 + NUM4 + MINORITY + TUITFTE + INEXPFTE + PELL_EVER + LOAN_EVER + UGDS + UGDS_ASIAN + UGDS_BLACK + UGDS_HISP + UGDS_NRA + UGDS_WHITE + UGDS_WOMEN + PCIPSTEM + PPTUG_EF + PCTPELL + RPY_1YR_RT + AVGFACSAL + COSTT4_A + PFTFTUG1_EF + SAT_AVG_ALL, data = CS2012C3)
pred.MD_EARN_WNE_P10 <- rnorm(161, predict(lm.imp.MD_EARN_WNE_P10, CS2012C3), sigma(lm.imp.MD_EARN_WNE_P10))
MD_EARN_WNE_P10.imp <- impute(MD_EARN_WNE_P10, pred.MD_EARN_WNE_P10)
CS2012C3$MD_EARN_WNE_P10 <- MD_EARN_WNE_P10.imp
```


```{r Binding C1,C2,C3: Recoding, message = FALSE, warning = FALSE, tidy = TRUE}
#Bind the different groups together to recreate CS2012, convert to tibble, delete extra tables
CS2012 <- rbind(CS2012C1, CS2012C2, CS2012C3)
CS2012 <- as_data_frame(CS2012) #To aid ease of manipulation converted the data frame into a tibble.
rm(CS2012C1, CS2012C2, CS2012C3)

#Clean up
rm(list = ls(pattern = "lm"))
rm(list = ls(pattern = "pred"))
rm(list = ls(pattern = "UGDS"))
rm(list = ls(pattern = ".imp"))

```


Many of the variables needed to be recoded. 
```{r Cleaning 5: Recoding, message = FALSE, warning = FALSE, tidy = TRUE}
CS2012$CONTROL <- recode_factor(CS2012$CONTROL, '1' = "Public", '2' = "Private nonprofit", '3' = "Private for-profit")
CS2012$REGION <- recode_factor(CS2012$REGION, '1' = "New England", '2' = "Mid East", '3' = "Great Lakes", '4' = "Plains", '5' = "Southeast", '6' = "Southwest", '7' = "Rocky Mountains", '8' = "Far West", '9' = "Outlying Areas")
CS2012$PREDDEG <- recode_factor(CS2012$PREDDEG, '0' = "Not classified", '1' = "Predominantly certificate-degree granting", '2' = "Predominantly associate's-degree granting", '3' = "Predominantly bachelor's-degree granting", '4' = "Entirely graduate-degree granting")
CS2012$LOCALE <- recode_factor(CS2012$LOCALE, '11' = "Large City", '12' = "Midsize City", '13' = "Small City", '21' = "Large Suburb", '22' = "Midsize Suburb", '23' = "Small Suburb", '31' = "Fringe Town", '32' = "Distant Town", '33' = "Remote Town", '41' = "Rural Fringe Territory", '42' = "Rural Distant Territory", '43' = "Rural Remote Territory")
CS2012$MINORITY <- recode_factor(CS2012$MINORITY, '0' = 'Non-minority', '1' = 'Single-Minority', '2' = 'Double-Minority')

#Next variables were reordered and renamed. 
CS2012 <- CS2012 %>% select(INSTNM, REGION, LOCALE, CONTROL, MINORITY, TUITFTE, INEXPFTE, AVGFACSAL, COSTT4_A, PREDDEG, NPT4, NUM4, SAT_AVG_ALL, PCIPSTEM, UGDS, UGDS_WHITE, UGDS_BLACK, UGDS_HISP, UGDS_ASIAN, UGDS_NRA, UGDS_WOMEN, PPTUG_EF, PFTFTUG1_EF, C150, LOAN_EVER, PELL_EVER, PCTPELL, RPY_1YR_RT, MD_EARN_WNE_P10)

CS2012dup <- CS2012 #Creating a duplicate of the dataset for later use

#Note the distribution of the institutions at this point is 1326 public, 559 private for-profit, and 986 private nonprofit institutions 
```

R automatically turns qualitative variables into dummy variables, but when this is done automatically it is difficult to perform variable selection. As a result, I converted qualitative variables into explicit dummy variables using the tidy package. This meant that all institutions had Public, Private nonprofit, and Private for-profit columns but only those in that category would have a 1.

```{r}
#Figure out how to take care of NAs
dummy <-function(x){ #function for quickly creating dummy variables
  x <- as.numeric(x) #convert the variable to a numeric type and reassign
  x[which(!is.na(x))]<-1 #the conversion above means that any non-numeric data will be converted to NA
  x[which(is.na(x))]<-0
  x #output the result
}

#Creating regional dummy variables from the REGION variable
CS2012 <- CS2012 %>% spread(REGION, REGION, 0) #Spreading the REGION variable
CS2012$`Far West` <- dummy(CS2012$`Far West`) #Using my dummy function to create a dummy variable here so that any institution in the Far West region will have a 1 and an institution anywhere else will have a 0, a similar methodology was followed for the other regional dummy variables below.
CS2012$`Great Lakes` <- dummy(CS2012$`Great Lakes`)
CS2012$`Mid East` <- dummy(CS2012$`Mid East`)
CS2012$`New England` <- dummy(CS2012$`New England`)
CS2012$Plains <- dummy(CS2012$Plains)
CS2012$`Rocky Mountains` <- dummy(CS2012$`Rocky Mountains`)
CS2012$Southeast <- dummy(CS2012$Southeast)
CS2012$Southwest <- dummy(CS2012$Southwest)
CS2012$`Outlying Areas` <- dummy(CS2012$`Outlying Areas`)

#Creating locale dummy variables from the LOCALE variable
CS2012 <- CS2012 %>% spread(LOCALE, LOCALE, 0) #Spreading the LOCALE variable
CS2012$`Distant Town` <- dummy(CS2012$`Distant Town`) #Using my dummy function to create a dummy variable here so that any institution located in a Distant Town will have a 1 and an institution anywhere else will have a 0, a similar methodology was followed for the other locale dummy variables below.
CS2012$`Fringe Town` <- dummy(CS2012$`Fringe Town`)
CS2012$`Large City` <- dummy(CS2012$`Large City`)
CS2012$`Large Suburb` <- dummy(CS2012$`Large Suburb`)
CS2012$`Midsize City` <- dummy(CS2012$`Midsize City`)
CS2012$`Midsize Suburb` <- dummy(CS2012$`Midsize Suburb`)
CS2012$`Remote Town` <- dummy(CS2012$`Remote Town`)
CS2012$`Rural Distant Territory` <- dummy(CS2012$`Rural Distant Territory`)
CS2012$`Rural Fringe Territory` <- dummy(CS2012$`Rural Fringe Territory`)
CS2012$`Rural Remote Territory` <- dummy(CS2012$`Rural Remote Territory`)
CS2012$`Small City` <- dummy(CS2012$`Small City`)
CS2012$`Small Suburb` <- dummy(CS2012$`Small Suburb`)

#Creating control dummy variables from the CONTROL variable
CS2012 <- CS2012 %>% spread(CONTROL, CONTROL, 0) #Spreading the CONTROL variable
CS2012$`Private for-profit` <- dummy(CS2012$`Private for-profit`) #Using my dummy function to create a dummy variable here so that any institution located in a Distant Town will have a 1 and an institution anywhere else will have a 0, a similar methodology was followed for the other control dummy variables below.
CS2012$`Private nonprofit` <- dummy(CS2012$`Private nonprofit`)
CS2012$Public <- dummy(CS2012$Public)

#Creating predicted degree dummy variables from the PREDDEG variable
CS2012 <- CS2012 %>% spread(PREDDEG, PREDDEG, 0) #Spreading the PREDDEG variable. 
CS2012$`Predominantly associate's-degree granting` <- dummy(CS2012$`Predominantly associate's-degree granting`) #Using my dummy function to create a dummy variable here so that any institution that predominantly grants associate degrees will have a 1 and an institution that predominantly grants one of the other two types of degrees will have a 0, a similar methodology was followed for the other predicted degree dummy variables below.
CS2012$`Predominantly bachelor's-degree granting` <- dummy(CS2012$`Predominantly bachelor's-degree granting`)
CS2012$`Predominantly certificate-degree granting` <- dummy(CS2012$`Predominantly certificate-degree granting`)
CS2012$`Not classified` <- dummy(CS2012$`Not classified`)

#Creating a minority dummy variable from the MINORITY variable. 
CS2012 <- CS2012 %>% spread(MINORITY, MINORITY, 0) #Spreading the MINORITY variable
CS2012$`Non-minority` <- dummy(CS2012$`Non-minority`) #Using my dummy function to create a dummy variable here so that any institution located in a Distant Town will have a 1 and an institution anywhere else will have a 0, a similar methodology was followed for the other control dummy variables below.
CS2012$`Single-Minority` <- dummy(CS2012$`Single-Minority`)
CS2012$`Double-Minority` <- dummy(CS2012$`Double-Minority`)

#Lastly, before beggining analysis variables were reordered, and renamed. Rather than eliminating one level of each category of my dummy variables (consistent with proper methodology), I simply eliminated my intercept. In this case, the estimated effects had the standard interpretation. For control this was Public, For predicted degree this was unclassified. For minority this was non-minority
CS2012 <- CS2012 %>% select(INSTNM, NEW_ENGLAND = `New England`, MID_EAST = `Mid East`, GREAT_LAKES = `Great Lakes`, PLAINS = Plains, SOUTH_EAST = Southeast, SOUTH_WEST = Southwest, ROCKY_MOUNT = `Rocky Mountains`, FAR_WEST = `Far West`, OUTLYING = `Outlying Areas`, LARGE_CITY = `Large City`, MID_SIZE_CITY = `Midsize City`, SMALL_CITY = `Small City`, LARGE_SUB = `Large Suburb`, MID_SIZE_SUB = `Midsize Suburb`, SMALL_SUB = `Small Suburb`, FRINGE_TOWN = `Fringe Town`, DIST_TOWN = `Distant Town`, REMOTE_TOWN = `Remote Town`, RURAL_FRINGE_TERR = `Rural Fringe Territory`, RURAL_DISTANT_TERR = `Rural Distant Territory`, RURAL_REMOTE_TERR = `Rural Remote Territory`, PUBLIC = Public, PRIV_NON = `Private nonprofit`, PRIV_4_PROF = `Private for-profit`, TUITFTE, INEXPFTE, AVGFACSAL, COSTT4_A, NOT_CLASSIFIED = `Not classified`, CERT_DEG = `Predominantly certificate-degree granting`, ASOC_DEG = `Predominantly associate's-degree granting`, BACH_DEG = `Predominantly bachelor's-degree granting`, NPT4, NUM4, SAT_AVG_ALL, PCIPSTEM, UGDS, UGDS_WHITE, UGDS_BLACK, UGDS_HISP, UGDS_ASIAN, UGDS_NRA, UGDS_WOMEN, NON_MINORITY = `Non-minority`, SINGLE_MINORITY = `Single-Minority`, DOUBLE_MINORITY = `Double-Minority`, PPTUG_EF, PFTFTUG1_EF, C150, LOAN_EVER, PELL_EVER, PCTPELL, RPY_1YR_RT, MD_EARN_WNE_P10) 

  
```


# Analysis
To analyze my data I used a value added approach as detailed in this [report]()at the beggining of this report. First, I carried out a multiple linear regression of all my variables on MD_EARN_WNE_P10.

To fit a multiple linear regression (MLR) model of all the predictor variables on median earnings after 10 years using least squares.
```{r MLR Model 1, message = FALSE, warning = FALSE, tidy = TRUE}
attach(CS2012) #Attaching the dataset so we can easily call on variables
MLR = lm(MD_EARN_WNE_P10~.0 + NEW_ENGLAND + MID_EAST + GREAT_LAKES + PLAINS + SOUTH_EAST + SOUTH_WEST + ROCKY_MOUNT + FAR_WEST + OUTLYING + LARGE_CITY + MID_SIZE_CITY + SMALL_CITY + LARGE_SUB + MID_SIZE_SUB + SMALL_SUB + FRINGE_TOWN + DIST_TOWN + REMOTE_TOWN + RURAL_FRINGE_TERR + RURAL_DISTANT_TERR + RURAL_REMOTE_TERR + PUBLIC + PRIV_NON + PRIV_4_PROF + TUITFTE + INEXPFTE + AVGFACSAL + COSTT4_A + NOT_CLASSIFIED + CERT_DEG + ASOC_DEG + BACH_DEG + NPT4 + NUM4 + SAT_AVG_ALL + PCIPSTEM + UGDS + UGDS_WHITE + UGDS_BLACK + UGDS_HISP + UGDS_ASIAN + UGDS_NRA + UGDS_WOMEN + NON_MINORITY + SINGLE_MINORITY + DOUBLE_MINORITY + PPTUG_EF + PFTFTUG1_EF + C150 + LOAN_EVER + PELL_EVER + PCTPELL + RPY_1YR_RT,data = CS2012)
MLRfit <- summary(MLR)
MLRfit #Output the regression coefficients for all the predictors
```

## Variable selection
Although some of my variables were significant, many were not. However, the model with an F-stat of `r MLRfit$fstatistic[1]` was significant at the 95% confidence level, indicating that there is a relationship between some of the variables and median earnings after 10 years.Consequently, I carried out Backward selection until all my variables were significant. Backward selection is a variable selection approach where, "We start with all variables in the model, and remove the variable with the largest p-value that is, the variable that is the least statistically significant. The new (p − 1)-variable model is fit, and the variable with the largest p-value is removed. This procedure continues until a stopping rule is reached" (James, Witten, Hastie, & Tibshirani, 2015). In this case, the stopping rule was that all variables must be significant to at least the 95%. I also removed any dummy variables causing singularities. The final MLR model reached was as follows;

```{r MLR Final Model, message = FALSE, warning = FALSE, tidy = TRUE}
MLR2 = lm(MD_EARN_WNE_P10~.0 + NEW_ENGLAND + MID_EAST + GREAT_LAKES + PLAINS + SOUTH_EAST + SOUTH_WEST + ROCKY_MOUNT + FAR_WEST + OUTLYING + LARGE_CITY + MID_SIZE_CITY + SMALL_CITY + LARGE_SUB + MID_SIZE_SUB + SMALL_SUB + FRINGE_TOWN + DIST_TOWN + REMOTE_TOWN + RURAL_FRINGE_TERR + RURAL_DISTANT_TERR + RURAL_REMOTE_TERR + PUBLIC + PRIV_NON + TUITFTE + INEXPFTE + AVGFACSAL + CERT_DEG + SAT_AVG_ALL + PCIPSTEM + UGDS + UGDS_WHITE + UGDS_ASIAN + UGDS_NRA + UGDS_WOMEN + PPTUG_EF + PFTFTUG1_EF + C150 + LOAN_EVER + PELL_EVER + RPY_1YR_RT,data = CS2012)#This model was fit with only these variables. 
MLR2fit <- summary(MLR2)
MLR2fit #Output the regression coefficients for all the predictors.
```

## Model Explanation
The final model was chosen because it had several advantages over the first model. First, due to model selection it was parsimonious, having 40 variables where the first had had 54. All variables were significant at least at the 95% confidence interval, and in fact most variables were significant at the 99.999% confidence interval. The model itself had an adjusted R-squared of `r MLR2fit$adj.r.squared`. Lastly, the F-statistic remained highly significant indicating that the model was valid. Although a full discussion of the model results is not necessary here, the impact of these variables on alumni median earnings after 10 years was roughly as expected. 

Predicting Median Earnings using the final model
```{r Prediction, message = FALSE, warning = FALSE, tidy = TRUE}
Predictions <- predict(MLR2, CS2012, interval = "prediction") #Used the predict() function to get the predicted value of median earnings and the lower and upper 95% prediction intervals for each institution and saved it in an object. The prediction intervals indicate that 95% of intervals of this form will contain the true value of median earnings for the institution.

CS2012_pred <- as_data_frame(cbind(CS2012dup,Predictions))%>% select(PRED_EARN = fit, -c(lwr, upr))
#Took several actions here
#Combined the Prediction object and CS2012 duplicate dataset.
#To aid ease of manipulation converted the data frame into a tibble.

CS2012_pred <- as_data_frame(cbind(CS2012dup,CS2012_pred))
#Took out the variables I am interested in, renamed them, and reassigned them.

CS2012_pred <- CS2012_pred %>% mutate(VALUE_ADDED = MD_EARN_WNE_P10 - PRED_EARN) #Created a value-added variable that shows how much an institution over or underperformed.
CS2012_pred <- CS2012_pred %>% arrange(desc(VALUE_ADDED)) #Reordered the list using the VALUE_ADDED variable. 

CS2012_pred$PERFORMANCE <- ""
CS2012_pred$PERFORMANCE[which(CS2012_pred$VALUE_ADDED > 0)] <- "Overperfomed"
CS2012_pred$PERFORMANCE[which(CS2012_pred$VALUE_ADDED < 0)] <- "Underperformed"
```


## Segmentation of Data***HERE
I decided to segment my data by taking the top, middle, and bottom deciles. Since I had 993 observations this was roughly 100 institutions in each group. 
```{r Data Segmentation, message = FALSE, warning = FALSE, tidy = TRUE}
TOP100 <- CS2012_pred %>% slice(1:967) #Selected the first 100 rows
MID100 <- CS2012_pred %>% slice(968:1934) #Selected the middle 101 rows
BOTTOM100 <- CS2012_pred %>% slice(1935:2902) #Selected the bottom 100 rows
```

I then summarized each segment into a simple tabulation of data that brought out the key insights. 
```{r Tabulation of Segmentation, message = FALSE, warning = FALSE, tidy = TRUE}
#Simplified the table to show institution names and value-added
TOP100 <- TOP100 %>% select(INSTNM, CONTROL, REGION, PREDDEG, LOCALE, MINORITY, VALUE_ADDED, PERFORMANCE) 
MID100 <- MID100 %>% select(INSTNM, CONTROL, REGION, PREDDEG, LOCALE, MINORITY, VALUE_ADDED, PERFORMANCE)
BOTTOM100 <- BOTTOM100 %>% select(INSTNM, CONTROL, REGION, PREDDEG, LOCALE, MINORITY, VALUE_ADDED, PERFORMANCE)
BOTTOM100 <- BOTTOM100 %>% arrange(VALUE_ADDED) #Reordered the list using the VALUE_ADDED variable to see worst schools.
```

**INSIGHT: While there are no clear differences between the Control of the institution and the predominant degree awarded across segments, the same is not true of region and locale.** 

# Vizualization
Consequently, it is clear that region and locale are two easily understandable variables/metrics that can be used to differentiate institutions. Below I demonstrate this for the top 100, middle 100, and bottom 100 universities.
```{r Vizualization 1, message = FALSE, warning =FALSE, tidy = TRUE}
TOP100 %>% ggplot(aes(x = LOCALE, fill = LOCALE)) + geom_bar() + xlab("Type of Locale") + ylab("The number of top 100 Institutions") + ggtitle("Barplot of the number of the top 100 institutions in each type of locale") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) #Creating a barplot of the number of TOP100 institutions in each type of LOCALE
TOP100 %>% ggplot(aes(x = LOCALE, fill = LOCALE)) + geom_bar() + facet_wrap(~REGION) + xlab("Type of Locale") + ylab("The number of top 100 Institutions") + ggtitle("Barplot of the number of top 100 institutions in each type of locale faceted by region") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) #Creating a barplot of the number of TOP100 institutions in each type of LOCALE faceted by REGION
```
**The top 100 institutions seems to cluster generally in Large suburbs, and cities. Additionally, they seem to be most prevalent in the Mid East, New England and the Southeast**

```{r Vizualization 2, message = FALSE, warning =FALSE, tidy = TRUE}
MID100 %>% ggplot(aes(x = LOCALE, fill = LOCALE)) + geom_bar() + xlab("Type of Locale") + ylab("The Number of mid 100 Institutions") + ggtitle("Barplot of the number of mid 100 institutions in each type of locale") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) #Creating a barplot of the number of MID100 institutions in each type of LOCALE
MID100 %>% ggplot(aes(x = LOCALE, fill = LOCALE)) + geom_bar() + facet_wrap(~REGION) + xlab("Type of Locale") + ylab("The Number of mid 100 Institutions") + ggtitle("Barplot of the number of middle 100 institutions in each type of locale faceted by region") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) #Creating a barplot of the number of MID100 institutions in each type of LOCALE faceted by REGION
```
**The middle 100 institutions seems to cluster generally in Distant Towns, Large suburbs, and cities. Additionally, they seem to be most prevalent in the Great Lakes, Plains and the Southeast**

```{r Vizualization 3, message = FALSE, warning =FALSE, tidy = TRUE}
BOTTOM100 %>% ggplot(aes(x = CONTROL, fill = CONTROL)) + geom_bar() + xlab("Type of Locale") + ylab("The Number of bottom 100 Institutions") + ggtitle("Barplot of the number of bottom 100 institutions in each type of locale") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) #Creating a barplot of the number of BOTTOM100 institutions in each type of LOCALE
BOTTOM100 %>% ggplot(aes(x = LOCALE, fill = LOCALE)) + geom_bar() + facet_wrap(~REGION) + xlab("Type of Locale") + ylab("The Number of bottom 100 Institutions") + ggtitle("Barplot of the number of bottom 100 institutions in each type of locale faceted by region") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) #Creating a barplot of the number of BOTTOM100 institutions in each type of LOCALE faceted by REGION
```
**The bottom 100 institutions seems to cluster generally in Large cities, Distant Towns, and Large suburbs. Additionally, they seem to be most prevalent in the Far West,and the Mideast**
