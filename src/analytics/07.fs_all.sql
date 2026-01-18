select
    t1.data_ref
    ,t1.idCliente
    ,t1.idade_dias
    ,t1.qtd_ativacao_vida
    ,t1.qtd_ativacao_D7
    ,t1.qtd_ativacao_D14
    ,t1.qtd_ativacao_D28
    ,t1.qtd_ativacao_D56
    ,t1.qtd_transacao_vida
    ,t1.qtd_transacao_D7
    ,t1.qtd_transacao_D14
    ,t1.qtd_transacao_D28
    ,t1.qtd_transacao_D56
    ,t1.saldo_vida
    ,t1.saldo_D7
    ,t1.saldo_D14
    ,t1.saldo_D28
    ,t1.saldo_D56
    ,t1.qtd_pontos_pos_vida
    ,t1.qtd_pontos_pos_D7
    ,t1.qtd_pontos_pos_D14
    ,t1.qtd_pontos_pos_D28
    ,t1.qtd_pontos_pos_D56
    ,t1.qtd_pontos_negativ_vida
    ,t1.qtd_pontos_negativ_D7
    ,t1.qtd_pontos_negativ_D14
    ,t1.qtd_pontos_negativ_D28
    ,t1.qtd_pontos_negativ_D56
    ,t1.qtd_transacao_manha
    ,t1.qtd_transacao_tarde
    ,t1.qtd_transacao_noite
    ,t1.pct_transacao_manha
    ,t1.pct_transacao_tarde
    ,t1.pct_transacao_noite
    ,t1.qtd_transacao_dia_vida
    ,t1.qtd_transacao_dia_D7
    ,t1.qtd_transacao_dia_D14
    ,t1.qtd_transacao_dia_D28
    ,t1.qtd_transacao_dia_D56
    ,t1.pct_ativacao_mau
    ,t1.qtd_horas_vida
    ,t1.qtd_horas_D7
    ,t1.qtd_horas_D14
    ,t1.qtd_horas_D28
    ,t1.qtd_horas_D56
    ,t1.avg_intervalo_dias_vida
    ,t1.avg_intervalo_dias_D28
    ,t1.qtd_ChatMessage
    ,t1.qtd_AirflowLover
    ,t1.qtd_RLover
    ,t1.qtd_ResgatarPonei
    ,t1.qtd_Listadepresenca
    ,t1.qtd_PresencaStreak
    ,t1.qtd_TrocadePontosStreamElements
    ,t1.qtd_Reembolso_StreamElements
    ,t1.qtd_rpg
    ,t1.qtd_churn_model
    ,t2.desc_life_cycle_atual
    ,t2.qtd_frequencia
    ,t2.desc_life_cycle_D28
    ,t2.pct_Curioso
    ,t2.pct_Fiel
    ,t2.pct_Reborn
    ,t2.pct_Reconquistado
    ,t2.pct_Turista
    ,t2.pct_Desencantado
    ,t2.pct_Zumbi
    ,t2.avg_freq_grupo
    ,t2.ratio_freq_grupo
    ,t3.qtd_cursos_completos
    ,t3.qtd_cursos_incompletos
    ,t3.carreira
    ,t3.coletaDados2024
    ,t3.dsDatabricks2024
    ,t3.dsPontos2024
    ,t3.estatistica2024
    ,t3.estatistica2025
    ,t3.github2024
    ,t3.github2025
    ,t3.iaCanal2025
    ,t3.lagoMago2024
    ,t3.loyaltyPredict2025
    ,t3.machineLearning2025
    ,t3.ml2024
    ,t3.mlflow2025
    ,t3.pandas2024
    ,t3.pandas2025
    ,t3.python2024
    ,t3.python2025
    ,t3.sql2020
    ,t3.sql2025
    ,t3.streamlit2025
    ,t3.tramparLakehouse2024
    ,t3.tseAnalytics2024
    ,t3.qtd_dias_ult_atividade
from fs_transacional t1
left join fs_lifecycle t2
    on t1.idCliente = t2.idCliente
    and t1.data_ref = t2.data_ref
left join fs_education t3
    on t1.idCliente = t3.idCliente
    and t1.data_ref = t3.data_ref
where 1=1
    and t2.data_ref is not null

    and t1.data_ref = (select max(data_ref) from fs_transacional)
