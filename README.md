# School_Enrollment-Project


This repository contains the School Enrollment Analysis Project, a data-driven study for Data Science II (Fall 2024) by Sangam Dhakal. The project integrates various datasets to analyze school enrollments in the United States from 1990 to 2001, linking them with demographic, economic, and crime data.


Introduction
The School Enrollment Analysis Project aims to explore trends and factors affecting school enrollments across U.S. counties during the 1990–2001 period. By integrating enrollment data with demographic, economic, and crime datasets, the project provides insights into the key predictors of enrollment patterns.


Datasets Used
The following datasets were used for this project:

1.ELSI School Enrollment Data (1990–2001): Raw and cleaned data on school enrollments.
2.School County Data: Includes county-level identifiers for schools.
3.Census Data: Contains demographic statistics (e.g., population, race, age groups).
4.Uniform Crime Reporting (UCR) Data: Crime rates and counts by county.
5.Economic Data: County-level economic indicators (e.g., income, employment).



Key Objectives:
1.Analyze school enrollment trends over time.
2.Understand the influence of demographic, crime, and economic factors on school enrollments.
3.Develop regression models to predict enrollment patterns.
4.Visualize trends and correlations using summary statistics and correlation matrices.



Methodology
Data Cleaning:

Removed invalid or missing values.
Normalized column names for consistency.

Data Integration:
Merged multiple datasets using county-level identifiers (FIPS codes).

Transformations:
Generated derived metrics (e.g., enrollment deviations, crime rates per 100,000 people).
Adjusted for differences using mean deviations.

Regression Analysis:
Conducted individual regressions for multiple predictors.
Built a final regression model to analyze the combined impact of key factors.

Outputs:
Exported clean and merged datasets for further analysis and visualization.



Outputs
Cleaned Data:
county_year_enrollment.csv: Aggregated enrollment data by county and year.
census_clean.csv: Processed census data with key demographic metrics.

Merged Dataset:
final_merged_data2: Comprehensive dataset combining all sources.

Regression Results:
Summarized individual and combined regression outputs.

Visualizations:
Correlation matrices for key variables.
Descriptive statistics and trends.
