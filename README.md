# An-Exploration-of-Value-Added-Methodology
Ranking U.S. Colleges in R

## Problem Description
Many commentators have marked the increasing importance of college to an individual's future earnings. Yet, the cost of attending college has never been higher, and people continue to lack information they can use to compare different institutions. Consequently, the importance of ranking the best colleges cannot be understated. This analysis ranks an extensive list of U.S. colleges using a value-added approach very similar to that used by [the Economist](http://www.economist.com/blogs/graphicdetail/2015/10/value-university) and [the Brookings Institute](https://www.brookings.edu/wp-content/uploads/2015/04/BMPP_CollegeValueAdded.pdf). However, this analysis goes beyond the previous approaches in several ways. 
  
  (1) it makes use of a formal imputation methodology, proposed by Columbia University's Andrew Gelman, to correct for instances of missing data. Second, it makes use of a machine learning approach to variable selection by creating several linear regression models and performing backward variable selection to obtain a parsimonious model with significant variables. Third, it makes use of accepted data visualization principles to illustrate common characteristics of the top 100, middle 100, and bottom 100 ranked institutions. Thus, this analysis (1) demonstrates the deceptiveness of standard college rankings by showing that the universities that rank highest in value-added are substantially different from those ranked highest in the most popular college rankings, (2) provides insight into the institutional factors that are of greatest value, measured by median earnings, to most students.

## Dataset
The dataset is from the [College Scorecard data webpage](https://collegescorecard.ed.gov/data/). The College Scorecard project was created to allow students and families to compare how well different colleges are preparing their students to be successful. Thus, it has data on the performance of institutions that receive federal aid and the outcomes of their students. The data is provided through "...federal reporting from institutions, data on federal financial aid, and tax information"[Data Documentation for College Scorecard](https://www.brookings.edu/wp-content/uploads/2015/04/BMPP_CollegeValueAdded.pdf). 
