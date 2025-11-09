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
    select
    idcliente,
    substr(dtcriacao,0,11) as dt_dia
    from transacoes
)
,max_date as (
    select julianday(max(dt_dia)) as max_day, date(dt_dia) as datacriacao_max
    from tb_daily
)
, tb_idade as (
    select
    idcliente,
    m.datacriacao_max,
    min(dt_dia) as dt_pri_transc,
    cast(max(m.max_day - julianday(d.dt_dia)) as int) as qtd_dias_prim_transac,
    max(dt_dia) as dt_ult_transc,
    cast(min(m.max_day - julianday(d.dt_dia)) as int) as qtd_dias_ult_transac
    from tb_daily d
    cross join max_date m
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
    cast( m.max_day - julianday(r.dt_dia) as int ) as qtd_dias_penult_transac
    from tb_rn r
    cross join max_date m
    where 1=1
        and rn = 2
)
, tb_lifecycle as (
    select
    t1.idcliente
    ,t1.datacriacao_max
    ,t1.qtd_dias_prim_transac
    ,t1.qtd_dias_ult_transac
    ,t2.qtd_dias_penult_transac
    ,case
        when t1.qtd_dias_prim_transac <= 7 then '01. Curioso'
        when t1.qtd_dias_ult_transac <= 7 and t2.qtd_dias_penult_transac - t1.qtd_dias_ult_transac <= 14 then '02. Fiel'
        when t1.qtd_dias_ult_transac between 8 and 14 then '03. Turista'
        when t1.qtd_dias_ult_transac between 15 and 28 then '04. Desencantado'
        when t1.qtd_dias_ult_transac > 28 then '05. Zumbi'
        when t1.qtd_dias_ult_transac <= 7 and t2.qtd_dias_penult_transac - t1.qtd_dias_ult_transac between 15 and 27 then '02.1 Reconquistado'
        when t1.qtd_dias_ult_transac <= 7 and t2.qtd_dias_penult_transac - t1.qtd_dias_ult_transac > 27 then '02.2 Reborn'
    end as desc_life_cycle
    from tb_idade t1
    left join tb_penultima_transac t2
        on t1.idcliente = t2.idcliente
)
select
desc_life_cycle,
descLifeCycle_TEO,
count(1) as qtd
from tb_lifecycle
group by 1
order by 1
;

