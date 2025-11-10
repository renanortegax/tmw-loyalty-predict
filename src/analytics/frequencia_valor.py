#%%
import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt

engine = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")
# %%
def import_query(path):
    with open(path, 'r') as f:
        query = f.read()
        return query


query = import_query('./05.frequencia_valor.sql')
# %%
df = pd.read_sql(query, engine)
df = df[df['qtd_pontos'] < 4000] # Remover o outlier (era um bug)
df = df[['IdCliente', 'qtd_frequencia', 'qtd_pontos']]
df.head()

#%%
plt.plot(df['qtd_frequencia'], df['qtd_pontos'], 'o')
plt.grid(True)
plt.xlabel("Frequencia")
plt.ylabel("Valor")
plt.show()

#%%
from sklearn import cluster
# Clusterizando
kmean = cluster.KMeans(n_clusters=5, random_state=42, max_iter=1000)
kmean.fit(df[['qtd_frequencia','qtd_pontos']])

df['cluster'] = kmean.labels_
df

#%%
df[df['IdCliente'].str.startswith('820c0e')]
#%%
df.groupby('cluster')['IdCliente'].count()
#%%
## Parece que a qtd de pontos está sozinha determinando o cluster
import seaborn as sns
sns.scatterplot(
    data = df,
    x='qtd_frequencia',
    y='qtd_pontos',
    hue='cluster',
    palette='deep'
)
plt.grid()

#%%


