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
df = df[['IdCliente', 'qtd_frequencia', 'qtd_pontos', 'cluster']]
df.head()

#%%
plt.plot(df['qtd_frequencia'], df['qtd_pontos'], 'o')
plt.grid(True)
plt.xlabel("Frequencia")
plt.ylabel("Valor")
plt.show()

#%%
from sklearn import cluster
from sklearn import preprocessing

## Normalizando (entre 0 e 1), pq a qtd de pontos estava sendo praticamente 100% determinante nos clusters antes disso
minmax = preprocessing.MinMaxScaler()
X = minmax.fit_transform(df[['qtd_frequencia', 'qtd_pontos']])

df_x = pd.DataFrame(X, columns=['norm_freq', 'norm_valor'])
df_x
#%%

# Clusterizando
kmean = cluster.KMeans(n_clusters=5, random_state=42, max_iter=1000)
kmean.fit(X)

df['cluster_kmean'] = kmean.labels_
df_x['cluster_kmean'] = kmean.labels_
df

#%%
df.groupby('cluster_kmean')['IdCliente'].count()
#%%
## [antes de normalizar] Parece que a qtd de pontos está sozinha determinando o cluster
import seaborn as sns
sns.scatterplot(
    data = df,
    x='qtd_frequencia',
    y='qtd_pontos',
    hue='cluster_kmean',
    palette='deep'
)
plt.hlines(y=1500, xmin=0, xmax=25, colors='black')
plt.hlines(y=750, xmin=0, xmax=25, colors='black')
plt.vlines(x=4, ymin=0, ymax=750, colors='black')
plt.vlines(x=10, ymin=0, ymax=3000, colors='black')
plt.grid()

#%%
sns.scatterplot(
    data = df_x,
    x='norm_freq',
    y='norm_valor',
    hue='cluster',
    palette='deep'
)
plt.grid()

#%%
# Criado na query
sns.scatterplot(
    data = df,
    x='qtd_frequencia',
    y='qtd_pontos',
    hue='cluster',
    palette='deep'
)
plt.grid()