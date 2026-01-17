#%%
import sqlalchemy
import pandas as pd
from sklearn import model_selection
from feature_engine import selection
from feature_engine import imputation
from feature_engine import encoding

pd.set_option('display.max_columns', None)

con = sqlalchemy.create_engine(f"sqlite:///../../data/analytics/database.db")
#%%
df = pd.read_sql('select * from abt_fiel', con)
#%%
print(df.groupby(['data_ref'])['idCliente'].count())

# OutOfTime pra teste
df_oot = df[df['data_ref']==df['data_ref'].max()].reset_index(drop=True)
df_oot.head(3)

#%%
target = 'flagFiel'
features = df.columns.tolist()[4:]

df_train_test = df[df['data_ref']<df['data_ref'].max()].reset_index(drop=True)

X = df_train_test[features] # pd.Series => vetor
y = df_train_test[target]   # df => matriz

#%%


X_train, X_test, y_train, y_test = model_selection.train_test_split(
    X, y,
    random_state=42,
    test_size=0.2,
    # pra taxa % do Y que é o target ficar parecida entre treino e teste -> bases mais homogêneas entre si
    stratify=y
)

print(f"Treino: {y_train.shape[0]}, Tx.Target {100*y_train.mean():.2f}%")
print(f"Teste: {y_test.shape[0]}, Tx.Target {100*y_test.mean():.2f}%")

#%%

# >> EXPLORE - MISSING
s_nas = X_train.isna().mean()
s_nas = s_nas[s_nas>0]
s_nas

#%%
# >> EXPLORE - BIVARIADA
cat_features = ['desc_life_cycle_atual','desc_life_cycle_D28']
num_features = list(set(features) - set(cat_features))

df_train = X_train.copy()
df_train[target] = y_train.copy()

df_train[num_features] = df_train[num_features].astype(float)

bivariada_num = df_train.groupby(target)[num_features].median().T
bivariada_num['ratio'] = (bivariada_num[1] + 0.001) / (bivariada_num[0] + 0.001)
bivariada_num.sort_values(by='ratio', ascending=False)

#%%
bivariada_cat = df_train.groupby([cat_features[0]])[target].mean()
bivariada_cat
#%%
bivariada_cat_d28 = df_train.groupby([cat_features[1]])[target].mean()
bivariada_cat_d28
# %%
# >> MODIFY - DROP
X_train[num_features] = X_train[num_features].astype(float)
# casos que a mediana do grupo que virou fiel e do que não virou é a mesma -> não ajuda no modelo
to_remove = bivariada_num[bivariada_num['ratio']==1].index.tolist()

drop_features = selection.DropFeatures(to_remove)

# >> MODIFY - MISSING
fill_0 = ['python2025']
imput_0 = imputation.ArbitraryNumberImputer(arbitrary_number=0,
                                            variables=fill_0)

imput_new = imputation.CategoricalImputer(fill_value='Nao-Usuario',
                                          variables=['desc_life_cycle_D28'])

imput_1000 = imputation.ArbitraryNumberImputer(arbitrary_number=1000,
                                               variables=['avg_intervalo_dias_D28','avg_intervalo_dias_vida','qtd_dias_ult_atividade'])

# >> MODIFY - OneHot
onehot = encoding.OneHotEncoder(variables=cat_features)

#%%
# >> MODDEL
from sklearn import tree
from sklearn import ensemble
from sklearn import metrics

model = ensemble.AdaBoostClassifier(random_state=42,
                                    n_estimators=150,
                                    learning_rate=0.1)

# model = ensemble.RandomForestClassifier(random_state=42,
#                                         n_estimators=150,
#                                         n_jobs=-1,
#                                         min_samples_leaf=60)

# model = tree.DecisionTreeClassifier(random_state=42, min_samples_leaf=50)

#%%
# >> CRIANDO PIPELINE
from sklearn import pipeline
model_pipeline = pipeline.Pipeline(steps=[
    ('Remocao de Features',drop_features),
    ('Imputacao de Zeros',imput_0),
    ('Imputacao de NaoUsuario',imput_new),
    ('Imputacao de 1000',imput_1000),
    ('Onehot Encoding',onehot),
    ('Algoritmo', model)
])

model_pipeline.fit(X_train, y_train)

#%%
model.fit(X_train, y_train)

#%%
# >> ACESS - METRICAS
# -------- TREINO
y_pred_train = model_pipeline.predict(X_train)
y_proba_train = model_pipeline.predict_proba(X_train)

acc_train = metrics.accuracy_score(y_train, y_pred_train)
auc_train = metrics.roc_auc_score(y_train, y_proba_train[:,1])

print("Acuracia Treino: ", acc_train)
print("AUC Treino: ", auc_train)

#%%
# -------- TESTE
y_pred_test = model_pipeline.predict(X_test)
y_proba_test = model_pipeline.predict_proba(X_test)

acc_test = metrics.accuracy_score(y_test, y_pred_test)
auc_test = metrics.roc_auc_score(y_test, y_proba_test[:,1])

print("Acuracia Teste: ", acc_test)
print("AUC Teste: ", auc_test)
#%%
# ---------------- METRICAS: acuracia e area da curva ----------------
# -- Fazendo na mao um chute que todo mundo é 0, minha acuracia fica maior, pq a incidência de 0 é muito grande
#    -- 0 é virar Fiel no próximo MAU do lifecycle (+28 day)
y_predict_burns = pd.Series([0]*y_test.shape[0])
y_proba_burns = pd.Series([y_train.mean()]*y_test.shape[0])

acc_burns = metrics.accuracy_score(y_test, y_predict_burns)
auc_burns = metrics.roc_auc_score(y_test, y_proba_burns)
print("Acuracia Burns: ", acc_burns)
print("AUC Burns: ", auc_burns)

# %%
# ---------------- OLHANDO AS VARIAVEIS ----------------
pd.options.display.float_format = '{:.6f}'.format

#%%        -- pegando ate penultimo passo --
features_names = model_pipeline[:-1].transform(X_train.head(1)).columns.tolist()
features_importance = pd.DataFrame(model_pipeline[:-1].transform(X_train.head(1)).columns.tolist(), columns=['variavel'])
features_importance['importance'] = model_pipeline[-1].feature_importances_
features_importance.sort_values(by='importance', ascending=False).head(20)
# features_importance.sort_values(ascending=False)

#%%
# ------------- OLHANDO O OOT -------------
## ->> Meu OOT ta 100% com 0, aí esta voltando nan pra AUC do Out of time
    # --> pq to sem os dados do próximo mes que pegariam o 1 pra variavel target
df_oot[num_features] = df_oot[num_features].astype(float)

X_oot = df_oot[features]
y_oot = df_oot[target]

y_oot.value_counts()

y_pred_oot = model_pipeline.predict(X_oot)
y_proba_oot = model_pipeline.predict_proba(X_oot)

acc_oot = metrics.accuracy_score(y_oot, y_pred_oot)
auc_oot = metrics.roc_auc_score(y_oot, y_proba_oot[:,1])

print("Acuracia OOT: ", acc_oot)
print("AUC OOT: ", auc_oot)
# %%

# >> ACESS - PERSISTIR MODELO
model_series = pd.Series(
    {
        "model":model_pipeline,
        "features":X_train.columns.tolist(),
        "auc_train":auc_train,
        "auc_test":auc_test,
        "auc_oot":auc_oot,
    }
)
model_series.to_pickle("model_fiel.pkl")