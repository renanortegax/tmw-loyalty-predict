/*
-- Idade na base:
1.) 0-7: curiosa (idade < 7)

-- Recencia: qtd de dias desde a ultima transacao
2.) 0-7: fiel -> recencia < 7 e recencia_anterior < 15
3.) 7-15: turista -> 7 <= recencia <= 14
4.) 15-28: desencantado -> 14 < recencia <= 28
5.) 28+ zumbi -> recencia > 28

-- Transições
6.) desencantada -> fiel: reconquistada -> recencia < 7 & 14 <= recencia_anterior <= 28
7.) zumbi -> fiel: reborn -> recencia < 7 e recencia_anterior > 28
-- Precisamos:
    - Idade
    - Ultima interação
    - Penultima interação
*/

with tb_daily as (
    select distinct
    idcliente,
    substr(dtcriacao,0,11) as dt_dia
    from transacoes
    where 1=1
        and dtcriacao < '{date}' -- dtcriacao esta como timestamp
)
, tb_idade as (
    select
    idcliente,
    min(dt_dia) as dt_pri_transc,
    cast(max(julianday('{date}') - julianday(d.dt_dia)) as int) as qtd_dias_prim_transac,
    max(dt_dia) as dt_ult_transc,
    cast(min(julianday('{date}') - julianday(d.dt_dia)) as int) as qtd_dias_ult_transac
    from tb_daily d
    group by 1
)
, tb_rn as (
    select
    idcliente,
    dt_dia,
    row_number() over(PARTITION BY idcliente order by dt_dia desc) RN
    from tb_daily
)
, tb_penultima_transac as (
    select
    r.idcliente,
    r.dt_dia,
    cast( julianday('{date}') - julianday(r.dt_dia) as int ) as qtd_dias_penult_transac
    from tb_rn r
    where 1=1
        and rn = 2
)
, tb_lifecycle as (
    select
    t1.idcliente
    ,t1.qtd_dias_prim_transac
    ,t1.qtd_dias_ult_transac
    ,t2.qtd_dias_penult_transac
    ,case
        when t1.qtd_dias_prim_transac <= 7 then '01.Curioso'
        when t1.qtd_dias_ult_transac <= 7 and t2.qtd_dias_penult_transac - t1.qtd_dias_ult_transac <= 14 then '02.Fiel'
        when t1.qtd_dias_ult_transac between 8 and 14 then '03.Turista'
        when t1.qtd_dias_ult_transac between 15 and 28 then '04.Desencantado'
        when t1.qtd_dias_ult_transac > 28 then '05.Zumbi'
        when t1.qtd_dias_ult_transac <= 7 and t2.qtd_dias_penult_transac - t1.qtd_dias_ult_transac between 15 and 27 then '02.Reconquistado'
        when t1.qtd_dias_ult_transac <= 7 and t2.qtd_dias_penult_transac - t1.qtd_dias_ult_transac > 27 then '02.Reborn'
    end as desc_life_cycle
    from tb_idade t1
    left join tb_penultima_transac t2
        on t1.idcliente = t2.idcliente
)
, tb_freq_valor as (
    select
    IdCliente,
    count(distinct substr(DtCriacao, 0, 11)) as qtd_frequencia,
    -- sum(QtdePontos),
    -- vamos considerar só positivo, pq pontos negativos são as trocas que a galera faz no chat
        -- se considerasse, iria reduzir a galera que trocou ponto
    sum(case when QtdePontos > 0 then QtdePontos else 0 end) as qtd_pontos
    from transacoes
    where 1=1
        and dtcriacao < '{date}'
        and DtCriacao >= date('{date}', '-28 days')
    group by 1
)
, tb_clusterizado as (
    /* Criado no ./05.frequencia_valor.sql */
    select
    IdCliente
    ,qtd_frequencia
    ,qtd_pontos
    ,case
        when qtd_frequencia <= 10 and qtd_pontos >= 1500 then '12-Hyper'
        when qtd_frequencia > 10 and qtd_pontos >= 1500 then '22-Eficiente'
        when qtd_frequencia <= 10 and qtd_pontos >= 750 then '11-Indeciso'
        when qtd_frequencia > 10 and qtd_pontos >= 750 then '21-Esforcado'
        when qtd_frequencia < 5 then '00-Lurker'
        when qtd_frequencia <= 10 then '01-Preguicoso'
        when qtd_frequencia > 10 then '20-Potencial'
    end as cluster
    from tb_freq_valor
)
select
date('{date}', '-1 day') as data_ref
,t1.idcliente
,t1.qtd_dias_prim_transac
,t1.qtd_dias_ult_transac
,t1.qtd_dias_penult_transac
,t1.desc_life_cycle
,t2.qtd_frequencia
,t2.qtd_pontos
,t2.cluster
from tb_lifecycle t1
left join tb_clusterizado t2
    on t1.IdCliente = t2.IdCliente
;