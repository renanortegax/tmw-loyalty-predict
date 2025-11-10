#%%
import pandas as pd
import sqlalchemy
from datetime import datetime
from dateutil.relativedelta import relativedelta

#%%
def import_query(path):
    with open(path, 'r') as f:
        query = f.read()
        return query

def generate_dates(date_start, date_end):
    if isinstance(date_start, str):
        date_start = datetime.strptime(date_start, "%Y-%m-%d").date()
    if isinstance(date_end, str):
        date_end = datetime.strptime(date_end, "%Y-%m-%d").date()
    
    current = date_start.replace(day=1)
    dates = []
    
    while current <= date_end:
        dates.append(current)
        current += relativedelta(months=1)
        
    return dates, [d.strftime("%Y-%m-%d") for d in dates]
#%%
query = import_query('./03.life_cycle.sql')
print(query.format(date='2025-11-09'))

#%%
engine_app = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")
engine_analytical = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")
#%%
df = pd.read_sql(query.format(date='2025-11-09'), engine_app)
df.head()
# %%
# df.to_sql("life_cycle", engine_analytical, index=False, if_exists='replace')

#%%
dates = generate_dates('2024-05-01', '2025-10-01')[-1]

#%%
# Foto da base todo final de mês
for d in dates:
    query_format = query.format(date=d)
    
    with engine_analytical.connect() as con:
        con.execute(sqlalchemy.text(f"delete from life_cycle where data_ref = date('{d}', '-1 day')"))
        con.commit()
    
    print(d)
    df = pd.read_sql(query_format, engine_app)
    df.to_sql("life_cycle", engine_analytical, index=False, if_exists='append')

#%%
# ------------- DROPANDO A TABELA -------------
# metadata = sqlalchemy.MetaData()
# your_table = sqlalchemy.Table('life_cycle', metadata, autoload_with=engine_analytical)
# your_table.drop(engine_analytical)
# print("Table 'life_cycle' dropped successfully!")
################################################