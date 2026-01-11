with tb_lifecycle_atual as (
    select
    idcliente
    ,desc_life_cycle as desc_life_cycle_atual
    ,qtd_frequencia
    from life_cycle
    where 1=1
        and data_ref = date('{date}', '-1 day')
)
, tb_lifecycle_D28 as (
    select
    idcliente
    ,desc_life_cycle as desc_life_cycle_D28
    from life_cycle
    where 1=1
        and data_ref = date('{date}','-29 day')
)
, tb_share_ciclos as (
    select
        idcliente
        ,1.* sum(case when desc_life_cycle = '01.Curioso' then 1 else 0 end) / count(*) as pct_Curioso
        ,1.* sum(case when desc_life_cycle = '02.Fiel' then 1 else 0 end) / count(*) as pct_Fiel
        ,1.* sum(case when desc_life_cycle = '02.Reborn' then 1 else 0 end) / count(*) as pct_Reborn
        ,1.* sum(case when desc_life_cycle = '02.Reconquistado' then 1 else 0 end) / count(*) as pct_Reconquistado
        ,1.* sum(case when desc_life_cycle = '03.Turista' then 1 else 0 end) / count(*) as pct_Turista
        ,1.* sum(case when desc_life_cycle = '04.Desencantado' then 1 else 0 end) / count(*) as pct_Desencantado
        ,1.* sum(case when desc_life_cycle = '05.Zumbi' then 1 else 0 end) / count(*) as pct_Zumbi
    from life_cycle
    where 1=1
        and data_ref < '{date}'
    group by 1
)
, tb_avg_ciclo as (
    select
    desc_life_cycle_atual,
    avg(qtd_frequencia) as avg_freq_grupo
    from tb_lifecycle_atual
    group by 1
)
, tb_join as (
    select
    t1.*
    ,t2.desc_life_cycle_D28
    ,t3.pct_Curioso
    ,t3.pct_Fiel
    ,t3.pct_Reborn
    ,t3.pct_Reconquistado
    ,t3.pct_Turista
    ,t3.pct_Desencantado
    ,t3.pct_Zumbi
    ,t4.avg_freq_grupo
    ,1.* t1.qtd_frequencia / t4.avg_freq_grupo as ratio_freq_grupo
    from tb_lifecycle_atual t1
    left join tb_lifecycle_D28 t2
        on t1.idcliente = t2.idcliente
    left join tb_share_ciclos t3
        on t1.idcliente = t3.idcliente
    left join tb_avg_ciclo t4
        on t1.desc_life_cycle_atual = t4.desc_life_cycle_atual
)
select
date('{date}', '-1 day') as data_ref,
*
from tb_join
where 1=1
    and date('{date}', '-1 day')