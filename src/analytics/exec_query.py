#%%
import pandas as pd
import sqlalchemy
from datetime import datetime
from dateutil.relativedelta import relativedelta
from tqdm import tqdm
import argparse
import os

#%%
def import_query(path):
    with open(path, 'r') as f:
        query = f.read()
        return query

def generate_dates_day_one(date_start, date_end):
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

def generate_dates(date_start, date_end, monthly=False):
    if isinstance(date_start, str):
        date_start = datetime.strptime(date_start, "%Y-%m-%d").date()
    if isinstance(date_end, str):
        date_end = datetime.strptime(date_end, "%Y-%m-%d").date()
    
    dates = []
    
    while date_start <= date_end:
        dates.append(date_start)
        date_start += relativedelta(days=1)

    if monthly:
        dates = [d for d in dates if d.day == 1]
        return dates, [d.strftime("%Y-%m-%d") for d in dates]
        

    return dates, [d.strftime("%Y-%m-%d") for d in dates]
#%%
dicts_files = {f.split(".")[-2] : ".".join(f.split(".")[:-2]) for f in os.listdir("./") if f.endswith(".sql")}

#%%
def exec_query(table, db_origin, db_target, dt_start, dt_stop, monthly, mode='append'):
    engine_app = sqlalchemy.create_engine(f"sqlite:///../../data/{db_origin}/database.db")
    engine_analytical = sqlalchemy.create_engine(f"sqlite:///../../data/{db_target}/database.db")

    dates = generate_dates(dt_start, dt_stop, monthly)[-1]
    query = import_query(f'./{dicts_files.get(table)}.{table}.sql')
    df = pd.read_sql(query.format(date='2025-11-09'), engine_app)
    df.head()

    # Foto da base todo final de mês
    for d in tqdm(dates):
        query_format = query.format(date=d)
        
        with engine_analytical.connect() as con:
            try:
                query_delete = f"delete from {table} where data_ref = date('{d}', '-1 day')"
                con.execute(sqlalchemy.text(query_delete))
                con.commit()
            except Exception as e:
                print(e)
        
        # print(d)
        df = pd.read_sql(query_format, engine_app)
        df.to_sql(table, engine_analytical, index=False, if_exists=mode)

# dates = generate_dates('2024-03-01', '2025-09-01')[-1]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--db_origin', choices=['loyalty-system', 'education-platform','analytics'], default='loyalty-system')
    parser.add_argument('--db_target', choices=['analytics'], default='analytics')
    parser.add_argument('--table', type=str, help='Tabela que vai processar com o mesmo nome do arquivo')
    parser.add_argument('--start', type=str, default='2024-03-01')
    parser.add_argument('--monthly', action='store_true')
    parser.add_argument('--mode', choices=['append','replace'])
    
    stop = datetime.now().strftime('%Y-%m-%d')
    parser.add_argument('--stop', type=str, default=stop)
    
    
    args = parser.parse_args()
    
    print(f"Iniciando para os seguintes argumentos:\n{args}")
    
    exec_query(args.table,args.db_origin,args.db_target,args.start,args.stop,args.monthly)
    
if __name__ == "__main__":
    main()

