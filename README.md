# School_Enrollment-Project

This is my final project for Data Science II.



Following is what I have done in this project:


Predicting School Enrollment – R Data Science Project

READ-IN AND PREPARE THE SCHOOL ENROLLMENTS DATA

1.  At the top of your R code file, read-in most of the libraries that you will need.


2.  We will work on the school enrollment data first.  Read-in ELSI_School_Enroll_1990_2001_Revised.xlsx.  

3.  Prepare/clean the file prior to transposing and merging.  To replicate the SAS process, write some code to replace all "dagger" ("†") values and dashes ("–") from all variables.  Reassign the values to NA.
Base R is easiest for this task

4.  Change all variable names to lowercase.

5.  Transpose "school_clean1" from wide to long panel format by using the long_panel command (from panelr).  Be sure that you understand the code example pasted below.


6.  After the transpose, rename the variable "wave" (created by long_panel) to "year" and change "white", "black", "hispanic" and all other race/ethnic groups from character into numeric variable types.

7. Using dplyr and the rowwise() command, create a variable called "total_enroll2" by summing all of the race/ethnic counts together for each school.  Sort the data by school_id, year to inspect your enrollment counts and look over the data (some missing values are expected).  Drop the original "total_enroll" variable as it is no longer needed.

8.  Our school_id variable is now a "factor."  Using base R and dollar$ syntax, convert school_id to numeric.  Note: This can be tricky because you may have to convert to character first, then numeric (all on a single line of code).

READ-IN AND PREPARE THE SCHOOL COUNTY FIPS DATA – MERGE WITH ENROLLMENTS

9.  We now need a unique variable for each county (e.g. county_fips).  Read-in both school files that contain county fips using these names: school_counties <- ELSI_School_ID_County_FIPS_2001.xlsx and school_coord <- All_School_Coordinates_2016_ELSI.xlsx.  Be sure to convert school_id in both of these files into a numeric or integer format for merging with school_enrollment (using a single line of Base-R code  right after the read-in may work best.)

10.  Prepare / clean both files that contain fips_county (one at a time).  Lowercase all variables and keep only the needed variables when merging.  If needed, fix the improper two-word “school name” variable using this code: rename(school_name2="school name") %>% 

11.  Use dplyr left join to merge the enrollments data frame with school_counties (create: combo_school_counties).  Then, create a data frame with ONLY the non-matching records from the merge.  Merge this non-matching file with school_coord using an inner_join.  Lastly, merge the matching records from this merge with combo_school_counties.

12.  Clean the final enrollments (combo) file by removing unnecessary variables.  Use coalesce to ensure that the fips_county variable is as complete as possible. 

13.  Aggregate the final enrollments (combo) file to the county-year level by using: summarize(county_enroll=sum(total_enroll2)) with groupby.  You are done with the school enrollment file.

14.  Create a permanent csv for the county-year level school enrollments file that you just created and write syntax to clear all files from the R Global Environment using: rm(list=ls()).  Next, read-in the csv that you just created to start fresh.

READ-IN AND PREPARE THE CENSUS AND CRIME DATA – MERGE WITH SCHOOL ENROLLMENTS

15.  Use library(haven) to read-in census_orig using the SAS dataset "pop_est9001.sas7bdat".  Clean and prepare this file for merging by creating a numeric or integer fips_county variable and removing unnecessary variables.  To aid in cleaning/formatting, consider this code: mutate(population=pop, county_name2=county, state_name=state) %>% 

16.  We now need census population counts by race and age for use as predictors.  Use dplyr left_join to merge the aggregated (county-year) level school enrollment file with the county-year level census file.

17.  Read-in the SAS agency-year level crime data "ucr_1990_2001_ori_level.sas7bdat" and prepare this file for merging with enrollments.  

18.  You will need to create a unique concatenated fips_state, fips county (i.e. fips_state||fips_county) variable for the merge with enrollments.  To combine fips_state and fips_county together (in char format with leading zeros), use: mutate(fcounty=(formatC(fips_county, digits = 0, width=3, format="d", flag="0"))) %>%.  Repeat this process for fips_state.  Then use str_c or “string concatenate” function to combine the two fips variables together as fips_county.

19.  Use dplyr summarize with groupby to aggregate the crime data to the county-year level.  Be sure to keep the key crime variables.
      
20. Use dplyr left join to merge the combo_school_enrollments data (from step 16) with the aggregated crime data.

READ-IN AND PREPARE THE ECONOMIC DATA – MERGE WITH ENROLLMENTS

21. Read-in and prepare the economic files.

22. Convert fips_county to numeric or integer format.  Then, left_join the most updated enrollment file with the economic variables.

23.  Create two new county-wide crime rate variables: mutate(new_tot_crime_rate=(total_crime_county/population)*100000) %>% 
mutate(new_violent_rate=(violent_crime_county/population)*100000) %>%  
Also, create an employment rate variable: mutate(employment_rate=(employment/population*1000))

24. Finish cleaning and relocate variables as needed. For example: relocate(new_tot_crime_rate, new_violent_rate, .before=area_name).  You now have your final merged file.  

25. Demean the independent and dependent variables for use in panel data regressions

26.  Write this final file with DM variables into a permanent csv file.  You may again wish to clear your Global Environment, read-in the permanent csv that you just created and start fresh.  Analytics is next.

GET ANSWERS – DATA ANALYTICS	

27. Create nation-year descriptive variables to check overall trends.  Were enrollments, crime, econ up or down over the 12-year time period (1990-2001)?  A few simple line plots are optional.

Optional line plot code (you may also use ggplot2):
Not required:  plot(national_schools1$year, national_schools1$county_enroll_DM, type = "l")

28. Check inter-variable correlations (any values higher than .65 should be used with caution)

Question:  What variable is most correlated with “year”?

29. Regress enrollment by each predictor, one at a time.  Lastly, run the final regression model with all statistically significant predictors together.

30.  Which census, economic, and crime variables significantly predicted county school enrollment from 1990-2012?  What was the overall predictive value of the final regression model (adjusted R-square)?  Which variables predicted a decline in enrollment (e.g. people leaving the area due to bad conditions in the county)?  In a few brief sentences, explain your results.  
