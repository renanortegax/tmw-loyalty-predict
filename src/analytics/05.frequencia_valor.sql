with tb_freq_valor as (
    select
    IdCliente,
    count(distinct substr(DtCriacao, 0, 11)) as qtd_frequencia,
    -- sum(QtdePontos),
    -- vamos considerar só positivo, pq pontos negativos são as trocas que a galera faz no chat
        -- se considerasse, iria reduzir a galera que trocou ponto
    sum(case when QtdePontos > 0 then QtdePontos else 0 end) as qtd_pontos
    from transacoes
    where 1=1
        and dtcriacao < '2025-09-01'
        and DtCriacao >= date('2025-09-01', '-28 days')
    group by 1
)
, tb_clusterizado as (
    select
    IdCliente
    ,qtd_frequencia
    ,qtd_pontos
    ,case
        when qtd_frequencia <= 10 and qtd_pontos > 1500 then 'Hyper'
        when qtd_frequencia > 10 and qtd_pontos >= 1500 then 'Eficiente'
        when qtd_frequencia <= 10 and qtd_pontos > 750 then 'Indeciso'
        when qtd_frequencia > 10 and qtd_pontos >= 7500 then 'Esforcado'
        when qtd_frequencia < 5 then 'Lurker'
        when qtd_frequencia <= 10 then 'Preguicoso'
        when qtd_frequencia > 10 then 'Potencial'
    end as cluster
    from tb_freq_valor
)
select
*
from tb_clusterizado;