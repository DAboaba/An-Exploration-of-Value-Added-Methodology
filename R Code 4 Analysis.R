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
Completion rate for first-time full-time students (C150_)                       |                                                                |
Share of undergraduates who are first-time full-time (PFTFTUG1_EF)              |                                                                |
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
```

To import the dataset;
```{r Main importation, message = FALSE, warning = FALSE, tidy = TRUE}
setwd("/Users/DMA/Desktop/Columbia/Programming\ in\ R/Toolbox/CollegeScorecard_Raw_Data") #Set the working directory to wherever you have stored the downloaded data. 
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
as_data_frame(CS2012_13) #To aid ease of manipulation converted the data frame into a tibble.
CS2012_13 <- select(CS2012_13, OPEID, OPEID6, INSTNM, MAIN, NUMBRANCH, CONTROL, REGION, SAT_AVG_ALL, AVGFACSAL, UGDS, UGDS_WHITE, UGDS_BLACK, UGDS_HISP, UGDS_ASIAN, UGDS_NRA, UGDS_WOMEN, PPTUG_EF, C150_4, C150_L4, PFTFTUG1_EF, RPY_1YR_RT, LOAN_EVER, PELL_EVER, MD_EARN_WNE_P10) #Dropped unnecessary variables
```

To finish addressing the second issue, I imported the 2013/2014 dataset, kept the variables of interest that actually reflected 2012/2013, and joined this dataset to the 2012/2013 dataset.
```{r Issue 2, message = FALSE, warning = FALSE, tidy = TRUE}
setwd("/Users/DMA/Desktop/Columbia/Programming\ in\ R/Toolbox/CollegeScorecard_Raw_Data") #Set the working directory to wherever you have stored the downloaded data.
CS2013_14 <- read_csv("MERGED2013_14_PP.csv") #Use the read_csv() function from the readr package to import the dataset into R.
as_data_frame(CS2013_14) #To aid ease of manipulation converted the data frame into a tibble.
CS2013_14 <- select(CS2013_14, OPEID, PREDDEG, TUITFTE, INEXPFTE, PCIP01, PCIP03, PCIP04, PCIP10, PCIP11, PCIP14, PCIP15, PCIP26, PCIP27, PCIP29, PCIP40, PCIP41, NPT4_PUB, NPT4_PRIV, NUM4_PUB, NUM4_PRIV, COSTT4_A, PCTPELL) #Dropped unnecessary variables
CS2012b <- left_join(CS2012_13, CS2013_14, by = "OPEID") #Joined the two modified datasets on the OPEID variable using the left_join() function from the tidyr package. "OPEID is the identification number used by the U.S. Department of Education to identify institutions. This is a an 8-digit number that distinguishes between institutions, branches, additional locations, and other entities that are part of the eligible institution".
```

To address the third issue, I imported the 2014/2015 dataset, kept the variables I was interested in and joined this dataset to the CS2012b dataset
```{r Issue 3, message = FALSE, warning = FALSE, tidy = TRUE}
setwd("/Users/DMA/Desktop/Columbia/Programming\ in\ R/Toolbox/CollegeScorecard_Raw_Data") #Set the working directory to wherever you have stored the downloaded data.
CS2014_15 <- read_csv("MERGED2014_15_PP.csv") #Use the read_csv() function from the readr package to import the dataset into R.
as_data_frame(CS2014_15) #To aid ease of manipulation converted the data frame into a tibble.
CS2014_15 <- select(CS2014_15, OPEID, CURROPER, LOCALE, HBCU, PBI, ANNHI, TRIBAL, AANAPII, HSI, NANTI, MENONLY, WOMENONLY) #Dropped unnecessary variables
CS2012 <- left_join(CS2012b, CS2014_15, by = "OPEID") #Joined the two modified datasets using the OPEID variable.
```

#### Preparation Part 2
The rationale behind importing data from the 2014/2015 dataset was to use several variables as a filter. In particular, I did not want to include colleges that were not currently operating, or were geared towards a specific mission (such as women only). Additionally, colleges with multiple campuses posed a problem because it would needlessly complicate my research. Therefore, I removed these colleges and then removed the variables I had used for the filtering.
```{r Filtering out colleges,message = FALSE, warning = FALSE, tidy = TRUE}
CS2012 <- CS2012 %>% filter(CURROPER == 1, HBCU == 0, PBI == 0, ANNHI == 0, TRIBAL == 0, AANAPII == 0, HSI == 0, NANTI == 0, MENONLY == 0, WOMENONLY == 0, MAIN == 1, NUMBRANCH == 1) #Keep colleges that are currently operating and not Historically Black institutions, predominantly black institutions, Alaska Native Native Hawaiian serving institutions, tribal institutions, Asian American Native American Pacific Islander-serving institutions, Hispanic-serving institutions, Native American non-tribal institution, men-only institutions, women-only institutions.
CS2012 <- select(CS2012, -c(OPEID, OPEID6, MAIN, NUMBRANCH, HBCU, PBI, ANNHI, TRIBAL, AANAPII, HSI, NANTI, MENONLY, WOMENONLY, CURROPER)) #Remove variables that were used to filter out institutions.
```

## Cleaning
### Cleaning Part 1
At this point the dataset has been adequately prepared. Consequently, I began to clean the dataset for final analysis. Several problems were obvious and I began working to address and mitigate these issues. 

The main issue that needed to be addressed was that the type of many of the variables was wrong. Because in the original dataset, missing data was recorded as "NULL", when the data was imported these variables were stored as character types. Thus, there were twp problems I had to address, incorrect types and NULL. At the same time, some of the variables I had were still not fully representative of what I wanted. 

The SAT_AVG_ALL, AVGFACSAL, UGDS, PPTUG_EF, PFTFTUG1_EF, TUITFTE, INEXPFTE, COSTT4_A, PCTPELL variables had NULLs and consequently the wrong data type. 
```{r Cleaning 1, message = FALSE, warning = FALSE, tidy = TRUE}
CS2012 <- CS2012 %>% filter(SAT_AVG_ALL != "NULL", AVGFACSAL != "NULL", PPTUG_EF != "NULL", PFTFTUG1_EF != "NULL", TUITFTE != "NULL", INEXPFTE != "NULL", COSTT4_A != "NULL", PCTPELL != "NULL") #Filter out missing data for the SAT_AVG_ALL, AVGFACSAL, PPTUG_EF, PFTFTUG1_EF, TUITFTE, INEXPFTE, COSTT4_A, PCTPELL variables.

#Converting these variables into numeric
CS2012$SAT_AVG_ALL <- as.numeric(CS2012$SAT_AVG_ALL) 
CS2012$AVGFACSAL <- as.numeric(CS2012$AVGFACSAL) 
CS2012$PPTUG_EF <- as.numeric(CS2012$PPTUG_EF) 
CS2012$PFTFTUG1_EF <- as.numeric(CS2012$PFTFTUG1_EF) 
CS2012$TUITFTE <- as.numeric(CS2012$TUITFTE)
CS2012$INEXPFTE <- as.numeric(CS2012$INEXPFTE)
CS2012$COSTT4_A <- as.numeric(CS2012$COSTT4_A)
CS2012$PCTPELL <- as.numeric(CS2012$PCTPELL)

CS2012 <- CS2012 %>% filter(UGDS!="NULL", UGDS_WHITE!="NULL", UGDS_BLACK!="NULL", UGDS_HISP!="NULL", UGDS_ASIAN!="NULL", UGDS_NRA!="NULL", UGDS_WOMEN!="NULL") #Filter out missing data for UGDS variables.

#Convert UGDS variables into numeric type.
CS2012$UGDS <- as.numeric(CS2012$UGDS) 
CS2012$UGDS_WHITE <- as.numeric(CS2012$UGDS_WHITE) 
CS2012$UGDS_BLACK <- as.numeric(CS2012$UGDS_BLACK) 
CS2012$UGDS_HISP <- as.numeric(CS2012$UGDS_HISP) 
CS2012$UGDS_ASIAN <- as.numeric(CS2012$UGDS_ASIAN) 
CS2012$UGDS_NRA <- as.numeric(CS2012$UGDS_NRA) 
CS2012$UGDS_WOMEN <- as.numeric(CS2012$UGDS_WOMEN) 

```

The RPY_1YR_RT, LOAN_EVER, PELL_EVER, and MD_EARN_WNE variables also had NULLs and consequently the wrong data type. They also had "PRIVACYSUPPRESSED" for some of the data. 
```{r Cleaning 2, message = FALSE, warning = FALSE, tidy = TRUE}
CS2012 <- CS2012 %>% filter(RPY_1YR_RT!="NULL", LOAN_EVER!="NULL", PELL_EVER!="NULL", MD_EARN_WNE_P10!="NULL") #filter out missing data
CS2012 <- CS2012 %>% filter(RPY_1YR_RT!="PrivacySuppressed", LOAN_EVER!="PrivacySuppressed", PELL_EVER!="PrivacySuppressed", MD_EARN_WNE_P10!="PrivacySuppressed") #filter out suppressed data

#Converting these variables into numeric
CS2012$RPY_1YR_RT <- as.numeric(CS2012$RPY_1YR_RT)
CS2012$LOAN_EVER <- as.numeric(CS2012$LOAN_EVER)
CS2012$PELL_EVER <- as.numeric(CS2012$PELL_EVER)
CS2012$MD_EARN_WNE_P10 <- as.numeric(CS2012$MD_EARN_WNE_P10)
```

The "PICPxy" variables, where x and y are numbers ranging from 0 to 9, represent the percentage of degrees an institution awarded in several STEM fields. These variables were taken from a larger list of degrees an institution awarded in several fields. I used this [STEM Degree list](http://stemdegreelist.com) to narrow down the variables. Because I was interested in the total percentage of degrees an institution awarded in STEM generally. I added up the percentages and created a new variable. However, before doing this, I had to first exclude NULLs and correct the data type.
```{r Cleaning 3, message = FALSE, warning = FALSE, tidy = TRUE}
#filtering out missing data
CS2012 <- CS2012 %>% filter(PCIP01 != "NULL", PCIP03 != "NULL", PCIP04 != "NULL",  PCIP10 != "NULL", PCIP11!= "NULL", PCIP14!= "NULL", PCIP15!= "NULL", PCIP26!= "NULL", PCIP27!= "NULL", PCIP29!= "NULL", PCIP40!= "NULL", PCIP41!= "NULL")

#Converting these variables into numeric
CS2012$PCIP01 <- as.numeric(CS2012$PCIP01)
CS2012$PCIP03 <- as.numeric(CS2012$PCIP03)
CS2012$PCIP04 <- as.numeric(CS2012$PCIP04)
CS2012$PCIP10 <- as.numeric(CS2012$PCIP10)
CS2012$PCIP11 <- as.numeric(CS2012$PCIP11)
CS2012$PCIP14 <- as.numeric(CS2012$PCIP14)
CS2012$PCIP15 <- as.numeric(CS2012$PCIP15)
CS2012$PCIP26 <- as.numeric(CS2012$PCIP26)
CS2012$PCIP27 <- as.numeric(CS2012$PCIP27)
CS2012$PCIP29 <- as.numeric(CS2012$PCIP29)
CS2012$PCIP40 <- as.numeric(CS2012$PCIP40)
CS2012$PCIP41 <- as.numeric(CS2012$PCIP41)

#Creating a new combination variable
CS2012 <- CS2012 %>% mutate(PCIPSTEM = PCIP01 + PCIP03 + PCIP04 + PCIP10 + PCIP11 + PCIP14 + PCIP15 + PCIP26 + PCIP27 + PCIP29 + PCIP40 + PCIP41)

#Removing the old variables
CS2012 <- select(CS2012, -c(PCIP01, PCIP03, PCIP04, PCIP10, PCIP11, PCIP14, PCIP15, PCIP26, PCIP27, PCIP29, PCIP40, PCIP41))
```

### Cleaning Part 2
Looking through the data it became clear that I had only a few less than 4-year institutions with. Consequently, I removed these institutions. Second, I needed to convert the C150_4 variable to numeric and filter out any institutions without data for this variable. Additionally, the NUM4 and NPT4 variables were split between public and private institutions. Because combining these proved difficult, I also removed them from the analysis. 
```{r Cleaning 4, message = FALSE, warning = FALSE, tidy = TRUE}
CS2012 <- CS2012 %>% filter(C150_L4 == "NULL") #Filtering out less than 4-year institutions because 4-year institutions have "NULL" data for this variable.
CS2012 <- CS2012 %>% filter(C150_4 != "NULL")
CS2012$C150_4 <- as.numeric(CS2012$C150_4)
CS2012 <- select(CS2012, -c(C150_L4, NPT4_PUB, NPT4_PRIV, NUM4_PUB, NUM4_PRIV)) #Removing several unnecessary variables.
```

Many of the variables needed to be recoded. 
```{r Cleaning: Recoding, message = FALSE, warning = FALSE, tidy = TRUE}
CS2012$CONTROL <- recode(CS2012$CONTROL, '1' = "Public", '2' = "Private nonprofit", '3' = "Private for-profit")
CS2012$REGION <- recode(CS2012$REGION, '1' = "New England", '2' = "Mid East", '3' = "Great Lakes", '4' = "Plains", '5' = "Southeast", '6' = "Southwest", '7' = "Rocky Mountains", '8' = "Far West", '9' = "Outlying Areas")
CS2012$PREDDEG <- recode(CS2012$PREDDEG, '0' = "Not classified", '1' = "Predominantly certificate-degree granting", '2' = "Predominantly associate's-degree granting", '3' = "Predominantly bachelor's-degree granting", '4' = "Entirely graduate-degree granting")
CS2012$LOCALE <- recode(CS2012$LOCALE, '11' = "Large City", '12' = "Midsize City", '13' = "Small City", '21' = "Large Suburb", '22' = "Midsize Suburb", '23' = "Small Suburb", '31' = "Fringe Town", '32' = "Distant Town", '33' = "Remote Town", '41' = "Rural Fringe Territory", '42' = "Rural Distant Territory", '43' = "Rural Remote Territory")
CS2012 <- unique(CS2012) #Deleting duplicated rows
CS2012dup <- CS2012 #Creating a duplicate of the dataset for later use

#Lastly, before beggining analysis variables were reordered and renamed. 
CS2012 <- CS2012 %>% select(INSTNM, REGION, LOCALE, CONTROL, TUITFTE, INEXPFTE, AVGFACSAL, COSTT4_A, PREDDEG, SAT_AVG_ALL, PCIPSTEM, UGDS, UGDS_WHITE, UGDS_BLACK, UGDS_HISP, UGDS_ASIAN, UGDS_NRA, UGDS_WOMEN, PPTUG_EF, PFTFTUG1_EF, C150_4, LOAN_EVER, PELL_EVER, PCTPELL, RPY_1YR_RT, MD_EARN_WNE_P10)
```

# Analysis
To analyze my data I used a value added approach as detailed at the beggining of this report. First, I carried out a multiple linear regression of all my variables on MD_EARN_WNE_P10.

To fit a multiple linear regression (MLR) model of all the predictor variables on median earnings after 10 years using least squares
```{r MLR Model 1, message = FALSE, warning = FALSE, tidy = TRUE}
attach(CS2012) #Attaching the dataset so we can easily call on variables
MLR = lm(MD_EARN_WNE_P10~.-INSTNM,data = CS2012) #This is shorthand for all the variables apart from INSTNM
MLRfit <- summary(MLR)
MLRfit #Output the regression coefficients for all the predictors
contrasts(factor(REGION)) #To return the coding that R uses for any dummy variable, in this case REGION
```

## Variable selection
Although some of my variables were significant, many were not. However, the model with an F-stat of `r MLRfit$fstatistic[1]` was significant at the 95% confidence level, indicating that there is a relationship between some of the variables and median earnings after 10 years.Consequently, I carried out Backward selection until all my variables were significant. Backward selection is a variable selection approach where, "We start with all variables in the model, and remove the variable with the largest p-value that is, the variable that is the least statistically significant. The new (p − 1)-variable model is fit, and the variable with the largest p-value is removed. This procedure continues until a stopping rule is reached" (James, Witten, Hastie, & Tibshirani, 2015). In this case, the stopping rule was that all variables must be significant to the 95%. The final MLR model reached was as follows;

```{r MLR Final Model, message = FALSE, warning = FALSE, tidy = TRUE}
MLR2 = lm(MD_EARN_WNE_P10~ PRIV4PROF + PRIVNON + AVGFACSAL + SAT_AVG_ALL + PCIPSTEM + UGDS_BLACK + UGDS_HISP + UGDS_ASIAN + UGDS_WOMEN + PPTUG_EF + PFTFTUG1_EF + C150_4 + LOAN_EVER + PELL_EVER + RPY_1YR_RT,data = CS2012) #This model was fit with only these variables. 
MLR2fit <- summary(MLR2)
MLR2fit #Output the regression coefficients for all the predictors.
```

## Model Explanation
The final model was chosen because it had several advantages over the first model. First, due to model selection it was parsimonious, having 15 variables where the first had had 42. All variables were significant at least at the 95% confidence interval and the model itself had an adjusted R-squared of `r MLR2fit$adj.r.squared`. Lastly, the F-statistic remained highly significant indicating that the model was valid. Although a full discussion of the model results is not necessary here, the impact of some variables was quite interesting. For instance, an alumni of a Private-for-profit institution had median earnings after 10 years that were on average almost $6000 greater than the earnings of an alumni of a Public institution. However, the impact of these variables on alumni median earnings after 10 years was roughly as expected. 


Predicting Median Earnings using the final model
```{r Prediction, message = FALSE, warning = FALSE, tidy = TRUE}
Predictions <- predict(MLR2, CS2012, interval = "prediction") #Used the predict() function to get the predicted value of median earnings and the lower and upper 95% prediction intervals for each institution and saved it in an object. The prediction intervals indicate that 95% of intervals of this form will contain the true value of median earnings for the institution.

CS2012dup <- as_data_frame(cbind(CS2012dup,Predictions)) %>% select(INSTNM, ACTUAL_EARN = MD_EARN_WNE_P10, PRED_EARN = fit, LWR_PRED_INT = lwr, UPR_PRED_INT = upr, CONTROL, REGION, PREDDEG, LOCALE) 
#Took several actions here
#Combined the Prediction object and CS2012 duplicate dataset.
#To aid ease of manipulation converted the data frame into a tibble.
#Took out the variables I am interested in, renamed them, and reassigned them.

CS2012dup <- CS2012dup %>% mutate(VALUE_ADDED = ACTUAL_EARN - PRED_EARN) #Created a value-added variable that shows how much an institution over or underperformed.
CS2012dup <- CS2012dup %>% arrange(desc(VALUE_ADDED)) #Reordered the list using the VALUE_ADDED variable. 
CS2012dup <- CS2012dup %>% select(INSTNM, VALUE_ADDED, ACTUAL_EARN, PRED_EARN, LWR_PRED_INT, UPR_PRED_INT, CONTROL, REGION, PREDDEG, LOCALE) #Reordered all the variables. 
```

## Segmentation of Data
I decided to segment my data by taking the top, middle, and bottom deciles. Since I had 993 observations this was roughly 100 institutions in each group. 
```{r Data Segmentation, message = FALSE, warning = FALSE, tidy = TRUE}
TOP100 <- CS2012dup %>% slice(1:100) #Selected the first 100 rows
MID100 <- CS2012dup %>% slice(446:546) #Selected the middle 101 rows
BOTTOM100 <- CS2012dup %>% slice(894:993) #Selected the bottom 100 rows
```

I then summarized each segment into a simple tabulation of data that brought out the key insights. 
```{r Tabulation of Segmentation, message = FALSE, warning = FALSE, tidy = TRUE}
#Simplified the table to show institution names and value-added
TOP100 <- TOP100 %>% select(INSTNM, VALUE_ADDED, CONTROL, REGION, PREDDEG, LOCALE) 
MID100 <- MID100 %>% select(INSTNM, VALUE_ADDED, CONTROL, REGION, PREDDEG, LOCALE)
BOTTOM100 <- BOTTOM100 %>% select(INSTNM, VALUE_ADDED, CONTROL, REGION, PREDDEG, LOCALE)
BOTTOM100 <- BOTTOM100 %>% arrange(VALUE_ADDED) #Reordered the list using the VALUE_ADDED variable. 
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
BOTTOM100 %>% ggplot(aes(x = LOCALE, fill = LOCALE)) + geom_bar() + xlab("Type of Locale") + ylab("The Number of bottom 100 Institutions") + ggtitle("Barplot of the number of bottom 100 institutions in each type of locale") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) #Creating a barplot of the number of BOTTOM100 institutions in each type of LOCALE
BOTTOM100 %>% ggplot(aes(x = LOCALE, fill = LOCALE)) + geom_bar() + facet_wrap(~REGION) + xlab("Type of Locale") + ylab("The Number of bottom 100 Institutions") + ggtitle("Barplot of the number of bottom 100 institutions in each type of locale faceted by region") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) #Creating a barplot of the number of BOTTOM100 institutions in each type of LOCALE faceted by REGION
```
**The bottom 100 institutions seems to cluster generally in Large cities, Distant Towns, and Large suburbs. Additionally, they seem to be most prevalent in the Far West,and the Mideast**