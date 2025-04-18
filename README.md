# Cycle Analysis
### Data Cleaning Steps:

1. **Read the Data**: 
   - Import CSV files for the 2019 Q1 and 2020 Q1 Divvy bike trips data using `read_csv()`.
   - Specify column types for accurate parsing of data, especially date-time columns.
   
2. **Rename Columns**:
   - Rename columns to match appropriate naming conventions for consistency (e.g., `trip_id` to `ride_id`, `bikeid` to `rideable_type`).

3. **Drop Extra Columns**:
   - Remove irrelevant columns like `gender` and `birthyear` from the 2019 Q1 data.
   
4. **Ensure Consistent Column Data Types**:
   - Convert `ride_id` to a character type in both dataframes for consistency.

5. **Handle Missing/Extra Columns**:
   - Drop unnecessary columns from the 2020 Q1 dataset (e.g., `start_lat`, `start_lng`, etc.) that are not needed for analysis.

6. **Combine Data**:
   - Use `bind_rows()` to combine the two datasets into one dataframe (`data`), ensuring they have the same structure.

7. **Convert Date Columns**:
   - Ensure the `started_at` and `ended_at` columns are in `POSIXct` format for proper date-time operations.

8. **Calculate Ride Duration**:
   - Create a new column `ride_duration` by calculating the difference between `ended_at` and `started_at` (in minutes).

9. **Filter Out Negative Ride Durations**:
   - Remove rows with negative or zero ride durations, ensuring only valid rides are kept.

10. **Recode Member Type**:
    - Rename the values in `member_casual` column to use more descriptive labels (`Customer` to `casual` and `Subscriber` to `member`).

---

### Exploratory Data Analysis (EDA) Steps:
1. **Summary Statistics**:
   - Calculate and print summary statistics (e.g., mean, median, max, min) for ride duration, grouped by `member_casual` (e.g., casual vs member riders).

2. **Analysis by Day**:
   - Summarize ride duration by day of the week, grouping by `member_casual` and `weekdays(started_at)`, to explore how ride durations vary across days and between member types.

3. **Additional Calculations**:
   - Calculate the overall **mean**, **max**, and **mode** of ride durations and day of the week.

4. **Pivot Tables**:
   - Calculate average ride duration by `member_casual` and by `day_of_week`.
   - Count the number of rides for each `member_casual` type grouped by day of the week.

5. **Visualizations**:
   - **Bar Plot for Rides by Day**: Visualize the number of rides by day of the week for each rider type (`member_casual`).
   - **Mean Ride Duration by Day and Member Type**: Plot the average ride duration for each day of the week, broken down by rider type.
   - **Average Ride Length for Members and Casual Riders**: Visualize the average ride length for casual vs member riders.
   - **Average Ride Length by Day of Week**: Visualize the average ride length for different days of the week, by member type.
   - **Number of Rides by Day of Week**: Visualize the number of rides each day by member type.

   These visualizations are saved as PNG files for further analysis or reporting.

These steps systematically clean the data and explore various aspects, like ride duration and frequency, to uncover insights based on member type and time-based patterns.
