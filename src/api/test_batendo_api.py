#%%
import requests
import sqlalchemy
import pandas as pd
import json

#%% Testando um request
resp = requests.get("http://localhost:5001/health_check")
resp.json()

#%% Batendo em "predict"
con = sqlalchemy.create_engine(f"sqlite:///../../data/analytics/database.db")

data = pd.read_sql("select * from fs_all limit 1", con)
data = {
    "data":data.to_dict(orient='records')[0]
}

print(data)
resp = requests.post("http://localhost:5001/predict", json=data)
resp.json()

#%% V1: Batendo em "predict_many"
data = pd.read_sql("select * from fs_all limit 2", con)
data = {
    "data":data.to_dict(orient='records')
}

print(data)
resp = requests.post("http://localhost:5001/predict_many", json=data)
resp.json()



#%% V2: Batendo em "predict_many"
data = pd.read_sql("select * from fs_all limit 2", con)

data = data.to_json(orient='records')
data = {"data": json.loads(data)}
data = {
    "rox":42
}
print(data)
resp = requests.post("http://localhost:5001/predict_many", json=data)
resp.json()



