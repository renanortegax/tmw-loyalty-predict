# Loyalty Predict
Créditos: [Projeto de Dados Téo Me Why](https://www.youtube.com/watch?v=FBCfsDREQaE&list=PLvlkVRRKOYFSNomvdmW4-EA3Ap3cyv4H5)

## Objetivo

Identificar perda ou ganho de engajamento dos usuários da nossa comunidade.

## Ações

- Métricas gerais do TMW;
- Definição do Ciclo de Vida dos usuários;
- Análise de Agrupamento dos diferentes perfís de usuários;
- Criar modelo de Machine Learning que detecte a perda ou ganho de engajamento;
- Incentivo por meio de pontos para usuários mais engajados;

## Etapas

- Entendimento do negócio;
- Extração dos dados;
- Entendimento dos dados;
- Definição das variáveis;
- Criação das Feature Stores;
- Treinamento do modelo;
- Registro do modelo no MLFlow;
- Criação de App para Inferência em Tempo Real;
- Integração com Ecossistema TMW;

## Fontes de Dados

- [Sistema de Pontos](https://www.kaggle.com/datasets/teocalvo/teomewhy-loyalty-system)
- [Plataforma de Cursos](https://www.kaggle.com/datasets/teocalvo/teomewhy-education-platform)
- [Link do repo original](https://github.com/TeoMeWhy/loyalty-predict#)
## Apoie o trabalho do mago

- 💵 Chave Pix: pix@teomewhy.org
- 💶 LivePix: [livepix.gg/teomewhy](https://livepix.gg/teomewhy)
- 💷 GitHub Sponsors: [github.com/sponsors/TeoMeWhy](https://github.com/sponsors/TeoMeWhy)
- 💴 ApoiaSe: [apoia.se/teomewhy](https://apoia.se/teomewhy)
- 🎥 Membro no YouTube: [youtube.com/@teomewhy/membership](https://youtube.com/@teomewhy/membership)
- 🎮 Sub na Twitch: [twitch.tv/teomewhy](https://twitch.tv/teomewhy)
- 💌 Newsletter: [teomewhy.substack.com](https://teomewhy.substack.com)
- 📚 Lojinha na Amazon: [Clique Aqui](https://www.amazon.com.br/shop/teo.calvo?-ref_=cm_sw_r_cp_ud_aipsfshop_MS3WV3HX76NT92FNB5BC)

## Para rodar [local]:
- Startar o mlflow: `mlflow server`
- Rodando o get_data + pipeline + predict
    - executar via **bash**: `make pipeline` 
        - **Obs:** se for a primeira execucao, fazer o setup primeiro: `make setup`
    - salva os predicts da data em questao na tabela do banco analitico `predict_score_fiel` via `src\analytics\predict_fiel.py`
    - salva a feature store `fs_all` via `src\analytics\pipeline_analytics.py`. Sempre a feature_sorte mais recente (conforme script `src\analytics\07.fs_all.sql`)
- Rodar o app flask pra subir a API e chamar por um outro cliente (Ex.: codigo `src\api\test_batendo_api.py` chama a api que faz predicao em tempo real)
    - `flask --app src/api/api_fiel.py run --port 5001`
        - porta 5000 o mlflow ta usando
