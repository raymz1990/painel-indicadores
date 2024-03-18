# Carregando bibliotecas
source("./data/CVM/R/06_Estrutura.R")

# LIQUIDEZ
ind_lucratividade <- DRE_ano[c("CD_CVM", "EMPRESA", "PERIODO",
                               "3.01", # ROL
                               "3.02", # Custos
                               "3.03", # Lucro Bruto
                               "3.04", # Despesas Operacionais
                               "3.05", # EBIT
                               "3.06", # Resultado Financeiro
                               "3.07", # Resultado antes lucros
                               "3.11")] # Lucro Liquido

# Calcular as colunas de lucratividade
ind_lucratividade$margem_bruta <- 
  paste0(round((-ind_lucratividade$`3.02`) / (ind_lucratividade$`3.01`) * 100, 2), "%")

ind_lucratividade$margem_ebit <- 
  paste0(round((ind_lucratividade$`3.05`) / (ind_lucratividade$`3.01`) * 100, 2), "%")

ind_lucratividade$margem_liquida <- 
  paste0(round((ind_lucratividade$`3.11`) / (ind_lucratividade$`3.01`) * 100, 2), "%")



colnames(ind_lucratividade)
ind_lucratividade <- select(ind_lucratividade, CD_CVM, EMPRESA, PERIODO,
                            margem_bruta, margem_ebit, margem_liquida)

ind_lucratividade$ID <- paste0(ind_lucratividade$CD_CVM, " - ", 
                               ind_lucratividade$EMPRESA, " - ",
                               ind_lucratividade$PERIODO)


