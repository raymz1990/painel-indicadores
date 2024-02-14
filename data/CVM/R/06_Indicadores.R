# Carregando bibliotecas
source("./data/CVM/R/00_Library.R")

# Carregando Arquivos
BP <- read.csv("./data/CVM/DemonstraçõesContabeis/BP.csv",
               sep = ",", 
               fileEncoding = "ISO-8859-1",
               stringsAsFactors = FALSE)
DRE <- read.csv("./data/CVM/DemonstraçõesContabeis/DRE.csv",
               sep = ",",
               fileEncoding = "ISO-8859-1",
               stringsAsFactors = FALSE)

# Transformações
## Renomeando colunas TRIMESTRE
BP <- rename(BP, PERIODO = TRIMESTRE)

## replicando periodos em BP (para calculos)
sort(unique(BP$PERIODO))
sort(unique(DRE$PERIODO))

colnames(BP)

# Criar um novo dataframe para fazer as transformações
BP2 <- BP %>%
  mutate(PERIODO = case_when(
    grepl("^2T", PERIODO) ~ str_replace(PERIODO, '2T', '1S'),
    grepl("^3T", PERIODO) ~ str_replace(PERIODO, '3T', '9M'),
    grepl("^4T", PERIODO) ~ str_replace(PERIODO, '4T', '20'),
    TRUE ~ PERIODO
  )) %>%
  filter(!grepl("^1T", PERIODO))  # Filtrar os valores "1T" 

# Combinando o novo dataframe com o antigo:
BP <- bind_rows(BP, BP2)


####################
refazer
- manter os arquivos BP e DRE antes de converter as empresas em colunas
- neste arquivo criar um dicionario (ou estrutura) em que mantem o CD_CONTA e CONTA. ]
  Depois excluir a coluna CONTA e converter CD_CONTA em colunas para calcular indicadores
- Indicadores sera um novo datraframe. fazer para cada grupo.