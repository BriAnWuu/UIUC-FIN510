## Property Assessment Challenge
This project aims to determine a fair market value of each property in the City of Chicago. Determining what is a fiar market value with this diversity of parcels that are spread across over 130 municipalities is one of the most complex valuation tasks in the United States. We are using the data from Cook County Assessor's Office(CCAO) and implement machine learning model-Gradient Boosting Machine(GBM) to predict the market value.

CCAO data documentation [is on Gitlab](https://gitlab.com/ccao-data-science---modeling/models/ccao_res_avm)

CCAO presentation on valuation method, model, and result [is on Youtube](https://www.youtube.com/embed/6rd-xYJb27Q?feature=oembed)

Our model of choice and methodology could be found [here](http://uc-r.github.io/gbm_regression)

### Files in this repository
- [final_project_1.R](https://github.com/BriAnWuu/UIUC-FIN510/blob/main/final_project_1.R): Source code of this project
- [historic_property_data.csv](https://github.com/BriAnWuu/UIUC-FIN510/blob/main/historic_property_data.csv): Training set that contains data on 50,000 properties sold recently with unique property identifier 'pid'
