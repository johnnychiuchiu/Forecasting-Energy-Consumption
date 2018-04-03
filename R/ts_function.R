library(psych)

##### General functions
slice_data <- function(data){
  for (index in c(2:nrow(data))){
    if (!is.na(data$Value[index]) & is.na(data$Value[index-1]) & 
        index !=1){
      return (index - 1)
      # case where NA is at end
    }else if (is.na(data$Value[index]) & index == nrow(data)){
      return (index)
    }
  }
  return (-1) # cannot slice
}

get_last_train <- function(data){
  # Get the index for the last train in each chunk
  my_ind <- -1
  
  for (index in c(2:nrow(data))){
    if (!is.na(data$Value[index]) & is.na(data$Value[index+1]) & index !=1){
      my_ind <- index
      break
    }
  }
  my_ind
}


##### Holtwinter related
predict_ts <- function(train, n_pred, seasonal, frequency){
  # make time series prediction for each of the NA chunk the input data
  if (frequency != -1){
    freq <- frequency # user_specified
  }else{
    freq <- nrow(train)/2
  }
  
  y<-ts(train %>% select(Value), frequency=freq)
  EWMA<-HoltWinters(y, seasonal = seasonal) 
  EWMApred<-predict(EWMA, n.ahead=n_pred, prediction.interval = T, level = 0.95)
  return(EWMApred[,1])
}

predict_for_site_holt <- function(data){
  # fill all the NA value for each site
  i=1
  while (slice_data(data)!=-1){
    print(paste("NA chunk No.",i))
    na_last = slice_data(data)
    train_last = get_last_train(data)
    n_pred = na_last-train_last
    
    EWMApred = predict_ts(data[1:train_last,], n_pred, seasonal='additive',-1)
    data[(train_last+1):na_last,]$Value = as.numeric(EWMApred[,1])
    i= i+1
  }
  return(data)
}

##### Auto.arima related

predict_arima <- function(train, n_pred){
  # make time series prediction for each of the NA chunk the input data using ARIMA
  
  fit_arima = auto.arima(train %>% select(Value))
  return(as.numeric(forecast(fit_arima, n_pred)$mean))
}

predict_for_site_arima <- function(data){
  # fill all the NA value for each site, currently use ARIMA without feature
  i=1
  while (slice_data(data)!=-1){
    print(paste("NA chunk No.",i))
    na_last = slice_data(data)
    train_last = get_last_train(data)
    n_pred = na_last-train_last
    
    pred_result = predict_arima(data[1:train_last,], n_pred)
    data[(train_last+1):na_last,]$Value = as.numeric(pred_result)
    i= i+1
  }
  return(data)
}

##### Arima with feature
predict_arima_with_feature <- function(train, test, n_pred){
  # make time series prediction for each of the NA chunk the input data using ARIMA
  
  # get best parameter
  fit_auto = auto.arima(train$Value)
  best_param = arimaorder(fit_auto)
  
  # get predictor
  xreg_train <- cbind(train$Weekday, as.factor(train$OnAndOff))
  
  # manually fit arima # reference: https://stackoverflow.com/questions/29522841/the-curious-case-of-arima-modelling-using-r
  fit_arima = arima(train$Value/10, best_param, xreg=xreg_train) #RMSE = 320.241
  
  # make prediction
  xreg_test = cbind(test$Weekday, as.factor(test$OnAndOff)) #192 obs
  pred_result = forecast(fit_arima, h=n_pred, xreg=xreg_test)
  pred_result = 10*as.numeric(pred_result$mean)
  
  return(pred_result)
}



predict_for_site_arima_with_feature <- function(data){
  # fill all the NA value for each site, currently use ARIMA without feature
  i=1
  while (slice_data(data)!=-1){
    print(paste("NA chunk No.",i))
    na_last = slice_data(data)
    train_last = get_last_train(data)
    n_pred = na_last-train_last
    
    pred_result = predict_arima_with_feature(data[1:train_last,], data[(train_last+1):na_last,], n_pred)
    data[(train_last+1):na_last,]$Value = as.numeric(pred_result)
    i= i+1
  }
  return(data)
}

##### Deal wtih outlier
check_outlier <- function(df, name, sd_cutoff){
  # Using standard deviation to check the outlier for numerical columns
  #
  # Parameters
  # ----------
  # df: data.frame
  # name: chr
  #    the column we want to check for outliers
  # sd_cutoff: num
  #    a number indicating how many standard deviation away from the mean
  # @return: None
  
  print(describe(df[,name])[c('mean','sd')])
  mean = as.numeric(describe(df[,name])['mean'])
  sd = as.numeric(describe(df[,name])['sd'])
  condition = paste(name, '<', mean , '-' , sd_cutoff, '*', sd, '|', 
                    name, '>', mean , '+' , sd_cutoff, '*', sd, sep='' )
  df %>% dplyr::filter_(condition)
}

rm_outlier <- function(df, name, sd_cutoff){
  # Remove rows that is outlier defined by standard deviation away from the mean
  #
  # Parameters
  # ----------
  # df: data.frame
  # name: chr
  #    the column we want to check for outliers
  # sd_cutoff: num
  #    a number indicating how many standard deviation away from the mean
  # @return: data.frame
  #    a dataframe removing outliers according to the input condition 
  
  print(describe(df[,name])[c('mean','sd')])
  mean = as.numeric(describe(df[,name])['mean'])
  sd = as.numeric(describe(df[,name])['sd'])
  condition = paste(name, '>=', mean , '-' , sd_cutoff, '*', sd, '&', 
                    name, '<=', mean , '+' , sd_cutoff, '*', sd, sep='' )
  return(df %>% filter_(condition))
}

replace_outlier <- function(df, name, sd_cutoff){
  df_filtered = rm_outlier(df, name, sd_cutoff)
  print(dim(df)[1]-dim(df_filtered)[1])
  
  mean = as.numeric(describe(df[,name])['mean'])
  sd = as.numeric(describe(df[,name])['sd'])
  thres_upper = mean + sd*sd_cutoff
  print(thres_upper)
  thres_lower = mean - sd*sd_cutoff
  print(thres_lower)
  
  df[,name] = ifelse(df[,name]>thres_upper, max(df_filtered[,name]), df[,name])
  df[,name] = ifelse(df[,name]<thres_lower, min(df_filtered[,name]), df[,name])
  return(df)
}




