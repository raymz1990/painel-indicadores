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

# Filtrando somente os trimestres
BP <- filter(BP, grepl("t", PERIODO, ignore.case = TRUE))

## Salvando a estrutura das DFs, para consulta

### PERIODOS (verificar)
length(unique(BP$PERIODO))
sort(unique(BP$PERIODO))
length(unique(DRE$PERIODO))
sort(unique(DRE$PERIODO))

struct_trimestre <- unique(select(BP, PERIODO))
struct_trimestre <- filter(struct_trimestre, grepl("t", PERIODO, ignore.case = TRUE))

#### Definindo a ordem decrescente
struct_trimestre$ORDER <- paste0(substr(struct_trimestre$PERIODO, 3, 4),
                                 substr(struct_trimestre$PERIODO, 1, 2))

struct_trimestre <- struct_trimestre[order(struct_trimestre$ORDER, decreasing = TRUE), ]

### EMPRESAS
length(unique(BP$CD_CVM))
length(unique(DRE$CD_CVM))

struct_empresas <- BP %>%
  select(CD_CVM, EMPRESA) %>%
  distinct() %>%
  arrange(EMPRESA)

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

DRE <- select(DRE, CD_CVM, EMPRESA, CD_CONTA, PERIODO, VL_CONTA) %>% 
  # será mantido o CD_CVM para criar um ID junto com o PERIODO
  filter(VL_CONTA != 0) %>%
  arrange(CD_CONTA) %>%
  pivot_wider(names_from = CD_CONTA, values_from = VL_CONTA) %>%
  replace(is.na(.), 0)

