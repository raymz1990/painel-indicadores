# Carregando bibliotecas
source("./data/CVM/R/07.1_liquidez.R")
#source("./data/CVM/R/07.2_endividamento.R")
source("./data/CVM/R/07.3_lucratividade.R")

# indicadores <- 
#   ind_liquidez %>%
#   left_join(., ind_lucratividade, 
#             by = "ID")


indicadores <-
  ind_liquidez %>%
  inner_join(ind_lucratividade,
             join_by(ID == ID))

indicadores <- 
  select(indicadores,  
         "CD_CVM.x", 
         "EMPRESA.x",
         "PERIODO.x",  
         "liq_geral",  
         "liq_corrente", 
         "liq_seca",      
         "liq_imediata", 
         "ID", 
         "margem_bruta",  
         "margem_ebit",
         "margem_liquida")
