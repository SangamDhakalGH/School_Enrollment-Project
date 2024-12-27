#Sangam Dhakal
#School Enrollment Project
#Data Science II 
#Fall 2024

#1
library(tidyverse)
library(panelr)
library(haven)
library(dplyr)
library(readxl)
library(corrr)

#2
school_clean1 <- read_xlsx("C:/Users/sngmd/OneDrive - University of Toledo/Desktop/5TH SEM/data science 2/R/ELSI_School_Enroll_1990_2001_Revised.xlsx")

#3
school_clean1[school_clean1 == "†" | school_clean1 == "–"] <- NA

#4
names(school_clean1) <- tolower(names(school_clean1))

#5
school_long <- long_panel(
  school_clean1,       
  id = "school_id",    
  prefix = "_",       
  begin = 1990,        
  end = 2001,          
  label_location = "end" 
)

#6
school_long <- school_long %>%
  rename(year = wave) %>%
  mutate(across(c(white, black, hispanic, ai_native, asian_pacif), 
                ~ as.numeric(as.character(.))))

#7
school_long <- school_long %>%
  mutate(total_enroll2 = rowSums(across(c(white, black, hispanic, ai_native, asian_pacif)), na.rm = TRUE)) %>%
  arrange(school_id, year) %>%
  select(-total_enroll)

#8
school_long$school_id <- as.numeric(as.character(school_long$school_id))

# 9
school_counties <- read_xlsx("C:/Users/sngmd/OneDrive - University of Toledo/Desktop/5TH SEM/data science 2/R/ELSI_School_ID_County_FIPS_2001.xlsx")
names(school_counties)[names(school_counties) == "School_ID"] <- "school_id"
school_counties$school_id <- as.numeric(as.character(school_counties$school_id))

school_coord <- read_xlsx("C:/Users/sngmd/OneDrive - University of Toledo/Desktop/5TH SEM/data science 2/R/All_School_Coordinates_2016_ELSI.xlsx")
names(school_coord)[names(school_coord) == "School ID NCES"] <- "school_id"
school_coord$school_id <- as.numeric(as.character(school_coord$school_id))


#10
school_counties <- school_counties %>%
  rename_all(tolower) %>%  # Convert all column names to lowercase
  select(school_id, county_number)  


school_coord <- school_coord %>%
  rename_all(tolower) %>%  
  rename(`school name` = school_name2) %>%  
  select(school_id, county_number) 


#11
combo_school_counties <- school_long %>%
  left_join(school_counties, by = "school_id")

non_matching <- school_long %>%
  anti_join(school_counties, by = "school_id")


merged_non_matching <- non_matching %>%
  inner_join(school_coord, by = "school_id")


final_combo <- combo_school_counties %>%
  bind_rows(merged_non_matching)




#12
final_combo <- final_combo %>%
  filter(!is.na(county_number)) %>%  
  mutate(
    fips_county = county_number,
    county_number = as.numeric(as.character(county_number)),  
  )

final_combo_clean <- final_combo %>%
  select(
    school_id, year, school_name, state_name, state_abbr, fips_county,
    white, black, hispanic, ai_native, asian_pacif, total_enroll2
  )

final_combo_clean <- final_combo %>%
  drop_na(
    school_id, year, school_name, state_name, state_abbr,
    white, black, hispanic, ai_native, asian_pacif, total_enroll2
  )


#13
# Grouping by fips_county and year, then summarize to get total enrollment
county_year_enrollment <- final_combo_clean %>%
  group_by(state_name, fips_county, year) %>%
  summarize(
    county_enroll = sum(total_enroll2),  
    .groups = "drop"  
  )

#14
write.csv(county_year_enrollment, "C:/Users/sngmd/OneDrive - University of Toledo/Desktop/5TH SEM/data science 2/R/county_year_enrollment.csv", row.names = FALSE)


#15
census_orig <- read_sas("C:/Users/sngmd/OneDrive - University of Toledo/Desktop/5TH SEM/data science 2/R/pop_est9001.sas7bdat")


census_clean <- census_orig %>%
  mutate(
    population = pop,  
    county_name2 = County,  
    state_name = state,  
    fips = sprintf("%04d", as.numeric(as.character(fips)))  
  ) %>%
  select(fips, year, population, county_name2, state_name, prop_nonwhite, prop_male, prop_age1524)  


write.csv(census_clean, "C:/Users/sngmd/OneDrive - University of Toledo/Desktop/5TH SEM/data science 2/R/census_clean.csv", row.names = FALSE)


county_year <- read_csv("C:/Users/sngmd/OneDrive - University of Toledo/Desktop/5TH SEM/data science 2/R/county_year_enrollment.csv")




county_year <- county_year %>%
  mutate(fips_county = sprintf("%04d", as.numeric(fips_county)))

census_clean <- census_clean %>%
  mutate(fips = sprintf("%04d", as.numeric(fips)))


#16
merged_data <- county_year %>%
  left_join(census_clean, by = c("fips_county" = "fips", "year" = "year"))


# Combine state.x and state.y into a single column and drop the originals
merged_data <- merged_data %>%
  mutate(state = coalesce(state_name.x, state_name.y)) %>%  
  select(-state_name.x, -state_name.y)  


#17
ucr <- read_sas("C:/Users/sngmd/OneDrive - University of Toledo/Desktop/5TH SEM/data science 2/R/ucr_1990_2001_ori_level.sas7bdat")



#18
ucr_data_clean <- ucr %>%
  mutate(
    # Ensuring fips_state is in 2-digit format with leading zeros
    fips_state = formatC(fips_state, width = 2, format = "d", flag = "0"),
    
    # Ensuring fips_county is in 3-digit format with leading zeros
    fips_county_short = formatC(fips_county, width = 3, format = "d", flag = "0"),
    
    # Concatenate fips_state and fips_county_short to create fips_county
    fips_county = str_c(fips_state, fips_county_short)
  ) %>%
  select(fips_county, yearucr, everything())


#Rename
ucr_data_clean <- ucr_data_clean %>%
  rename(year = yearucr)  


#19
ucr_data_aggregated <- ucr_data_clean %>%
  group_by(fips_county, year) %>%  
  summarize(
    total_crime_county = mean(total_sum, na.rm = TRUE),  
    total_crime_rate_old = mean(total_rate, na.rm = TRUE),  
    violent_crime_county = mean(violent_sum, na.rm = TRUE), 
    violent_rate_old = mean(violent_rate, na.rm = TRUE),  
    .groups = "drop"  
  )


#20

final_merged_data <- merged_data %>%
  left_join(ucr_data_aggregated, by = c("fips_county" = "fips_county", "year" = "year"))



#21
files = list.files(path="C:/Users/sngmd/OneDrive - University of Toledo/Desktop/5TH SEM/data science 2/R/New folder",pattern="*.sas7bdat", full.names=TRUE)
j=1989
for (i in files) {
  j=j+1
  assign(paste0("reis_",j),read_sas(i))
  temp=get(paste0("reis_",j)) #creates temp file for renaming variables and adding year
  names(temp)<- c("fips_county","area_name","state","percap_income","employment")
  temp$year=j
  assign(paste0("reis_",j), temp)   #Renames temp back to original reis_yyyy 
}
econ_vect <- mget(ls(pattern="reis_"))
econ_orig <- bind_rows(econ_vect)  #Stacks the econ files together




#22

final_merged_data <- final_merged_data %>%
  mutate(fips_county = sprintf("%05d", as.numeric(fips_county)))


econ_orig <- econ_orig %>%
  mutate(fips_county = sprintf("%05d", as.numeric(fips_county)))


# left join
final_merged_data2 <- final_merged_data %>%
  left_join(econ_orig, by = c("fips_county" = "fips_county", "year" = "year"))



final_merged_data2 <- final_merged_data2 %>%
  mutate(state = coalesce(state.x, state.y)) %>%  
  select(-state.x, -state.y)



#23
final_merged_data2 <- final_merged_data2 %>%
  mutate(
    # Total crime rate per 100,000 people
    new_tot_crime_rate = (total_crime_county / population) * 100000,
    
    # Violent crime rate per 100,000 people
    new_violent_rate = (violent_crime_county / population) * 100000,
    
    # Employment rate per 1,000 people
    employment_rate = (employment / population) * 1000
  )

#24
final_merged_data2 <- final_merged_data2 %>%
  relocate(new_tot_crime_rate, new_violent_rate, .before = area_name) %>%  # Move new crime rate variables
  relocate(employment_rate, .before = area_name)


#25
school_dm_final <- final_merged_data2 %>%
  group_by(fips_county) %>%
  mutate(across(where(is.numeric), ~ .x - mean(.x, na.rm = TRUE),.names = "{.col}_DM"))




#26
write.csv(school_dm_final, "C:/Users/sngmd/OneDrive - University of Toledo/Desktop/5TH SEM/data science 2/R/school_dm_final.csv", row.names = FALSE)


#27
national_school <- school_dm_final %>% 
  group_by(year) %>% 
  summarize(county_enroll_dm=mean(county_enroll_DM, na.rm=TRUE),
            prop_nonwhite_dm=mean(prop_nonwhite_DM, na.rm=TRUE),
            prop_age1524_dm=mean(prop_age1524_DM, na.rm=TRUE), 
            total_crime_rtdm=mean(total_crime_rate_old_DM, na.rm=TRUE),
            employment_rate_dm=mean(employment_rate_DM, na.rm=TRUE),
            percap_income_dm=mean(percap_income_DM, na.rm=TRUE), 
            violent_rate_old_dm=mean(violent_rate_old_DM, na.rm=TRUE))


#28
#To check the first half of the variables
corr1 <- school_dm_final %>%   #Creates a nice, clean correlation dataframe.
  correlate() %>%    # Create correlation data frame (cor_df)
  focus(county_enroll_DM,population_DM,prop_nonwhite_DM,prop_male_DM,prop_age1524_DM, mirror = TRUE) %>%  
  rearrange() %>%  # rearrange by correlations
  shave() # Shave off the upper triangle for a clean result

#To check the second half of the variables
corr2 <- school_dm_final %>%  #Creates a nice, clean correlation dataframe.
  correlate() %>%    # Create correlation data frame (cor_df)
  focus(county_enroll_DM, violent_rate_old_DM, new_violent_rate_DM, percap_income_DM, employment_rate_DM, mirror = TRUE) %>%  # Focus on cor_df without 'cyl' and 'vs'
  rearrange() %>%  # rearrange by correlations
  shave() # Shave off the upper triangle for a clean result





#29

predictors <- c("year", "population_DM", "prop_nonwhite_DM", "prop_age1524_DM", "total_crime_rate_old_DM", "employment_rate_DM", "percap_income_DM", "violent_rate_old_DM", "new_violent_rate_DM")

# individual regressions
single_regressions <- lapply(predictors, function(predictor) {
  formula <- as.formula(paste("county_enroll_DM ~", predictor))
  lm(formula, data = school_dm_final)
})


single_regression_summaries <- lapply(single_regressions, summary)

# Displaying summaries
for (i in 1:length(predictors)) {
  cat("Regression with predictor:", predictors[i], "\n")
  print(single_regression_summaries[[i]]$coefficients) # Show coefficients and p-values
  cat("\n")
}


# Final regression model
final_model <- lm(
  county_enroll_DM ~ prop_nonwhite_DM + prop_age1524_DM + violent_rate_old_DM + year,
  data = school_dm_final)

summary(final_model)












