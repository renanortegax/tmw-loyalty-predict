#%%
from exec_query import exec_query
import datetime
import sqlalchemy
import pandas as pd

now = datetime.datetime.now().strftime("%Y-%m-%d")

engine_app = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")
engine_analytical = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

df = pd.read_sql('select max(data_ref) from life_cycle', engine_analytical)
last_dt_lifecycle = df.iloc[0].values[0]

#%%

steps = [
    {
        "table":"life_cycle",
        "db_origin":"loyalty-system",
        "db_target":"analytics",
        "dt_start":last_dt_lifecycle,
        "dt_stop":now,
        "monthly":False,
    },
    {
        "table":"fs_transacional",
        "db_origin":"loyalty-system",
        "db_target":"analytics",
        "dt_start":now,
        "dt_stop":now,
        "monthly":False,
    },
    {
        "table":"fs_education",
        "db_origin":"education-platform",
        "db_target":"analytics",
        "dt_start":now,
        "dt_stop":now,
        "monthly":False,
    },
    {
        "table":"fs_lifecycle",
        "db_origin":"analytics",
        "db_target":"analytics",
        "dt_start":now,
        "dt_stop":now,
        "monthly":False,
    },
    {
        "table":"fs_all",
        "db_origin":"analytics",
        "db_target":"analytics",
        "dt_start":now,
        "dt_stop":now,
        "monthly":False,
    },
]

for s in steps:
    exec_query(**s)
    
#%%