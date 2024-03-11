# Carregando bibliotecas
source("./data/CVM/R/07.1_liquidez.R")

indicadores <- select(ind_liquidez,
                      ID, EMPRESA, PERIODO, 
                      liq_geral, liq_corrente, liq_seca, liq_imediata)
