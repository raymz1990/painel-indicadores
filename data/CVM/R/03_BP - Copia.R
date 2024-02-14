# Carregando empresas
source("./data/CVM/R/01_BaseDados.R")

# Carregando arquivos do BP

# definir os diretórios onde estão os arquivos CSV
dir_BP <- file.path("./data/CVM/Dados_CVM/DemonstracoesFinanceiras/BP")
# obter a lista de nomes de arquivos em cada diretório
arquivos_BP <- list.files(dir_BP, pattern = "\\.csv$")
# inicializar listas para armazenar os data frames
lista_BP <- list()
# loop através dos arquivos em cada diretório e ler cada um com read.csv
for (arquivo in arquivos_BP) {
  caminho_arquivo <- file.path(dir_BP, arquivo)
  df <- read.csv(caminho_arquivo, sep = ";", fileEncoding = "ISO-8859-1", stringsAsFactors = FALSE)
  lista_BP[[arquivo]] <- df
}
# combinar todos os data frames em um único data frame
BP <- do.call(rbind, lista_BP)



CD_CVM_unique <- unique(empresas$CD_CVM)

#### CONFIGURANDO DADOS BP ####
# alterando o formato da coluna CD_CVM
empresas$CD_CVM <- as.character(empresas$CD_CVM)
BP$CD_CVM <- as.character(BP$CD_CVM)
#BP$VL_CONTA <- as.integer((BP$VL_CONTA))
# filtrar as linhas que contém as empresas desejadas na coluna "DENOM_CIA"
BP <- subset(BP, CD_CVM %in% CD_CVM_unique & ORDEM_EXERC == "ÚLTIMO")
# Criando colunas Trimestre e Ano
BP$TRIMESTRE <- paste0(as.numeric(substr(BP$DT_REFER, 6, 7)) / 3, 'T', 
                       as.numeric(substr(BP$DT_REFER, 3, 4)))
BP$ANO <- as.numeric(substr(BP$DT_REFER, 1, 4))


# Criando colunas Trimestre e Ano
## BP
#trimestre <- as.integer(format(BP$TRIMESTRE, "%m")) / 3 # Extrair o trimestre e os dois últimos digitos do ano
#ano <- format(BP$TRIMESTRE, "%y")
#BP$TRIMESTRE <- paste0(trimestre, "T", ano) # Criar a coluna formatada
#BP$ANO <- format(as.Date(BP$DT_REFER), "%Y")

### BP
# Verificado que as empresas possuem nomenclaturas diferentes em seus planos de contas, buscou-se reduzir a base dados,
# e agrupar algumas informações para padronizar todas as DF.

#unique(BP$DS_CONTA)
contas_bp <- BP[, c('CD_CONTA', 'DS_CONTA')]
contas_bp <- unique(contas_bp)


# Criando uma nova tabela BP
BP$NIVEL <- nchar(BP$CD_CONTA)
BP$CLASSE <- ifelse(BP$NIVEL == 1, as.character(BP$NIVEL), substr(BP$CD_CONTA, 1, 4))
contas_bp <- BP[, c('NIVEL', 'CLASSE', 'CD_CONTA', 'DS_CONTA', 'ST_CONTA_FIXA')]
contas_bp <- unique(contas_bp)

BP <- subset(BP, (CLASSE == 1.02 & NIVEL <= 10) | (CLASSE != 1.02 & NIVEL <= 7))

BP$CONTA <- paste(BP$CD_CONTA, "-", BP$DS_CONTA)

#unique(BP$CONTA)

# Renomear os valores da coluna "CONTA" com base nas regras
BP <- BP %>%
  mutate(CONTA = case_when(
    CONTA %in% c("1.01.05 - Ativos Biológicos", 
                 "1.01.06 - Tributos a Recuperar", 
                 "1.01.07 - Despesas Antecipadas", 
                 "1.01.08 - Outros Ativos Circulantes") 
    ~ "1.01.05 - Outros Ativos Circulantes",
    CONTA %in% c("1.02.01.01 - Aplicações Financeiras Avaliadas a Valor Justo através do Resultado", 
                 "1.02.01.02 - Aplicações Financeiras Avaliadas a Valor Justo através de Outros Resultados Abrangentes", 
                 "1.02.01.03 - Aplicações Financeiras Avaliadas ao Custo Amortizado", 
                 "1.02.01.01 - Aplicações Financeiras Avaliadas a Valor Justo", 
                 "1.02.01.02 - Aplicações Financeiras Avaliadas ao Custo Amortizado") 
    ~ "1.02.01.01 - Aplicações Financeiras",
    CONTA %in% c("1.02.01.04 - Contas a Receber", 
                 "1.02.01.03 - Contas a Receber") 
    ~ "1.02.01.02 - Contas a Receber",
    CONTA %in% c("1.02.01.05 - Estoques", 
                 "1.02.01.04 - Estoques") 
    ~ "1.02.01.03 - Estoques",
    CONTA %in% c("1.02.01.06 - Ativos Biológicos", 
                 "1.02.01.07 - Tributos Diferidos", 
                 "1.02.01.08 - Despesas Antecipadas", 
                 "1.02.01.10 - Outros Ativos Não Circulantes", 
                 "1.02.01.05 - Ativos Biológicos", 
                 "1.02.01.06 - Tributos Diferidos", 
                 "1.02.01.07 - Despesas Antecipadas", 
                 "1.02.01.09 - Outros Ativos Não Circulantes") 
    ~ "1.02.01.05 - Outros Ativos Não Circulantes",
    CONTA %in% c("1.02.01.09 - Créditos com Partes Relacionadas", 
                 "1.02.01.08 - Créditos com Partes Relacionadas") 
    ~ "1.02.01.04 - Créditos com Partes Relacionadas",
    CONTA == "1.02.02 - Investimentos" 
    ~ "1.02.02 - Investimentos",
    CONTA == "1.02.03 - Imobilizado" 
    ~ "1.02.03 - Imobilizado",
    CONTA == "1.02.04 - Intangível" 
    ~ "1.02.04 - Intangível",
    CONTA %in% c("1.02.02.01 - Participações Societárias", 
                 "1.02.02.02 - Propriedades para Investimento", 
                 "1.02.03.01 - Imobilizado em Operação", 
                 "1.02.03.02 - Direito de Uso em Arrendamento", 
                 "1.02.03.03 - Imobilizado em Andamento", 
                 "1.02.04.01 - Intangíveis", 
                 "1.02.04.02 - Goodwill", 
                 "1.02.03.02 - Imobilizado Arrendado", 
                 "1.02.02.01 - Participações Societárias") 
    ~ "NA",
    CONTA %in% c("2.01.06 - Provisões", "2.01.07 - Passivos sobre Ativos Não-Correntes a Venda e Descontinuados") 
    ~ "2.01.05 - Outras Obrigações",
    CONTA %in% c("2.02.03 - Tributos Diferidos", 
                 "2.02.04 - Provisões", 
                 "2.02.05 - Passivos sobre Ativos Não-Correntes a Venda e Descontinuados", 
                 "2.02.06 - Lucros e Receitas a Apropriar") 
    ~ "2.02.02 - Outras Obrigações",
    CONTA == "2.03 - Patrimônio Líquido Consolidado" 
    ~ "2.03 - Patrimônio Líquido",
    TRUE ~ CONTA
  ))

BP <- BP %>% filter(CONTA != "NA")

BP <- right_join(BP, select(empresas, 'CD_CVM', 'EMPRESA'), by = "CD_CVM")

BP <- BP %>%select(CNPJ_CIA,
                   CD_CVM,
                   EMPRESA,
                   DENOM_CIA,
                   CD_CONTA,
                   DS_CONTA,
                   TRIMESTRE,
                   ANO,
                   CONTA,
                   VL_CONTA)

# Agrupar os dados e calcular a soma de VL_CONTA para cada grupo
BP <- BP %>%
  group_by(CD_CVM, EMPRESA, TRIMESTRE, ANO, CONTA) %>%
  mutate(VL_CONTA = sum(VL_CONTA)) %>%
  distinct(CD_CVM, EMPRESA, TRIMESTRE, ANO, CONTA, .keep_all = TRUE)


#### Salvando em .csv
colnames(BP)
BP <- ungroup(BP)
# BP2 <- select(BP, 'EMPRESA', 'CD_CONTA', 'CONTA', 'TRIMESTRE', 'VL_CONTA') %>%
#   filter(VL_CONTA != 0 & (TRIMESTRE == '4T22' | TRIMESTRE == '3T23')) %>%
#   arrange(EMPRESA) %>%
#   pivot_wider(names_from = EMPRESA, values_from = VL_CONTA) %>%
#   replace(is.na(.), 0)

BP2 <- select(BP, 'EMPRESA', 'CD_CONTA', 'CONTA', 'TRIMESTRE', 'VL_CONTA') %>%
  filter(VL_CONTA != 0) %>%
  arrange(EMPRESA) %>%
  pivot_wider(names_from = EMPRESA, values_from = VL_CONTA) %>%
  replace(is.na(.), 0)


# Verificando valores unicos de CONTA
sort(unique(BP2$CONTA))

# Salvando o dataframe em .csv
write.csv(BP2, file = "./data/CVM/DemonstraçõesContabeis/BP.csv", 
          row.names = FALSE, 
          fileEncoding = "UTF-8")

# Excluindo todos os arquivos na pasta
unlink("./data/CVM/Dados_CVM/DemonstracoesFinanceiras/BP/", recursive = TRUE)


###########################
## SALAVANDO EM CSV 4T20, 4T21, 4T22, 1T23, 2T23, 3T23

# BP4T20 <- BP2 %>%
#   filter(TRIMESTRE == '4T20')
# 
# BP4T21 <- BP2 %>%
#   filter(TRIMESTRE == '4T21')
# 
# 
# BP4T22 <- BP2 %>%
#   filter(TRIMESTRE == '4T22')
# 
# BP1T23 <- BP2 %>%
#   filter(TRIMESTRE == '1T23')
# 
# BP2T23 <- BP2 %>%
#   filter(TRIMESTRE == '2T23')
# 
# BP3T23 <- BP2 %>%
#   filter(TRIMESTRE == '3T23')

# Salvando o dataframe BP2 em um arquivo CSV chamado "BP2.csv"
# write.csv(BP4T20, file = "DemonstraçõesContabeis/BP_4T20.csv", row.names = FALSE, fileEncoding = "UTF-8")
# write.csv(BP4T21, file = "DemonstraçõesContabeis/BP_4T21.csv", row.names = FALSE, fileEncoding = "UTF-8")
# write.csv(BP4T22, file = "DemonstraçõesContabeis/BP_4T22.csv", row.names = FALSE, fileEncoding = "UTF-8")
# write.csv(BP1T23, file = "DemonstraçõesContabeis/BP_1T23.csv", row.names = FALSE, fileEncoding = "UTF-8")
# write.csv(BP2T23, file = "DemonstraçõesContabeis/BP_2T23.csv", row.names = FALSE, fileEncoding = "UTF-8")
# write.csv(BP3T23, file = "DemonstraçõesContabeis/BP_3T23.csv", row.names = FALSE, fileEncoding = "UTF-8")

####





# BP1 <- select(BP, 'CD_CVM', 'CONTA', 'TRIMESTRE', 'ANO', 'VL_CONTA') %>%
#   pivot_wider(names_from = CONTA, values_from = VL_CONTA)