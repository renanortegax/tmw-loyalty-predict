select * from life_cycle;

select
data_ref,
desc_life_cycle,
count(1)
from life_cycle
group by 1,2
order by 1,2