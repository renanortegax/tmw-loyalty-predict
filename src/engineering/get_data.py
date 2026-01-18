#%%
import os
from dotenv import load_dotenv
from kaggle import api
import shutil

load_dotenv()

# os.getenv("KAGGLE_KEY")
# os.getenv("KAGGLE_USERNAME")

#%%
datasets = [
    'teocalvo/teomewhy-loyalty-system',
    'teocalvo/teomewhy-education-platform'
]
for d in datasets:
    dataset_name = d.split("teomewhy-")[-1]
    path = f'../../data/{dataset_name}/database.db'
    
    api.dataset_download_file(d, 'database.db')

    shutil.move('database.db', path)
    print(f"Movendo dados da {dataset_name} para {path}")

