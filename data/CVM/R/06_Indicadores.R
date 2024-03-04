# Carregando bibliotecas
source("./data/CVM/R/00_Library.R")

# Carregando Arquivos
BP <- read.csv("./data/CVM/DemonstraçõesContabeis/BP.csv",
               sep = ",", 
               fileEncoding = "UTF-8",
               stringsAsFactors = FALSE)
DRE <- read.csv("./data/CVM/DemonstraçõesContabeis/DRE.csv",
               sep = ",",
               fileEncoding = "UTF-8",
               stringsAsFactors = FALSE)

# Transformações

## replicando periodos em BP (para calculos)
sort(unique(BP$PERIODO))
sort(unique(DRE$PERIODO))

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

## Salvando a estrutura das DFs, para consulta

### PERIODOS
length(unique(BP$PERIODO))
sort(unique(BP$PERIODO))
length(unique(DRE$PERIODO))
sort(unique(DRE$PERIODO))
struct_empresas <- unique(select(BP, CD_CVM, EMPRESA))

### EMPRESAS
length(unique(BP$CD_CVM))
length(unique(DRE$CD_CVM))
struct_empresas <- unique(select(BP, CD_CVM, EMPRESA))

### BP
struc_BP <- unique(select(BP, CD_CONTA, CONTA))
colnames(BP)

BP <- select(BP, CD_CVM, EMPRESA, CD_CONTA, PERIODO, VL_CONTA) %>% 
  # será mantido o CD_CVM para criar um ID junto com o PERIODO
  filter(VL_CONTA != 0) %>%
  arrange(CD_CONTA) %>%
  pivot_wider(names_from = CD_CONTA, values_from = VL_CONTA) %>%
  replace(is.na(.), 0)

### DRE
struc_DRE <- unique(select(DRE, CD_CONTA, CONTA))
colnames(DRE)
# DRE <- select(DRE, EMPRESA, CD_CONTA, PERIODO, VL_CONTA)

############### INDICADORES #################
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


# ENDIVIDAMENTO
ind_endividamento <- BP[c("EMPRESA", "PERIODO",
                          "1",
                          "2.01",
                          "2.01.04",
                          "2.02",
                          "2.02.01",
                          "2.03")]

# Calcular as colunas de liquidez
ind_endividamento$geral_ativo <- round((ind_endividamento$`2.01` + ind_endividamento$`2.02`) /
                                         ind_endividamento$`1` * 100, 2)
ind_endividamento$garantia_cap_proprio <- round(ind_endividamento$`2.03` / 
                                                (ind_endividamento$`2.01` + ind_endividamento$`2.02`)
                                                * 100, 2)
# 2.3) De Curto Prazo s/Total	21/(21+221) x 100
# 
#   23/(21+221) x 100
