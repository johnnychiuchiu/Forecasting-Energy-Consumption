library(dplyr)
library(readr)
library(forecast)
source('ts_function.R')

##### Read Data
train_15min = read.csv('data/train_15min_cleaned.csv')
test_15min = read.csv('data/test_15min.csv')
test_15min = test_15min %>% mutate(Value = NA) 

train_1hour = read.csv('data/train_1hour_cleaned.csv')
test_1hour = read.csv('data/test_1hour.csv')
test_1hour = test_1hour %>% mutate(Value = NA) 

train_1day = read.csv('data/train_1day_cleaned.csv')
test_1day = read.csv('data/test_1day.csv')
test_1day = test_1day %>% mutate(Value = NA) 


########### Fit arima with predictor for 1 day
# bind train with test
temp <- train_1day %>% 
  select(obs_id, SiteId, Timestamp, Value, Weekday, OnAndOff, ForecastId, isHoliday)
temp2 <- test_1day %>% 
  select(obs_id, SiteId, Timestamp, Value, Weekday, OnAndOff,ForecastId, isHoliday)
combined_1day <- rbind(temp,temp2)

# sort
combined_1day <- combined_1day %>% arrange(SiteId,Timestamp)

site1 = combined_1day %>% filter(SiteId==1)

#### Fit arima
final_1day=data.frame()
for (site in unique(combined_1day$SiteId)){
  print(paste("SiteId:",site))
  site_result = predict_for_site_arima_with_feature(combined_1day %>% filter(SiteId==site))
  final_1day = rbind(final_1day, site_result)
}

########### Fit arima with predictor for 1 hour
# bind train with test
temp <- train_1hour %>% 
  select(SiteId, Timestamp, Value, obs_id)
temp2 <- test_1hour %>% 
  mutate(Value = NA) %>%
  select(SiteId, Timestamp, Value, obs_id)
combined_1hour <- rbind(temp,temp2)

# sort
combined_1hour <- combined_1hour %>% arrange(SiteId,Timestamp)

#### Fit arima
final_1hour=data.frame()
for (site in unique(combined_1hour$SiteId)){
  print(paste("SiteId:",site))
  site_result = predict_for_site_arima_with_feature(combined_1hour %>% filter(SiteId==site))
  final_1hour = rbind(final_1hour, site_result)
}


########### Fit arima with predictor for 15 min
# bind train with test
temp <- train_15min %>% 
  select(SiteId, Timestamp, Value, obs_id)
temp2 <- test_15min %>% 
  mutate(Value = NA) %>%
  select(SiteId, Timestamp, Value, obs_id)
combined_15min <- rbind(temp,temp2)

# sort
combined_15min <- combined_15min %>% arrange(SiteId,Timestamp)

#### Fit arima
final_15min=data.frame()
for (site in unique(combined_15min$SiteId)){
  print(paste("SiteId:",site))
  site_result = predict_for_site_arima_with_feature(combined_15min %>% filter(SiteId==site))
  final_15min = rbind(final_15min, site_result)
}


######## Generate submission file
##### Generate submission file
test_1day_arima = final_1day %>% filter(obs_id %in% test_1day$obs_id) 
test_1day_arima = merge(test_1day_arima, test_1day %>% select(obs_id, ForecastId),by='obs_id',all.x= TRUE)
test_1day_arima = test_1day_arima %>% select(colnames(test_1day)) %>% arrange(SiteId, ForecastId, Timestamp)

test_1hour_arima = final_1hour %>% filter(obs_id %in% test_1hour$obs_id) 
test_1hour_arima = merge(test_1hour_arima, test_1hour %>% select(obs_id, ForecastId),by='obs_id',all.x= TRUE)
test_1hour_arima = test_1hour_arima %>% select(colnames(test_1hour)) %>% arrange(SiteId, ForecastId, Timestamp)

test_15min_arima = final_15min %>% filter(obs_id %in% test_15min$obs_id) 
test_15min_arima = merge(test_15min_arima, test_15min %>% select(obs_id, ForecastId),by='obs_id',all.x= TRUE)
test_15min_arima = test_15min_arima %>% select(colnames(test_15min)) %>% arrange(SiteId, ForecastId, Timestamp)


autoarima_all = rbind(test_1day_arima, test_1hour_arima)
autoarima_all = rbind(autoarima_all, test_15min_arima)
autoarima_all = autoarima_all %>% arrange(SiteId, Timestamp, ForecastId)

write.csv(autoarima_all, file='submission/auto_arima.csv', row.names = FALSE)


