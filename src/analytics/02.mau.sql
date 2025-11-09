-- SQLite:  ctrl + shift + q
-- SQLTools: ctrl + E crtl + E
/*
-- MAU: Monthly Active Users: considerando qtd de usuario que teve transacao por mes
*/
select
substr(DtCriacao, 0, 8) as MesAno,
count(DISTINCT idCliente) as DAU
from transacoes
group by 1
order by 1;

-- Normalizando pra 28 dias pra trás do dia de referencia - 4 semanas - 4 dias da semana nas 4 semanas
    -- tem um periodo que o bot nao ficava ligado de fds, por isso que tem menos
with tb_diario as (
    select
    substr(DtCriacao, 0, 11) as DtDia,
    idCliente
    from transacoes
    group by 1
)
, tb_dias_distintos as (
    select distinct DtDia as dtRef from tb_diario
)
SELECT
t1.dtref,
count(distinct idcliente) as MAU,
count(DISTINCT t2.dtdia) as qtdDias
from tb_dias_distintos t1
left join tb_diario t2
    on t2.dtdia <= t1.dtRef
    -- julianday referencia numerica daquele dia
    and julianday(t1.dtref) - julianday(t2.dtdia) < 28
group by 1
order by 1;