## Property Assessment Challenge
This project aims to determine a fair market value of each property in the City of Chicago. Determining what is a fiar market value with this diversity of parcels that are spread across over 130 municipalities is one of the most complex valuation tasks in the United States. We are using the data from Cook County Assessor's Office(CCAO) and implement machine learning model-Gradient Boosting Machine(GBM) to predict the market value.

CCAO data documentation [is on Gitlab](https://gitlab.com/ccao-data-science---modeling/models/ccao_res_avm)

CCAO presentation on valuation method, model, and result [is on Youtube](https://www.youtube.com/embed/6rd-xYJb27Q?feature=oembed)

Our model of choice and methodology could be found [here](http://uc-r.github.io/gbm_regression)

### Files in this repository
- [final_project_1.R](https://github.com/BriAnWuu/UIUC-FIN510/blob/main/final_project_1.R): Source code of this project
- [historic_property_data.csv](https://github.com/BriAnWuu/UIUC-FIN510/blob/main/historic_property_data.csv): contains data on 50,000 properties sold recently with unique property identifier 'pid'
- [codebook.csv](https://github.com/BriAnWuu/UIUC-FIN510/blob/main/codebook.csv): describes the variables in the data
- [predict_property_data.csv](https://github.com/BriAnWuu/UIUC-FIN510/blob/main/predict_property_data.csv): contains data on 10,000 properties whose values are yet to be determined
- [assessed_value.csv](https://github.com/BriAnWuu/UIUC-FIN510/blob/main/assessed_value.csv): Predicted values for properties in the testing set
- [hyper_grid.csv](https://github.com/BriAnWuu/UIUC-FIN510/blob/main/hyper_grid.csv): 81 combinations of GBM parameter(shrinkage, tree depth, minimum number of terminal nodes, and bagging fraction) and their performance metrics, mean squared error(MSE)

### What we did to the data
- Variable selection: features selected according to CCAO presentation [video](https://www.youtube.com/embed/6rd-xYJb27Q?feature=oembed)(17:45)
- Pre-processing: filling and dropping missing values, dropping features with too many missing values, factorize categorical variables, adding polynomial variables
- Randomization: testing set-30%, validation set-17.5%, and training set-52.5%
- Parameter tunning: find hyperparameters, best performing combination of parameters for GBM, to build our pricing model
- Model evaluation: use performance metrics MSE to evaluate our model
- Data analytics: summary statistics and distribution of assessed(predicted) values, analyze relative influence of each feature on our model
