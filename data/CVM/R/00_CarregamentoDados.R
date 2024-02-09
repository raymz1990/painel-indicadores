####################### INSTRUÇÕES #######################
## Neste arquivo serão somente feito os tratamentos dos dados

library(httr)


# URL do arquivo FCA
url_fca <- "https://dados.cvm.gov.br/dados/CIA_ABERTA/CAD/DADOS/cad_cia_aberta.csv"

# URLs base dos arquivos ITR e DFP
url_itr_base <- "https://dados.cvm.gov.br/dados/CIA_ABERTA/DOC/ITR/DADOS/"
url_dfp_base <- "https://dados.cvm.gov.br/dados/CIA_ABERTA/DOC/DFP/DADOS/"

# Range de anos para ITR e DFP
anos_itr <- 2020:2023
anos_dfp <- 2020:2023

# Pasta de destino
pasta_destino <- "./data/CVM/Dados_CVM/"

# Verifica se a pasta de destino existe, se não, cria-a
if (!file.exists(pasta_destino)) {
  dir.create(pasta_destino, recursive = TRUE)
}

# Baixa o arquivo FCA
dest_fca <- file.path(pasta_destino, "Empresas/cad_cia_aberta.csv")
GET(url_fca, write_disk(dest_fca, overwrite = TRUE))

# Baixa os arquivos ITR
for (ano in anos_itr) {
  url_itr <- paste0(url_itr_base, "itr_cia_aberta_", ano, ".zip")
  dest_itr <- file.path(pasta_destino, paste0("Arquivos/itr_cia_aberta_", ano, ".zip"))
  GET(url_itr, write_disk(dest_itr, overwrite = TRUE))
}

# Baixa os arquivos DFP
for (ano in anos_dfp) {
  url_dfp <- paste0(url_dfp_base, "dfp_cia_aberta_", ano, ".zip")
  dest_dfp <- file.path(pasta_destino, paste0("Arquivos/dfp_cia_aberta_", ano, ".zip"))
  GET(url_dfp, write_disk(dest_dfp, overwrite = TRUE))
}


# Pastas de destino para itr_cia_aberta_ano.csv e dfp_cia_aberta_ano.csv
pasta_bp <- "./data/CVM/Dados_CVM/DemonstracoesFinanceiras/BP"
pasta_dfc_md <- "./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DFC_MD"
pasta_dfc_mi <- "./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DFC_MI"
pasta_dmpl <- "./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DMPL"
pasta_dre <- "./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DRE"
pasta_dva <- "./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DVA"
pasta_dados <- "./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DADOS"


# Extrair itr_cia_aberta_ano.csv e dfp_cia_aberta_ano.csv
#BP
for (ano in anos_itr) {
  arquivo_zip_itr <- file.path(pasta_destino, paste0("Arquivos/itr_cia_aberta_", ano, ".zip"))
  for (tipo_con in c("BPA_con", "BPP_con")) {
    arquivo_csv_itr <- paste0("itr_cia_aberta_", tipo_con, "_", ano, ".csv")
    unzip(arquivo_zip_itr, files = arquivo_csv_itr, exdir = pasta_bp)
  }
}

for (ano in anos_dfp) {
  arquivo_zip_dfp <- file.path(pasta_destino, paste0("Arquivos/dfp_cia_aberta_", ano, ".zip"))
  for (tipo_con in c("BPA_con", "BPP_con")) {
    arquivo_csv_dfp <- paste0("dfp_cia_aberta_", tipo_con, "_", ano, ".csv")
    unzip(arquivo_zip_dfp, files = arquivo_csv_dfp, exdir = pasta_bp)
  }
}

#DFC_MD
for (ano in anos_itr) {
  arquivo_zip_itr <- file.path(pasta_destino, paste0("Arquivos/itr_cia_aberta_", ano, ".zip"))
  for (tipo_con in c("DFC_MD_con")) {
    arquivo_csv_itr <- paste0("itr_cia_aberta_", tipo_con, "_", ano, ".csv")
    unzip(arquivo_zip_itr, files = arquivo_csv_itr, exdir = pasta_dfc_md)
  }
}

for (ano in anos_dfp) {
  arquivo_zip_dfp <- file.path(pasta_destino, paste0("Arquivos/dfp_cia_aberta_", ano, ".zip"))
  for (tipo_con in c("DFC_MD_con")) {
    arquivo_csv_dfp <- paste0("dfp_cia_aberta_", tipo_con, "_", ano, ".csv")
    unzip(arquivo_zip_dfp, files = arquivo_csv_dfp, exdir = pasta_dfc_md)
  }
}

#DFC_MI
for (ano in anos_itr) {
  arquivo_zip_itr <- file.path(pasta_destino, paste0("Arquivos/itr_cia_aberta_", ano, ".zip"))
  for (tipo_con in c("DFC_MI_con")) {
    arquivo_csv_itr <- paste0("itr_cia_aberta_", tipo_con, "_", ano, ".csv")
    unzip(arquivo_zip_itr, files = arquivo_csv_itr, exdir = pasta_dfc_mi)
  }
}

for (ano in anos_dfp) {
  arquivo_zip_dfp <- file.path(pasta_destino, paste0("Arquivos/dfp_cia_aberta_", ano, ".zip"))
  for (tipo_con in c("DFC_MI_con")) {
    arquivo_csv_dfp <- paste0("dfp_cia_aberta_", tipo_con, "_", ano, ".csv")
    unzip(arquivo_zip_dfp, files = arquivo_csv_dfp, exdir = pasta_dfc_mi)
  }
}

#DMPL
for (ano in anos_itr) {
  arquivo_zip_itr <- file.path(pasta_destino, paste0("Arquivos/itr_cia_aberta_", ano, ".zip"))
  for (tipo_con in c("DMPL_con")) {
    arquivo_csv_itr <- paste0("itr_cia_aberta_", tipo_con, "_", ano, ".csv")
    unzip(arquivo_zip_itr, files = arquivo_csv_itr, exdir = pasta_dmpl)
  }
}

for (ano in anos_dfp) {
  arquivo_zip_dfp <- file.path(pasta_destino, paste0("Arquivos/dfp_cia_aberta_", ano, ".zip"))
  for (tipo_con in c("DMPL_con")) {
    arquivo_csv_dfp <- paste0("dfp_cia_aberta_", tipo_con, "_", ano, ".csv")
    unzip(arquivo_zip_dfp, files = arquivo_csv_dfp, exdir = pasta_dmpl)
  }
}

#DRE
for (ano in anos_itr) {
  arquivo_zip_itr <- file.path(pasta_destino, paste0("Arquivos/itr_cia_aberta_", ano, ".zip"))
  for (tipo_con in c("DRE_con")) {
    arquivo_csv_itr <- paste0("itr_cia_aberta_", tipo_con, "_", ano, ".csv")
    unzip(arquivo_zip_itr, files = arquivo_csv_itr, exdir = pasta_dre)
  }
}

for (ano in anos_dfp) {
  arquivo_zip_dfp <- file.path(pasta_destino, paste0("Arquivos/dfp_cia_aberta_", ano, ".zip"))
  for (tipo_con in c("DRE_con")) {
    arquivo_csv_dfp <- paste0("dfp_cia_aberta_", tipo_con, "_", ano, ".csv")
    unzip(arquivo_zip_dfp, files = arquivo_csv_dfp, exdir = pasta_dre)
  }
}

#DVA
for (ano in anos_itr) {
  arquivo_zip_itr <- file.path(pasta_destino, paste0("Arquivos/itr_cia_aberta_", ano, ".zip"))
  for (tipo_con in c("DVA_con")) {
    arquivo_csv_itr <- paste0("itr_cia_aberta_", tipo_con, "_", ano, ".csv")
    unzip(arquivo_zip_itr, files = arquivo_csv_itr, exdir = pasta_dva)
  }
}

for (ano in anos_dfp) {
  arquivo_zip_dfp <- file.path(pasta_destino, paste0("Arquivos/dfp_cia_aberta_", ano, ".zip"))
  for (tipo_con in c("DVA_con")) {
    arquivo_csv_dfp <- paste0("dfp_cia_aberta_", tipo_con, "_", ano, ".csv")
    unzip(arquivo_zip_dfp, files = arquivo_csv_dfp, exdir = pasta_dva)
  }
}

#DADOS
for (ano in anos_itr) {
  arquivo_zip_itr <- file.path(pasta_destino, paste0("Arquivos/itr_cia_aberta_", ano, ".zip"))
  arquivo_csv_itr <- paste0("itr_cia_aberta_", ano, ".csv")
  unzip(arquivo_zip_itr, files = arquivo_csv_itr, exdir = pasta_dados)
}

for (ano in anos_dfp) {
  arquivo_zip_dfp <- file.path(pasta_destino, paste0("Arquivos/dfp_cia_aberta_", ano, ".zip"))
  arquivo_csv_dfp <- paste0("dfp_cia_aberta_", ano, ".csv")
  unzip(arquivo_zip_dfp, files = arquivo_csv_dfp, exdir = pasta_dados)
}

