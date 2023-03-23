# Step 1: Load libraries and data----
library(gbm)
library(dplyr)
library(rsample)
library(tidyverse)
historic_df <- read.csv("historic_property_data.csv")
predict_df <- read.csv("predict_property_data.csv")

# Step 2: Preparing data in historic property data----
# Retain some of the variables
features <- c("meta_nbhd", "geo_school_hs_district", "geo_school_elem_district", "meta_town_code", 
              "econ_midincome", "char_bldg_sf", "econ_tax_rate", "char_fbath",
              "char_rooms", "char_frpl", "char_age", "char_hd_sf", 
              "char_beds", "char_type_resd", "char_air", "char_ext_wall",
              "char_bsmt", "char_use", "char_hbath", "char_gar1_size",
              "char_tp_dsgn", "char_gar1_att", "char_apts")

# Create new data frame that will be used to train the model later
feature_df <- historic_df[c('sale_price', features)]

# Convert variables to categorical variables
feat2factor <- c('meta_nbhd', 'geo_school_hs_district', 'geo_school_elem_district', 'meta_town_code',
                 'char_type_resd', 'char_air', 'char_ext_wall', 'char_bsmt',
                 'char_use', 'char_gar1_size', 'char_tp_dsgn', 'char_gar1_att',
                 'char_apts')
for (i in 1:ncol(feature_df)) {
  print(paste0(i, ' ',sum(is.na(feature_df[, i]))))}

# Deals with NA
# Remove some of the rows that consist NA
feature_df <- feature_df[!is.na(feature_df$geo_school_elem_district), ]
feature_df <- feature_df[!is.na(feature_df$geo_school_hs_district), ]
feature_df <- feature_df[!is.na(feature_df$char_type_resd), ]
feature_df <- feature_df[!is.na(feature_df$char_air), ]

# Fill in NA with some specific values 
feature_df$econ_midincome[is.na(feature_df$econ_midincome)] <- median(feature_df$econ_midincome, na.rm = TRUE)
feature_df$char_frpl[is.na(feature_df$char_frpl)] <- 0
feature_df$char_ext_wall[is.na(feature_df$char_ext_wall)] <- 2
feature_df$char_bsmt[is.na(feature_df$char_bsmt)] <- 1
feature_df$char_use[is.na(feature_df$char_use)] <- 1
feature_df$char_gar1_size[is.na(feature_df$char_gar1_size)] <- 1
feature_df$char_gar1_att[is.na(feature_df$char_gar1_att)] <- 2

# Create three variables: poly_char_hd_sf, poly_char_age, and poly_char_bldg_sf
feature_df$poly_char_hd_sf <- (feature_df$char_hd_sf)^2
feature_df$poly_char_age <- (feature_df$char_age)^2
feature_df$poly_char_bldg_sf <- (feature_df$char_bldg_sf)^2

# Remove outliers
feature_df <- feature_df[-which(feature_df$sale_price > 10000000), ]
feature_df <- feature_df[-which(feature_df$sale_price < 1000), ]

for (feat in feat2factor) {
  feature_df[, feat] <- as.factor(feature_df[, feat])}

feature_df <- feature_df[,-c(22,24)]

# Step 3: Training model with Gradient Boosting Machines----
# Create hyper parameter grid
hyper_grid <- expand.grid(
  shrinkage = c(.01, .05, .1),
  interaction.depth = c(3, 5, 7),
  n.minobsinnode = c(10, 15, 20),
  bag.fraction = c(.65, .8, 1), 
  optimal_trees = 0,               
  min_RMSE = 0)

# Total number of combinations
nrow(hyper_grid)

# Create training set(70%) and testing set(30%)
set.seed(123)
split <- initial_split(feature_df, prop = .7)
feature_df_train<- training(split)
feature_df_test<- testing(split)

# Randomize training set
set.seed(123)
random_index <- sample(1:nrow(feature_df_train), nrow(feature_df_train))
random_feature_df_train <- feature_df_train[random_index, ]

# Grid search 
for(i in 1:nrow(hyper_grid)) {
  set.seed(123)
  
  # Train model with GBM function
  gbm.tune <- gbm(
    formula = sale_price ~ .,
    distribution = "gaussian",
    data = random_feature_df_train,
    n.trees = 5000,
    interaction.depth = hyper_grid$interaction.depth[i],
    shrinkage = hyper_grid$shrinkage[i],
    n.minobsinnode = hyper_grid$n.minobsinnode[i],
    bag.fraction = hyper_grid$bag.fraction[i],
    train.fraction = .75,
    n.cores = NULL,
    verbose = FALSE)
  
  # Add MSE and trees to grid
  hyper_grid$optimal_trees[i] <- which.min(gbm.tune$valid.error)
  hyper_grid$min_MSE[i] <- min(gbm.tune$valid.error) #MSE
}

# Get the best 10 results: The first row indicate the optimal result
hyper_grid %>% dplyr::arrange(min_MSE) %>% head(10)
min_mse <- which.min(hyper_grid$min_MSE)

# fit.final
set.seed(123)
gbm.fit.final <- gbm(
  formula = sale_price ~ .,
  distribution = "gaussian",
  data = feature_df_train,
  n.trees = hyper_grid$optimal_trees[min_mse],
  interaction.depth = hyper_grid$interaction.depth[min_mse],
  shrinkage = hyper_grid$shrinkage[min_mse],
  n.minobsinnode = hyper_grid$n.minobsinnode[min_mse],
  bag.fraction = hyper_grid$bag.fraction[min_mse], 
  train.fraction = 1,
  n.cores = NULL,
  verbose = FALSE)  

# visualizing
par(mar = c(5, 8, 1, 1))

# Summary of the fit.final
summary(
  gbm.fit.final, 
  cBars = 10,
  method = relative.influence, 
  las = 2)

# Step 4: Predict on testing set----
pred <- predict(gbm.fit.final, n.trees = gbm.fit.final$n.trees, feature_df_test)

# Calculate MSE on testing set
MSE <- mean((pred-feature_df_test$sale_price)^2)

# Step 5: Preparing data in predict property data----
# Deals with NA: fill in NA with some specific values
predict_df$econ_midincome[is.na(predict_df$econ_midincome)] <- median(predict_df$econ_midincome, na.rm = TRUE)
predict_df$char_frpl[is.na(predict_df$char_frpl)] <- 0
predict_df$char_ext_wall[is.na(predict_df$char_ext_wall)] <- 2
predict_df$char_bsmt[is.na(predict_df$char_bsmt)] <- 1
predict_df$char_use[is.na(predict_df$char_use)] <- 1
predict_df$char_gar1_size[is.na(predict_df$char_gar1_size)] <- 1
predict_df$char_gar1_att[is.na(predict_df$char_gar1_att)] <- 2

# Create three variables: poly_char_hd_sf, poly_char_age, and poly_char_bldg_sf
predict_df$poly_char_hd_sf <- (predict_df$char_hd_sf)^2
predict_df$poly_char_age <- (predict_df$char_age)^2
predict_df$poly_char_bldg_sf <- (predict_df$char_bldg_sf)^2 

# Step 6: Final prediction on predict property data----
pred_final <- predict(gbm.fit.final, n.trees = gbm.fit.final$n.trees, predict_df)

# Step 7: Check the result and Export to csv----
assessed_value <- data.frame(matrix(ncol = 2, nrow = 10000))
colnames(assessed_value) <- c("pid", "assessed_value")
assessed_value[,1] <- 1:10000
assessed_value[,2] <- pred_final

# Check whether the result contains NA, zero, or negative number
isna <- sum(is.na(assessed_value[,2]))
equal0 <- sum(assessed_value[,2]==0)
negative <- sum(assessed_value[,2]<0)

# Export to csv
write.csv(assessed_value,"assessed_value.csv", row.names = FALSE)

# Step 8: Create summary statistics----
assessed_value <- read.csv('assessed_value.csv')
summary(assessed_value$assessed_value)
options(scipen = 999)

# Create distribution of the assessed property values
assessed_value %>% 
  ggplot(aes(x=assessed_value))+
  geom_histogram(color="black", fill="white", bins = 100)+
  labs(title="Distribution of assessed property values",x="Assessed Value", y="Count")+
  theme_minimal()
