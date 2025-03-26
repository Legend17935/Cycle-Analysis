install.packages("languageserver")
install.packages("readr")
install.packages("vscDebugger")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("gridExtra")
install.packages("openxlsx")

# Load the packages
library(readr)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(openxlsx)

# Read the CSV files into dataframes
df1 <- read_csv("Divvy_Trips_2019_Q1 - Divvy_Trips_2019_Q1.csv", col_types = cols(
  trip_id = col_character(),
  bikeid = col_character(),
  start_time = col_datetime(format = "%Y-%m-%d %H:%M:%S"),
  end_time = col_datetime(format = "%Y-%m-%d %H:%M:%S"),
  from_station_name = col_character(),
  from_station_id = col_character(),
  to_station_name = col_character(),
  to_station_id = col_character(),
  tripduration = col_double(),
  usertype = col_character()
))
print("Data Summary for 2019 Q1:")
print(summary(df1))

# Rename columns in df1 to align with data and drop extra columns
df1 <- df1 %>% rename(
  ride_id = trip_id,
  rideable_type = bikeid,
  started_at = start_time,
  ended_at = end_time,
  start_station_name = from_station_name,
  start_station_id = from_station_id,
  end_station_name = to_station_name,
  end_station_id = to_station_id,
  member_casual = usertype
) %>% select(-c(gender, birthyear))

# Print the updated df1 summary
print("Updated Data Summary for 2019 Q1:")
print(summary(df1))

# Attempt to read the 2020 Q1 file (may need to handle large file size)
df2 <- read_csv("Divvy_Trips_2020_Q1 - Divvy_Trips_2020_Q1.csv", col_types = cols(
  ride_id = col_character(),
  rideable_type = col_character(),
  started_at = col_datetime(format = "%Y-%m-%d %H:%M:%S"),
  ended_at = col_datetime(format = "%Y-%m-%d %H:%M:%S"),
  start_station_name = col_character(),
  start_station_id = col_character(),
  end_station_name = col_character(),
  end_station_id = col_character(),
  member_casual = col_character()
))
print("Data Summary for 2020 Q1:")
print(summary(df2))

# Ensure ride_id is character in both dataframes
df1 <- df1 %>% mutate(ride_id = as.character(ride_id))
df2 <- df2 %>% mutate(ride_id = as.character(ride_id))

# Drop columns from df2
columns_to_drop <- c("start_lat", "start_lng", "end_lat", "end_lng")
df2 <- df2 %>% select(-all_of(columns_to_drop))

# Union df1 and df2 by column names and put it in data
data <- bind_rows(df1, df2, .id = NULL)

# Print the combined data summary
print("Combined Data Summary:")
print(summary(data))


# Data Cleaning
# Convert date columns to Date type
data$started_at <- as.POSIXct(data$started_at, format="%Y-%m-%d %H:%M:%S")
data$ended_at <- as.POSIXct(data$ended_at, format="%Y-%m-%d %H:%M:%S")

# Calculate ride duration
ride_duration <- abs(difftime(data$ended_at, data$started_at, units="mins"))
data$ride_duration <- as.numeric(ride_duration)

# Remove negative ride durations
data <- data %>% filter(ride_duration > 0)

# Rename Customer to casual and Subscriber to member in column member_casual
data <- data %>% mutate(member_casual = recode(member_casual, 'Customer' = 'casual', 'Subscriber' = 'member'))

# Print the updated data summary
print("Updated Data Summary with renamed member_casual:")
print(summary(data))

# Print cleaned data summary
print("Cleaned Data Summary:")
print(summary(data))

# Exploratory Data Analysis
# Compare ride duration between member types
ride_duration_summary <- data %>% group_by(member_casual) %>% summarise(mean_duration = mean(ride_duration), median_duration = median(ride_duration), max_duration = max(ride_duration), min_duration = min(ride_duration))
print("Ride Duration Summary:")
print(ride_duration_summary)

# Compare ride duration between member types for each day
ride_duration_summary_by_day <- data %>% group_by(member_casual, day = weekdays(started_at)) %>% summarise(mean_duration = mean(ride_duration), median_duration = median(ride_duration), max_duration = max(ride_duration), min_duration = min(ride_duration))
print("Ride Duration Summary by Day:")
print(ride_duration_summary_by_day)

# Additional Calculations
# Calculate the mean of ride_length
mean_ride_length <- mean(data$ride_duration)
print(paste("Mean Ride Length:", mean_ride_length))

# Calculate the max ride_length
max_ride_length <- max(data$ride_duration)
print(paste("Max Ride Length:", max_ride_length))

# Calculate the mode of day_of_week
mode_day_of_week <- as.character(names(sort(table(weekdays(data$started_at)), decreasing=TRUE)[1]))
print(paste("Mode of Day of Week:", mode_day_of_week))

# Pivot Tables
# Calculate the average ride_length for members and casual riders
pivot_avg_ride_length <- data %>% group_by(member_casual) %>% summarise(avg_ride_length = mean(ride_duration))
print("Pivot Table - Average Ride Length for Members and Casual Riders:")
print(pivot_avg_ride_length)

# Calculate the average ride_length for users by day_of_week
pivot_avg_ride_length_by_day <- data %>% group_by(member_casual, day_of_week = weekdays(started_at)) %>% summarise(avg_ride_length = mean(ride_duration))
print("Pivot Table - Average Ride Length by Day of Week:")
print(pivot_avg_ride_length_by_day)

# Calculate the number of rides for users by day_of_week
pivot_count_rides_by_day <- data %>% group_by(member_casual, day_of_week = weekdays(started_at)) %>% summarise(count_rides = n())
print("Pivot Table - Number of Rides by Day of Week:")
print(pivot_count_rides_by_day)

# Visualizations
# Number of rides by day of the week
p2 <- ggplot(data, aes(x=weekdays(started_at), fill=member_casual)) + geom_bar(position="dodge") + labs(title="Number of Rides by Day of the Week", x="Day of the Week", y="Count")
print(p2)
ggsave("rides_by_day_of_week.png", plot=p2)

# Ride duration distribution by day and member type
p3 <- ggplot(ride_duration_summary_by_day, aes(x=day, y=mean_duration, fill=member_casual)) + geom_bar(stat="identity", position="dodge") + labs(title="Mean Ride Duration by Day and Member Type", x="Day of the Week", y="Mean Ride Duration (minutes)")
print(p3)
ggsave("ride_duration_by_day_and_member_type.png", plot=p3)

# Save pivot tables as images
# Save the average ride_length for members and casual riders
p4 <- ggplot(pivot_avg_ride_length, aes(x=member_casual, y=avg_ride_length, fill=member_casual)) + geom_bar(stat="identity") + labs(title="Average Ride Length for Members and Casual Riders", x="Member Type", y="Average Ride Length (minutes)")
print(p4)
ggsave("avg_ride_length_members_casual.png", plot=p4)

# Save the average ride_length for users by day_of_week
p5 <- ggplot(pivot_avg_ride_length_by_day, aes(x=day_of_week, y=avg_ride_length, fill=member_casual)) + geom_bar(stat="identity", position="dodge") + labs(title="Average Ride Length by Day of Week", x="Day of the Week", y="Average Ride Length (minutes)")
print(p5)
ggsave("avg_ride_length_by_day.png", plot=p5)

# Save the number of rides for users by day_of_week
p6 <- ggplot(pivot_count_rides_by_day, aes(x=day_of_week, y=count_rides, fill=member_casual)) + geom_bar(stat="identity", position="dodge") + labs(title="Number of Rides by Day of Week", x="Day of the Week", y="Number of Rides")
print(p6)
ggsave("count_rides_by_day.png", plot=p6)

# Summary and Recommendations
# 1. Annual members have shorter and more consistent ride durations compared to casual riders.
# 2. Casual riders tend to ride more on weekends, while annual members have a more even distribution throughout the week.
# 3. To convert casual riders to annual members, Cyclistic can offer promotions and discounts on weekends and holidays.
# 4. Digital media campaigns can target casual riders with messages highlighting the benefits of annual memberships, such as cost savings and convenience.
# Summary and Recommendations
# 1. Annual members have shorter and more consistent ride durations compared to casual riders.
# 2. Casual riders tend to ride more on weekends, while annual members have a more even distribution throughout the week.
# 3. To convert casual riders to annual members, Cyclistic can offer promotions and discounts on weekends and holidays.
# 4. Digital media campaigns can target casual riders with messages highlighting the benefits of annual memberships, such as cost savings and convenience.

