# Carregando bibliotecas
source("./data/CVM/R/06_Estrutura.R")

# LIQUIDEZ
ind_liquidez <- BP[c("CD_CVM", "EMPRESA", "PERIODO",
                     "1.01",
                     "1.01.01",
                     "1.01.02",
                     "1.01.04",
                     "1.02.01",
                     "2.01",
                     "2.02")]

# Calcular as colunas de liquidez
ind_liquidez$liq_geral <- round((ind_liquidez$`1.01` + ind_liquidez$`1.02.01`) / (ind_liquidez$`2.01` + ind_liquidez$`2.02`), 2)
ind_liquidez$liq_corrente <- round(ind_liquidez$`1.01` / ind_liquidez$`2.01`, 2)
ind_liquidez$liq_seca <- round((ind_liquidez$`1.01` - ind_liquidez$`1.01.04`) / ind_liquidez$`2.01`, 2)
ind_liquidez$liq_imediata <- round((ind_liquidez$`1.01.01` + ind_liquidez$`1.01.02`) / ind_liquidez$`2.01`, 2)

colnames(ind_liquidez)
ind_liquidez <- select(ind_liquidez, CD_CVM, EMPRESA, PERIODO,
                       liq_geral, liq_corrente, liq_seca, liq_seca, liq_imediata)

ind_liquidez$ID <- paste0(ind_liquidez$CD_CVM, " - ",
                          ind_liquidez$EMPRESA, " - ",
                          ind_liquidez$PERIODO)


