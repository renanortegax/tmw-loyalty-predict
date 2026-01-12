-- >> Analytical Base Table << --
DROP TABLE IF EXISTS abt_fiel;

CREATE TABLE IF NOT EXISTS abt_fiel as 
WITH tb_join AS (

    SELECT t1.data_ref,
           t1.IdCliente,
           t1.desc_life_cycle,
           t2.desc_life_cycle as desc_life_cycle_t2,
           CASE WHEN t2.desc_life_cycle = '02.Fiel' THEN 1 ELSE 0 END AS flagFiel,
           ROW_NUMBER() OVER (PARTITION BY t1.IdCliente ORDER BY random()) as rnRandom
    FROM life_cycle AS t1
    LEFT JOIN life_cycle AS t2
        ON t1.IdCliente = t2.IdCliente
        AND date(t1.data_ref, '+28 day') = date(t2.data_ref)
        -- AND date(t1.data_ref, 'start of month', '+2 months', '-1 day')
    WHERE 1=1
        and t1.data_ref >= '2024-03-01'
        AND t1.data_ref in (select distinct data_ref from fs_transacional) /* fazendo isso pq processei mensal as fs_..sql*/
    AND t1.desc_life_cycle <> '05.Zumbi'
)

,tb_cohort as (
    select
    -- t1.desc_base,
    t1.data_ref
    ,t1.idCliente
    ,t1.flagFiel
    from tb_join t1
    where 1=1
        and rnRandom <= 2
    -- order by idCliente,data_ref
)

select
t1.*
,t2.idade_dias
,t2.qtd_ativacao_vida
,t2.qtd_ativacao_D7
,t2.qtd_ativacao_D14
,t2.qtd_ativacao_D28
,t2.qtd_ativacao_D56
,t2.qtd_transacao_vida
,t2.qtd_transacao_D7
,t2.qtd_transacao_D14
,t2.qtd_transacao_D28
,t2.qtd_transacao_D56
,t2.saldo_vida
,t2.saldo_D7
,t2.saldo_D14
,t2.saldo_D28
,t2.saldo_D56
,t2.qtd_pontos_pos_vida
,t2.qtd_pontos_pos_D7
,t2.qtd_pontos_pos_D14
,t2.qtd_pontos_pos_D28
,t2.qtd_pontos_pos_D56
,t2.qtd_pontos_negativ_vida
,t2.qtd_pontos_negativ_D7
,t2.qtd_pontos_negativ_D14
,t2.qtd_pontos_negativ_D28
,t2.qtd_pontos_negativ_D56
,t2.qtd_transacao_manha
,t2.qtd_transacao_tarde
,t2.qtd_transacao_noite
,t2.pct_transacao_manha
,t2.pct_transacao_tarde
,t2.pct_transacao_noite
,t2.qtd_transacao_dia_vida
,t2.qtd_transacao_dia_D7
,t2.qtd_transacao_dia_D14
,t2.qtd_transacao_dia_D28
,t2.qtd_transacao_dia_D56
,t2.pct_ativacao_mau
,t2.qtd_horas_vida
,t2.qtd_horas_D7
,t2.qtd_horas_D14
,t2.qtd_horas_D28
,t2.qtd_horas_D56
,t2.avg_intervalo_dias_vida
,t2.avg_intervalo_dias_D28
,t2.qtd_ChatMessage
,t2.qtd_AirflowLover
,t2.qtd_RLover
,t2.qtd_ResgatarPonei
,t2.qtd_Listadepresenca
,t2.qtd_PresencaStreak
,t2.qtd_TrocadePontosStreamElements
,t2.qtd_Reembolso_StreamElements
,t2.qtd_rpg
,t2.qtd_churn_model
,t3.desc_life_cycle_atual
,t3.qtd_frequencia
,t3.desc_life_cycle_D28
,t3.pct_Curioso
,t3.pct_Fiel
,t3.pct_Reborn
,t3.pct_Reconquistado
,t3.pct_Turista
,t3.pct_Desencantado
,t3.pct_Zumbi
,t3.avg_freq_grupo
,t3.ratio_freq_grupo
,t4.qtd_cursos_completos
,t4.qtd_cursos_incompletos
,t4.carreira
,t4.coletaDados2024
,t4.dsDatabricks2024
,t4.dsPontos2024
,t4.estatistica2024
,t4.estatistica2025
,t4.github2024
,t4.github2025
,t4.iaCanal2025
,t4.lagoMago2024
,t4.loyaltyPredict2025
,t4.machineLearning2025
,t4.ml2024
,t4.mlflow2025
,t4.pandas2024
,t4.pandas2025
,t4.python2024
,t4.python2025
,t4.sql2020
,t4.sql2025
,t4.streamlit2025
,t4.tramparLakehouse2024
,t4.tseAnalytics2024
,t4.qtd_dias_ult_atividade
from tb_cohort t1
left join fs_transacional t2
    on t1.idCliente = t2.idCliente
    and t1.data_ref = t2.data_ref
left join fs_lifecycle t3
    on t1.idCliente = t3.idCliente
    and t1.data_ref = t3.data_ref
left join fs_education t4
    on t1.idCliente = t4.idCliente
    and t1.data_ref = t4.data_ref
where 1=1
    and t3.data_ref is not null
;


-- CREATE TABLE IF NOT EXISTS abt_fiel as 
-- with tb_join as (
--     select
--         'train' as desc_base
--         ,t1.data_ref
--         ,t1.idCliente
--         ,t1.desc_life_cycle
--         ,t2.data_ref as data_ref_2
--         ,case when t2.desc_life_cycle = '02.Fiel' then 1 else 0 end as flagFiel
--         ,t2.desc_life_cycle as desc_life_cycle_2
--         -- amostra aleatoria pra cada cliente
--         ,row_number() over(partition by t1.idcliente order by random()) as rnRandom
--     from life_cycle t1
--     left join life_cycle t2
--         on t2.idcliente = t1.idcliente
--         /* -- ele fez +28 day pra pegar o MAU seguinte, mas eu não processei as tabeals de forma diaria, fiz mensal, pq estava demorando muito.. entao estou pegando o mês seguinte daquele cliente*/
--         and t2.data_ref = date(t1.data_ref, 'start of month', '+2 months', '-1 day')
--     where 1=1
--         and t1.desc_life_cycle <> '05.Zumbi'
--         and t1.data_ref >= '2024-03-31' 
--         and t1.data_ref <= '2025-08-31'

--     union all

--     select
--         'teste_oot' as desc_base
--         ,t1.data_ref
--         ,t1.idCliente
--         ,t1.desc_life_cycle
--         ,t2.data_ref as data_ref_2
--         ,case when t2.desc_life_cycle = '02.Fiel' then 1 else 0 end as flagFiel
--         ,t2.desc_life_cycle as desc_life_cycle_2
--         -- amostra aleatoria pra cada cliente
--         ,row_number() over(partition by t1.idcliente order by random()) as rnRandom
--     from life_cycle t1
--     left join life_cycle t2
--         on t2.idcliente = t1.idcliente
--         /* -- ele fez +28 day pra pegar o MAU seguinte, mas eu não processei as tabeals de forma diaria, fiz mensal, pq estava demorando muito.. entao estou pegando o mês seguinte daquele cliente*/
--         and t2.data_ref = date(t1.data_ref, 'start of month', '+2 months', '-1 day')
--     where 1=1
--         and t1.desc_life_cycle <> '05.Zumbi'
--         /* >> depois usar 2025-09-30 pra testar o modelo << */
--         and t1.data_ref = '2025-09-30'
-- )
-- ,tb_cohort as (
--     select
--     t1.desc_base
--     ,t1.data_ref
--     ,t1.idCliente
--     ,t1.flagFiel
--     from tb_join t1
--     where 1=1
--         and rnRandom <= 2
--     order by idCliente,data_ref
-- )

-- select
-- t1.*
-- ,t2.idade_dias
-- ,t2.qtd_ativacao_vida
-- ,t2.qtd_ativacao_D7
-- ,t2.qtd_ativacao_D14
-- ,t2.qtd_ativacao_D28
-- ,t2.qtd_ativacao_D56
-- ,t2.qtd_transacao_vida
-- ,t2.qtd_transacao_D7
-- ,t2.qtd_transacao_D14
-- ,t2.qtd_transacao_D28
-- ,t2.qtd_transacao_D56
-- ,t2.saldo_vida
-- ,t2.saldo_D7
-- ,t2.saldo_D14
-- ,t2.saldo_D28
-- ,t2.saldo_D56
-- ,t2.qtd_pontos_pos_vida
-- ,t2.qtd_pontos_pos_D7
-- ,t2.qtd_pontos_pos_D14
-- ,t2.qtd_pontos_pos_D28
-- ,t2.qtd_pontos_pos_D56
-- ,t2.qtd_pontos_negativ_vida
-- ,t2.qtd_pontos_negativ_D7
-- ,t2.qtd_pontos_negativ_D14
-- ,t2.qtd_pontos_negativ_D28
-- ,t2.qtd_pontos_negativ_D56
-- ,t2.qtd_transacao_manha
-- ,t2.qtd_transacao_tarde
-- ,t2.qtd_transacao_noite
-- ,t2.pct_transacao_manha
-- ,t2.pct_transacao_tarde
-- ,t2.pct_transacao_noite
-- ,t2.qtd_transacao_dia_vida
-- ,t2.qtd_transacao_dia_D7
-- ,t2.qtd_transacao_dia_D14
-- ,t2.qtd_transacao_dia_D28
-- ,t2.qtd_transacao_dia_D56
-- ,t2.pct_ativacao_mau
-- ,t2.qtd_horas_vida
-- ,t2.qtd_horas_D7
-- ,t2.qtd_horas_D14
-- ,t2.qtd_horas_D28
-- ,t2.qtd_horas_D56
-- ,t2.avg_intervalo_dias_vida
-- ,t2.avg_intervalo_dias_D28
-- ,t2.qtd_ChatMessage
-- ,t2.qtd_AirflowLover
-- ,t2.qtd_RLover
-- ,t2.qtd_ResgatarPonei
-- ,t2.qtd_Listadepresenca
-- ,t2.qtd_PresencaStreak
-- ,t2.qtd_TrocadePontosStreamElements
-- ,t2.qtd_Reembolso_StreamElements
-- ,t2.qtd_rpg
-- ,t2.qtd_churn_model
-- ,t3.desc_life_cycle_atual
-- ,t3.qtd_frequencia
-- ,t3.desc_life_cycle_D28
-- ,t3.pct_Curioso
-- ,t3.pct_Fiel
-- ,t3.pct_Reborn
-- ,t3.pct_Reconquistado
-- ,t3.pct_Turista
-- ,t3.pct_Desencantado
-- ,t3.pct_Zumbi
-- ,t3.avg_freq_grupo
-- ,t3.ratio_freq_grupo
-- ,t4.qtd_cursos_completos
-- ,t4.qtd_cursos_incompletos
-- ,t4.carreira
-- ,t4.coletaDados2024
-- ,t4.dsDatabricks2024
-- ,t4.dsPontos2024
-- ,t4.estatistica2024
-- ,t4.estatistica2025
-- ,t4.github2024
-- ,t4.github2025
-- ,t4.iaCanal2025
-- ,t4.lagoMago2024
-- ,t4.loyaltyPredict2025
-- ,t4.machineLearning2025
-- ,t4.ml2024
-- ,t4.mlflow2025
-- ,t4.pandas2024
-- ,t4.pandas2025
-- ,t4.python2024
-- ,t4.python2025
-- ,t4.sql2020
-- ,t4.sql2025
-- ,t4.streamlit2025
-- ,t4.tramparLakehouse2024
-- ,t4.tseAnalytics2024
-- ,t4.qtd_dias_ult_atividade
-- from tb_cohort t1
-- left join fs_transacional t2
--     on t1.idCliente = t2.idCliente
--     and t1.data_ref = t2.data_ref
-- left join fs_lifecycle t3
--     on t1.idCliente = t3.idCliente
--     and t1.data_ref = t3.data_ref
-- left join fs_education t4
--     on t1.idCliente = t4.idCliente
--     and t1.data_ref = t4.data_ref
-- where 1=1
--     and t3.data_ref is not null
-- ;