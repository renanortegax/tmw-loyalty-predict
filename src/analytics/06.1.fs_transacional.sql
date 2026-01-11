with tb_transacao as (
    select
    *
    ,substr(dtcriacao,0,11) as dtdia
    ,CAST(substr(dtcriacao, 12,2) as int) - 3 as dthora -- subtrai 3 por conta do UTC+0
    from transacoes
    where dtcriacao <= '{date}'
)
, tb_agg_transacao as (
    select
        idcliente

        /* -- Idade na Base --------------------------------------------------- */
        ,max( julianday('{date}') - julianday(DtCriacao) ) as idade_dias
        /* -- Frequência em Dias (D7, D14, D28, D56, Vida) --------------------------------------------------- */
        ,count(DISTINCT dtdia) as qtd_ativacao_vida
        ,count(DISTINCT case when dtdia >= date('{date}', '-7 days') then dtdia end) as qtd_ativacao_D7
        ,count(DISTINCT case when dtdia >= date('{date}', '-14 days') then dtdia end) as qtd_ativacao_D14
        ,count(DISTINCT case when dtdia >= date('{date}', '-28 days') then dtdia end) as qtd_ativacao_D28
        ,count(DISTINCT case when dtdia >= date('{date}', '-56 days') then dtdia end) as qtd_ativacao_D56
        /* -- Frequência em Transações (D7, D14, D28, D56, Vida) --------------------------------------------------- */
        ,count(DISTINCT idtransacao) as qtd_transacao_vida
        ,count(DISTINCT case when dtdia >= date('{date}', '-7 days') then idtransacao end) as qtd_transacao_D7
        ,count(DISTINCT case when dtdia >= date('{date}', '-14 days') then idtransacao end) as qtd_transacao_D14
        ,count(DISTINCT case when dtdia >= date('{date}', '-28 days') then idtransacao end) as qtd_transacao_D28
        ,count(DISTINCT case when dtdia >= date('{date}', '-56 days') then idtransacao end) as qtd_transacao_D56

        /* -- Valor de pontos (pos, neg, saldo) - D7, D14, D28, D56, Vida --------------------------------------------------- */
        ------ saldo liquido
        ,sum(qtdepontos) as saldo_vida
        ,sum(case when dtdia >= date('{date}', '-7 days') then qtdepontos else 0 end) as saldo_D7
        ,sum(case when dtdia >= date('{date}', '-14 days') then qtdepontos else 0 end) as saldo_D14
        ,sum(case when dtdia >= date('{date}', '-28 days') then qtdepontos else 0 end) as saldo_D28
        ,sum(case when dtdia >= date('{date}', '-56 days') then qtdepontos else 0 end) as saldo_D56
        ------ positivos
        ,sum(case when qtdepontos > 0 then qtdepontos else 0 end) as qtd_pontos_pos_vida
        ,sum(case when dtdia >= date('{date}', '-7 days') and qtdepontos > 0 then qtdepontos else 0 end) as qtd_pontos_pos_D7
        ,sum(case when dtdia >= date('{date}', '-14 days') and qtdepontos > 0 then qtdepontos else 0 end) as qtd_pontos_pos_D14
        ,sum(case when dtdia >= date('{date}', '-28 days') and qtdepontos > 0 then qtdepontos else 0 end) as qtd_pontos_pos_D28
        ,sum(case when dtdia >= date('{date}', '-56 days') and qtdepontos > 0 then qtdepontos else 0 end) as qtd_pontos_pos_D56
        ------ negativos
        ,sum(case when qtdepontos < 0 then qtdepontos else 0 end) as qtd_pontos_negativ_vida
        ,sum(case when dtdia >= date('{date}', '-7 days') and qtdepontos < 0 then qtdepontos else 0 end) as qtd_pontos_negativ_D7
        ,sum(case when dtdia >= date('{date}', '-14 days') and qtdepontos < 0 then qtdepontos else 0 end) as qtd_pontos_negativ_D14
        ,sum(case when dtdia >= date('{date}', '-28 days') and qtdepontos < 0 then qtdepontos else 0 end) as qtd_pontos_negativ_D28
        ,sum(case when dtdia >= date('{date}', '-56 days') and qtdepontos < 0 then qtdepontos else 0 end) as qtd_pontos_negativ_D56

        /* -- Período que assiste live (share de período) --------------------------------------------------- */
        ,count(case when dthora BETWEEN 7 and 11 then idtransacao end) as qtd_transacao_manha
        ,count(case when dthora BETWEEN 12 and 18 then idtransacao end) as qtd_transacao_tarde
        ,count(case when dthora > 18 or dthora < 7 then idtransacao end) as qtd_transacao_noite

        ,1. * count(case when dthora BETWEEN 7 and 11 then idtransacao end) / count(idtransacao) as pct_transacao_manha
        ,1. * count(case when dthora BETWEEN 12 and 18 then idtransacao end) / count(idtransacao) as pct_transacao_tarde
        ,1. * count(case when dthora > 18 or dthora < 7 then idtransacao end) / count(idtransacao) as pct_transacao_noite


    from tb_transacao
    group by 1
)
, tb_agg_calculada as (
    select
    *
    /* -- Quantidade de transações por dia (D7, D14, D28, D56) --------------------------------------------------- */
    ,coalesce(1. * qtd_transacao_vida / qtd_ativacao_vida, 0) as qtd_transacao_dia_vida
    ,coalesce(1. * qtd_transacao_D7 / qtd_ativacao_D7, 0) as qtd_transacao_dia_D7
    ,coalesce(1. * qtd_transacao_D14 / qtd_ativacao_D14, 0) as qtd_transacao_dia_D14
    ,coalesce(1. * qtd_transacao_D28 / qtd_ativacao_D28, 0) as qtd_transacao_dia_D28
    ,coalesce(1. * qtd_transacao_D56 / qtd_ativacao_D56, 0) as qtd_transacao_dia_D56
    /* -- Percentual de ativação no MAU --------------------------------------------------- */
    ,coalesce(1. * qtd_ativacao_D28 / 28, 0) as pct_ativacao_mau
    from tb_agg_transacao
)
, tb_hora_dia as (
    select
    idcliente
    ,dtdia
    -- primeira interacao e ultima que estamos usando de regra pra determinar o tempo que a pessoa assistiu
    ,( max(julianday(dtcriacao)) - min(julianday(dtcriacao)) ) * 24 as duracao
    from tb_transacao
    group by 1,2
)
, tb_hora_cliente as (
    select
        idcliente
            /* -- Horas assistidas (D7, D14, D28, D56) --------------------------------------------------- */
        ,sum(duracao) as qtd_horas_vida
        ,sum(case when dtdia >= date('{date}', '-7 days') then duracao else 0 end) as qtd_horas_D7
        ,sum(case when dtdia >= date('{date}', '-14 days') then duracao else 0 end) as qtd_horas_D14
        ,sum(case when dtdia >= date('{date}', '-28 days') then duracao else 0 end) as qtd_horas_D28
        ,sum(case when dtdia >= date('{date}', '-56 days') then duracao else 0 end) as qtd_horas_D56
    from tb_hora_dia
    group by 1
)
, tb_lag_dia as (
    select
    idcliente
    ,dtdia
    ,lag(dtdia) over (PARTITION by idcliente order by dtdia) as lag_dia
    from tb_hora_dia
)
, tb_intervalo_dias as (
    /* -- Média de intervalo entre os dias de ativação --------------------------------------------------- */
    select
    idcliente,
    avg(julianday(dtDia) - julianday(lag_dia)) as avg_intervalo_dias_vida,
    avg(case when dtdia >= date('{date}', '-28 days') then julianday(dtDia) - julianday(lag_dia) end) as avg_intervalo_dias_D28
    from tb_lag_dia
    group by 1
)
, tb_share_produtos as (
    --> obs: existe IdProduto sem nome/categoria (no fim, acabam nao entrando no case abaixo, por estar usando o nome/categ pra separar)
        /* Prova: 
            select
                t2.IdProduto,
                DescCategoriaProduto,
                DescNomeProduto,
                count(1) as qtd
            from transacao_produto t2
            left join produtos t3
                on t2.IdProduto = t3.IdProduto
            group by 1,2,3
            order by 1,2,3
        */
    select
        t1.idCliente
        /* -- Tipos de produto "comprados" (ponderador pela quantidade) --------------------------------------------------- */
        ,1.* count(case when t3.DescNomeProduto = 'ChatMessage' then t1.IdTransacao end) / count(t1.IdTransacao) as qtd_ChatMessage
        ,1.* count(case when t3.DescNomeProduto = 'Airflow Lover' then t1.IdTransacao end) / count(t1.IdTransacao) as qtd_AirflowLover
        ,1.* count(case when t3.DescNomeProduto = 'R Lover' then t1.IdTransacao end) / count(t1.IdTransacao) as qtd_RLover
        ,1.* count(case when t3.DescNomeProduto = 'Resgatar Ponei' then t1.IdTransacao end) / count(t1.IdTransacao) as qtd_ResgatarPonei
        ,1.* count(case when t3.DescNomeProduto = 'Lista de presença' then t1.IdTransacao end) / count(t1.IdTransacao) as qtd_Listadepresenca
        ,1.* count(case when t3.DescNomeProduto = 'Presença Streak' then t1.IdTransacao end) / count(t1.IdTransacao) as qtd_PresencaStreak
        ,1.* count(case when t3.DescNomeProduto = 'Troca de Pontos StreamElements' then t1.IdTransacao end) / count(t1.IdTransacao) as qtd_TrocadePontosStreamElements
        ,1.* count(case when t3.DescNomeProduto = 'Reembolso: Troca de Pontos StreamElements' then t1.IdTransacao end) / count(t1.IdTransacao) as qtd_Reembolso_StreamElements
            -- Agrupando alguns produtos pra usar a categoria, por serem muitos
        ,1.* count(case when t3.DescCategoriaProduto = 'rpg' then t1.IdTransacao end) / count(t1.IdTransacao) as qtd_rpg
        ,1.* count(case when t3.DescCategoriaProduto = 'churn_model' then t1.IdTransacao end) / count(t1.IdTransacao) as qtd_churn_model
    from tb_transacao as t1
    left join transacao_produto t2
        on t1.IdTransacao = t2.IdTransacao
    left join produtos t3
        on t2.IdProduto = t3.IdProduto
    group by 1
)

, tb_join as (
    select
        t1.*
        ,t2.qtd_horas_vida
        ,t2.qtd_horas_D7
        ,t2.qtd_horas_D14
        ,t2.qtd_horas_D28
        ,t2.qtd_horas_D56
        ,t3.avg_intervalo_dias_vida
        ,t3.avg_intervalo_dias_D28
        ,t4.qtd_ChatMessage
        ,t4.qtd_AirflowLover
        ,t4.qtd_RLover
        ,t4.qtd_ResgatarPonei
        ,t4.qtd_Listadepresenca
        ,t4.qtd_PresencaStreak
        ,t4.qtd_TrocadePontosStreamElements
        ,t4.qtd_Reembolso_StreamElements
        ,t4.qtd_rpg
        ,t4.qtd_churn_model
    from tb_agg_calculada t1
    left join tb_hora_cliente t2
        on t1.idcliente = t2.idcliente
    left join tb_intervalo_dias t3
        on t1.idcliente = t3.idcliente
    left join tb_share_produtos t4
        on t1.idCliente = t4.idCliente
)
SELECT
date('{date}', '-1 day') as data_ref
,*
from tb_join
;