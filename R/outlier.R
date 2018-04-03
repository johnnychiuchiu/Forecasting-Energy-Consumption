library(dplyr)
library(readr)
library(forecast)

##### Read Data
train_15min = read.csv('data/train_15min.csv')
test_15min = read.csv('data/test_15min.csv')
test_15min = test_15min %>% mutate(Value = NA) 

train_1hour = read.csv('data/train_1hour.csv')
test_1hour = read.csv('data/test_1hour.csv')
test_1hour = test_1hour %>% mutate(Value = NA) 

train_1day = read.csv('data/train_1day.csv')
test_1day = read.csv('data/test_1day.csv')
test_1day = test_1day %>% mutate(Value = NA) 


# get unique siteId for 1 day data
unique(train_15min$SiteId)
unique(train_1hour$SiteId)
unique(train_1day$SiteId)


# check outlier for train data
site_15mins = train_15min %>% filter(SiteId == 194)

View(check_outlier(site_15mins, 'Value', 390))
t = replace_outlier(site_15mins, 'Value', 390)

##### Replace outlier for 1 day data
train_cleaned_1day <- data.frame()

for (site in unique(train_1day$SiteId)){
  print(paste("SiteId:",site))
  site_result = replace_outlier(train_1day %>% filter(SiteId==site), 'Value', 50)
  train_cleaned_1day = rbind(train_cleaned_1day, site_result)
}

table(train_cleaned_1day$Value == train_1day$Value)


##### Replace outlier for 1 hour data
train_cleaned_1hour <- data.frame()

for (site in unique(train_1hour$SiteId)){
  print(paste("SiteId:",site))
  site_result = replace_outlier(train_1hour %>% filter(SiteId==site), 'Value', 50)
  train_cleaned_1hour = rbind(train_cleaned_1hour, site_result)
}

table(train_cleaned_1hour$Value == train_1hour$Value)


##### Replace outlier for 15 mins data
train_cleaned_15min <- data.frame()

for (site in unique(train_15min$SiteId)){
  print(paste("SiteId:",site))
  site_result = replace_outlier(train_15min %>% filter(SiteId==site), 'Value', 50)
  train_cleaned_15min = rbind(train_cleaned_15min, site_result)
}

table(train_cleaned_15min$Value == train_15min$Value)

write.csv(train_cleaned_1day, file='data/train_1day_cleaned.csv', row.names = FALSE)
write.csv(train_cleaned_1hour, file='data/train_1hour_cleaned.csv', row.names = FALSE)
write.csv(train_cleaned_15min, file='data/train_15min_cleaned.csv', row.names = FALSE)









