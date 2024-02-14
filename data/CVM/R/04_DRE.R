# Carregando empresas
# source("./data/CVM/R/01_BaseDados.R")

# Carregando arquivos do BP

# definir os diretórios onde estão os arquivos CSV
dir_DRE <- file.path("./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DRE")
# obter a lista de nomes de arquivos em cada diretório
arquivos_DRE <- list.files(dir_DRE, pattern = "\\.csv$")
# inicializar listas para armazenar os data frames
lista_DRE <- list()
# loop através dos arquivos em cada diretório e ler cada um com read.csv
for (arquivo in arquivos_DRE) {
  caminho_arquivo <- file.path(dir_DRE, arquivo)
  df <- read.csv(caminho_arquivo, sep = ";", fileEncoding = "ISO-8859-1", stringsAsFactors = FALSE)
  lista_DRE[[arquivo]] <- df
}
# combinar todos os data frames em um único data frame
DRE <- do.call(rbind, lista_DRE)


#### CONFIGURANDO DADOS DRE ####
# alterando o formato da coluna CD_CVM
DRE$CD_CVM <- as.character(DRE$CD_CVM)
empresas$CD_CVM <- as.character(empresas$CD_CVM)
# filtrar as linhas que contém as empresas desejadas na coluna "DENOM_CIA"
DRE <- subset(DRE, CD_CVM %in% CD_CVM_unique & ORDEM_EXERC == "ÚLTIMO")
# Criando colunas Trimestre e Ano
DRE$TRIMESTRE <- paste0(as.numeric(substr(DRE$DT_REFER, 6, 7)) / 3, 'T', 
                       as.numeric(substr(DRE$DT_REFER, 3, 4)))
DRE$ANO <- as.numeric(substr(DRE$DT_REFER, 1, 4))
# A DRE está criando 2 linhas para cada conta, 1 para o trimestre e 1 para o período acumulado
# solução: criar uma coluna PERIODO identificando quando é trimestre e o periodo acumulado

# P.S.1: Também foi identificado que algumas incossistencia no 1T de algumas empresas. Assim, estamos elimininando estas linhas com divergências
DRE <- subset(DRE, !(substr(DRE$DT_INI_EXERC, nchar(DRE$DT_INI_EXERC) - 4, nchar(DRE$DT_INI_EXERC)) == "03-01"))
DRE <- subset(DRE, !(substr(DRE$DT_INI_EXERC, nchar(DRE$DT_INI_EXERC) - 4, nchar(DRE$DT_INI_EXERC)) == "10-01"))

# No 1T não há mais incossistência. 
# No 2T, quando acumulado, será identificado como 6M + ano
# No 3T, quando acumulado, será identificado como 9M + ano
# No 4T está somente apresentando o acumulado. ** Deverá ser criado um calculo subtraindo o 9M
ano <- as.numeric(substr(DRE$DT_REFER, 3, 4))
DRE$PERIODO <- 
  ifelse(
    substr(DRE$TRIMESTRE, 1, 2) == "2T" &
      substr(DRE$DT_INI_EXERC, 6, 10) == "01-01", 
    paste0("6M", ano),
    ifelse(
      substr(DRE$TRIMESTRE, 1, 2) == "3T" & 
        substr(DRE$DT_INI_EXERC, nchar(DRE$DT_INI_EXERC) - 4, 
               nchar(DRE$DT_INI_EXERC)) == "01-01", 
      paste0("9M", ano),
      ifelse(
        substr(DRE$TRIMESTRE, 1, 2) == "4T", DRE$ANO,
        DRE$TRIMESTRE)))

# Verificando se não há nenhuma anormalidade nos dados (empresas tem demonstrado dados fora do padrão)
# Agrupe os dados para identificar as combinações com valores duplicados
# duplications <- DRE %>%
#  group_by(CD_CONTA, DS_CONTA, NIVEL, CLASSE, CONTA, PERIODO, DENOM_CIA, .groups = "drop") %>%
#  summarise(n = n()) %>%
#  filter(n > 1L) 

# unique(DRE$DS_CONTA)
contas_DRE <- DRE[, c('CD_CONTA', 'DS_CONTA')]
contas_DRE <- unique(contas_DRE)


# Criando uma nova tabela BP
DRE$NIVEL <- nchar(DRE$CD_CONTA)
DRE$CLASSE <- ifelse(DRE$NIVEL == 1, as.character(DRE$NIVEL), substr(DRE$CD_CONTA, 1, 4))
contas_DRE <- DRE[, c('NIVEL', 'CLASSE', 'CD_CONTA', 'DS_CONTA', 'ST_CONTA_FIXA')]
contas_DRE <- unique(contas_DRE)

DRE <- subset(DRE, (CLASSE == 1.02 & NIVEL <= 10) | (CLASSE != 1.02 & NIVEL <= 7))

DRE$CONTA <- paste(DRE$CD_CONTA, "-", DRE$DS_CONTA)

DRE <- right_join(DRE, select(empresas, 'CD_CVM', 'EMPRESA'), by = "CD_CVM")





DRE <- DRE %>%
  select(CNPJ_CIA,
         CD_CVM,
         EMPRESA,
         DENOM_CIA,
         CD_CONTA,
         DS_CONTA,
         PERIODO,
         ANO,
         CONTA,
         VL_CONTA)

# Agrupar os dados e calcular a soma de VL_CONTA para cada grupo
DRE <- DRE %>%
  group_by(CD_CVM, EMPRESA, PERIODO, ANO, CONTA) %>%
  mutate(VL_CONTA = sum(VL_CONTA)) %>%
  distinct(CD_CVM, EMPRESA, PERIODO, ANO, CONTA, .keep_all = TRUE)


#### Salvando em .csv
colnames(DRE)
DRE <- ungroup(DRE)
# DRE2 <- select(DRE, 'EMPRESA', 'CD_CONTA', 'CONTA', 'PERIODO', 'VL_CONTA') %>%
#   filter(VL_CONTA != 0 & (PERIODO == '2022' | PERIODO == '9M23')) %>%
#   arrange(EMPRESA) %>%
#   pivot_wider(names_from = EMPRESA, values_from = VL_CONTA) %>%
#   replace(is.na(.), 0)

# Supondo que BP2 é o seu dataframe e CONTA é a coluna que contém as descrições das linhas
DRE <- DRE[DRE$CONTA == "3.01 - Receita de Venda de Bens e/ou Serviços" | 
             DRE$CONTA == "3.02 - Custo dos Bens e/ou Serviços Vendidos" |
             DRE$CONTA == "3.03 - Resultado Bruto" |
             DRE$CONTA == "3.04 - Despesas/Receitas Operacionais" |
             DRE$CONTA == "3.04.01 - Despesas com Vendas" |
             DRE$CONTA == "3.04.02 - Despesas Gerais e Administrativas" |
             DRE$CONTA == "3.04.03 - Perdas pela Não Recuperabilidade de Ativos" |
             DRE$CONTA == "3.04.04 - Outras Receitas Operacionais" |
             DRE$CONTA == "3.04.05 - Outras Despesas Operacionais" |
             DRE$CONTA == "3.04.06 - Resultado de Equivalência Patrimonial" |
             DRE$CONTA == "3.05 - Resultado Antes do Resultado Financeiro e dos Tributos" |
             DRE$CONTA == "3.06 - Resultado Financeiro" |
             DRE$CONTA == "3.06.01 - Receitas Financeiras" |
             DRE$CONTA == "3.06.02 - Despesas Financeiras" |
             DRE$CONTA == "3.07 - Resultado Antes dos Tributos sobre o Lucro" |
             DRE$CONTA == "3.08 - Imposto de Renda e Contribuição Social sobre o Lucro" |
             DRE$CONTA == "3.09 - Resultado Líquido das Operações Continuadas" |
             DRE$CONTA == "3.10 - Resultado Líquido de Operações Descontinuadas" |
             DRE$CONTA == "3.11 - Lucro/Prejuízo Consolidado do Período" |
             DRE$CONTA == "3.11.01 - Atribuído a Sócios da Empresa Controladora" |
             DRE$CONTA == "3.11.02 - Atribuído a Sócios Não Controladores", ]


DRE2 <- select(DRE, 'EMPRESA', 'CD_CONTA', 'CONTA', 'PERIODO', 'VL_CONTA') %>%
  filter(VL_CONTA != 0) %>%
  arrange(EMPRESA) %>%
  pivot_wider(names_from = EMPRESA, values_from = VL_CONTA) %>%
  replace(is.na(.), 0)


sort(unique(DRE2$CONTA))

# Salvando o dataframe em .csv
write.csv(DRE2, file = "./data/CVM/DemonstraçõesContabeis/DRE.csv", 
           row.names = FALSE, 
          fileEncoding = "UTF-8")

# Excluindo todos os arquivos na pasta
unlink("./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DRE/", recursive = TRUE)


############################
##### SALVANDO EM .CSV


# DRE4T20 <- DRE2 %>%
#   filter(PERIODO == '2020')
# 
# DRE4T21 <- DRE2 %>%
#   filter(PERIODO == '2021')
# 
# DRE4T22 <- DRE2 %>%
#   filter(PERIODO == '2022')
# 
# DRE1T23 <- DRE2 %>%
#   filter(PERIODO == '1T23')
# 
# DRE2T23 <- DRE2 %>%
#   filter(PERIODO == '6M23')
# 
# DRE3T23 <- DRE2 %>%
#   filter(PERIODO == '9M23')
# 
# # Salvando o dataframe BP2 em um arquivo CSV chamado "BP2.csv"
# write.csv(DRE4T20, file = "DemonstraçõesContabeis/DRE_4T20.csv", row.names = FALSE, fileEncoding = "UTF-8")
# write.csv(DRE4T21, file = "DemonstraçõesContabeis/DRE_4T21.csv", row.names = FALSE, fileEncoding = "UTF-8")
# write.csv(DRE4T22, file = "DemonstraçõesContabeis/DRE_4T22.csv", row.names = FALSE, fileEncoding = "UTF-8")
# write.csv(DRE1T23, file = "DemonstraçõesContabeis/DRE_1T23.csv", row.names = FALSE, fileEncoding = "UTF-8")
# write.csv(DRE2T23, file = "DemonstraçõesContabeis/DRE_2T23.csv", row.names = FALSE, fileEncoding = "UTF-8")
# write.csv(DRE3T23, file = "DemonstraçõesContabeis/DRE_3T23.csv", row.names = FALSE, fileEncoding = "UTF-8")



