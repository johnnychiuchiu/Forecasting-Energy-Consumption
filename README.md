# Forecasting-Energy-Consumption

It is a competition hosted by DrivenData. You can find a full description of the competition [[here](https://www.drivendata.org/competitions/51/electricity-prediction-machine-learning/)].

The objective is to forecast energy consumption from the following data:
* Historical building consumption data
* Historical weather data and weather forecast for one or a few places geographically close to the building
* Calendar information, identifying working and off days
* Meta-data about the building, e.g., whether it is an office space, a restaurant, etc.

Our team result in 71th place in the competition


## Documentation

**Data Transformation**
* `merge_table.ipynb` data manipulation for train data [[python nbviewer](http://nbviewer.jupyter.org/github/johnnychiuchiu/Forecasting-Energy-Consumption/blob/master/python/merge_table.ipynb)]
* `merge_table_test.ipynb` data manipulation for test data [[python nbviewer](http://nbviewer.jupyter.org/github/johnnychiuchiu/Forecasting-Energy-Consumption/blob/master/python/merge_table_test.ipynb)]

**Outlier**
* `outlier.R` Replace outliers according to standard deviation[[R script](https://github.com/johnnychiuchiu/Forecasting-Energy-Consumption/blob/master/R/outlier.R)]

**HoltWinter**
* `weather_1d.Rmd` | `weather_1h.Rmd` | `weather_15min.Rmd` time series model building combining previous result to make future prediction [[Rmd for 1d](https://github.com/johnnychiuchiu/Forecasting-Energy-Consumption/blob/master/R/weather_1d.Rmd), [Rmd for 1h](https://github.com/johnnychiuchiu/Forecasting-Energy-Consumption/blob/master/R/weather_1h.Rmd), [Rmd for 15mins](https://github.com/johnnychiuchiu/Forecasting-Energy-Consumption/blob/master/R/weather_15min.Rmd)]

**HoltWinter using only current period**
* `weather_1d_using_current.Rmd` | `weather_1h_using_current.Rmd` | `weather_15min_using_current.Rmd` time series model building using only current period [[Rmd for 1d](https://github.com/johnnychiuchiu/Forecasting-Energy-Consumption/blob/master/R/weather_1d_using_current.Rmd), [Rmd for 1h](https://github.com/johnnychiuchiu/Forecasting-Energy-Consumption/blob/master/R/weather_1h_using_current.Rmd), [Rmd for 15mins](https://github.com/johnnychiuchiu/Forecasting-Energy-Consumption/blob/master/R/weather_15min_using_current.Rmd)]


**Auto Arima**
* `autoarima.R` time series model building using auto.arima [[R script](https://github.com/johnnychiuchiu/Forecasting-Energy-Consumption/blob/master/R/autoarima.R)]

**Arima with features**
* `arima_with_feature.R` time series model building using arima with some features [[R script](https://github.com/johnnychiuchiu/Forecasting-Energy-Consumption/blob/master/R/arima_with_feature.R)]

## Directory Structure

```
project
|   README.md
|   .gitignore
|
|__ data: all the project related data including the submission files
|
|__ python: scripts in python, mostly related to data manipulation for the project
|
|__ R: script and Rmd in R, mostly related model building for time series.
```
