#%%
import pandas as pd
import sqlalchemy
import mlflow
print("Rodar `mlflow server` para iniciar o mlflow")

con = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

mlflow.set_tracking_uri("http://localhost:5000")
#%%
versions = mlflow.search_model_versions(filter_string="name='model_fiel'")
last_version = max([int(i.version) for i in versions])
model = mlflow.sklearn.load_model(f"models:///model_fiel/{last_version}")

#%%
data = pd.read_sql("select * from fs_all", con)
model
#%%
predict = model.predict_proba(data[model.feature_names_in_])[:,1]
data['predict_fiel'] = predict #probabilidade de ser fiel
data = data[['data_ref','idcliente','predict_fiel']]

#%%
data.to_sql("predict_score_fiel", con, index=False, if_exists='replace')

#%%