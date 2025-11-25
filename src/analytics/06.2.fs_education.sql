-- SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;

with tb_usuario_curso as (
    SELECT
    idUsuario
    ,descSlugCurso
    ,count(descSlugCursoEpisodio) qtd_eps
    from cursos_episodios_completos
    where dtCriacao < '2025-10-01'
    group by 1,2
)
, tb_curso_total_eps as (
    select
    descSlugCurso
    ,count(descEpisodio) as qtd_total_eps
    from cursos_episodios
    group by 1
)
, tb_pct_cursos as (
    select
    t1.idUsuario
    ,t1.descSlugCurso
    ,1. * qtd_eps/qtd_total_eps as pct_curso_completo
    from tb_usuario_curso t1
    left join tb_curso_total_eps t2
        on t1.descSlugCurso = t2.descSlugCurso
)

, tb_pivotada_pct_cursos as (
        /* -- Pct e metricas de completude em cursos --------------------------------------------------- */
    select
    idUsuario
    ,max(case when pct_curso_completo = 1 then 1 else 0 end) as qtd_cursos_completos
    ,max(case when pct_curso_completo > 0 and pct_curso_completo < 1 then 1 else 0 end) as qtd_cursos_incompletos
    ,max(case when descSlugCurso = 'carreira' then pct_curso_completo else 0 end) as carreira
    ,max(case when descSlugCurso = 'coleta-dados-2024' then pct_curso_completo else 0 end) as coletaDados2024
    ,max(case when descSlugCurso = 'ds-databricks-2024' then pct_curso_completo else 0 end) as dsDatabricks2024
    ,max(case when descSlugCurso = 'ds-pontos-2024' then pct_curso_completo else 0 end) as dsPontos2024
    ,max(case when descSlugCurso = 'estatistica-2024' then pct_curso_completo else 0 end) as estatistica2024
    ,max(case when descSlugCurso = 'estatistica-2025' then pct_curso_completo else 0 end) as estatistica2025
    ,max(case when descSlugCurso = 'github-2024' then pct_curso_completo else 0 end) as github2024
    ,max(case when descSlugCurso = 'github-2025' then pct_curso_completo else 0 end) as github2025
    ,max(case when descSlugCurso = 'ia-canal-2025' then pct_curso_completo else 0 end) as iaCanal2025
    ,max(case when descSlugCurso = 'lago-mago-2024' then pct_curso_completo else 0 end) as lagoMago2024
    ,max(case when descSlugCurso = 'loyalty-predict-2025' then pct_curso_completo else 0 end) as loyaltyPredict2025
    ,max(case when descSlugCurso = 'machine-learning-2025' then pct_curso_completo else 0 end) as machineLearning2025
    ,max(case when descSlugCurso = 'ml-2024' then pct_curso_completo else 0 end) as ml2024
    ,max(case when descSlugCurso = 'mlflow-2025' then pct_curso_completo else 0 end) as mlflow2025
    ,max(case when descSlugCurso = 'pandas-2024' then pct_curso_completo else 0 end) as pandas2024
    ,max(case when descSlugCurso = 'pandas-2025' then pct_curso_completo else 0 end) as pandas2025
    ,max(case when descSlugCurso = 'python-2024' then pct_curso_completo else 0 end) as python2024
    ,max(case when descSlugCurso = 'python-2025' then pct_curso_completo else 0 end) as python2025
    ,max(case when descSlugCurso = 'sql-2020' then pct_curso_completo else 0 end) as sql2020
    ,max(case when descSlugCurso = 'sql-2025' then pct_curso_completo else 0 end) as sql2025
    ,max(case when descSlugCurso = 'streamlit-2025' then pct_curso_completo else 0 end) as streamlit2025
    ,max(case when descSlugCurso = 'trampar-lakehouse-2024' then pct_curso_completo else 0 end) as tramparLakehouse2024
    ,max(case when descSlugCurso = 'tse-analytics-2024' then pct_curso_completo else 0 end) as tseAnalytics2024
    from tb_pct_cursos
    group by 1
)
, tb_atividade as (
    select 
        idUsuario,
        max(dtRecompensa) as dtcriacao
    from recompensas_usuarios
    where dtRecompensa < '2025-10-01'
    group by 1

    union all

    select 
        idUsuario,
        max(dtcriacao) as dtcriacao
    from habilidades_usuarios
    where dtcriacao < '2025-10-01'
    group by 1

    union all

    select
        idUsuario,
        max(dtcriacao) as dtcriacao
    from cursos_episodios_completos
    where dtcriacao < '2025-10-01'
    group by 1
)
, tb_ult_atividade as (
    select
    idUsuario
    ,min( julianday('2025-10-01') - julianday(dtCriacao)) as qtd_dias_ult_atividade
    from tb_atividade
    group by 1
)
, tb_join as (
    select
    t3.idTMWCliente as idcliente
    ,t1.qtd_cursos_completos
    ,t1.qtd_cursos_incompletos
    ,t1.carreira
    ,t1.coletaDados2024
    ,t1.dsDatabricks2024
    ,t1.dsPontos2024
    ,t1.estatistica2024
    ,t1.estatistica2025
    ,t1.github2024
    ,t1.github2025
    ,t1.iaCanal2025
    ,t1.lagoMago2024
    ,t1.loyaltyPredict2025
    ,t1.machineLearning2025
    ,t1.ml2024
    ,t1.mlflow2025
    ,t1.pandas2024
    ,t1.pandas2025
    ,t1.python2024
    ,t1.python2025
    ,t1.sql2020
    ,t1.sql2025
    ,t1.streamlit2025
    ,t1.tramparLakehouse2024
    ,t1.tseAnalytics2024
    ,t2.qtd_dias_ult_atividade
    from tb_pivotada_pct_cursos t1
    left join tb_ult_atividade t2
        on t1.idUsuario = t2.idUsuario
    join usuarios_tmw t3 -- filtrando a galera que vinculou
        on t1.idUsuario = t3.idUsuario
)
select
    date('2025-10-01', '-1 day') as data_ref,
    *
from tb_join
;