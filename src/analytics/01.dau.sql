-- SQLite:  ctrl + shift + q
-- SQLTools: ctrl + E crtl + E
/*
-- DAU: Daily Active Users: considerando qtd de usuario que teve transacao por dia
*/
select
substr(DtCriacao, 0, 11) as DtDia,
count(DISTINCT idCliente) as DAU
from transacoes
group by 1
order by 1;

