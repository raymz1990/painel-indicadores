# Carregando bibliotecas
source("./data/CVM/R/07.1_liquidez.R")
source("./data/CVM/R/07.2_endividamento.R")
source("./data/CVM/R/07.3_lucratividade.R")

indicadores <- 
  ind_liquidez %>%
  left_join(., ind_lucratividade, 
            by = "ID")
origin_flights = flights2 %>% 
  inner_join(airports, by = c("origin"= "faa"))

origin_flights = flights2 %>% 
  inner_join(airports, join_by(origin == faa))

indicadores <-
  ind_liquidez %>%
  inner_join(ind_lucratividade,
             join_by(ID == ID))
