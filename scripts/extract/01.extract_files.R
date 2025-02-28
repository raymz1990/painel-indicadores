# Script: 01.extract_files.R
# Objetivo: Realizar a extração e descompactação dos arquivos .zip.
# Funcionalidades:
# Identificar e listar os arquivos .zip na pasta data/raw/.
# Descompactar os arquivos e organizar os dados CSV em subpastas nomeadas por trimestre ou ano dentro de data/raw/.
# Criar logs para acompanhar o processo de extração.

library(httr)

# Configurações
config <- list(
  url_fca = "https://dados.cvm.gov.br/dados/CIA_ABERTA/CAD/DADOS/cad_cia_aberta.csv",
  url_itr_base = "https://dados.cvm.gov.br/dados/CIA_ABERTA/DOC/ITR/DADOS/",
  url_dfp_base = "https://dados.cvm.gov.br/dados/CIA_ABERTA/DOC/DFP/DADOS/",
  anos = 2022:2024,
  pasta_destino = "./data/cvm/raw/"
)

# Funções
baixar_arquivo <- function(url, destino) {
  GET(url, write_disk(destino, overwrite = TRUE))
  message("Download concluído: ", destino)
}

descompactar_arquivo <- function(arquivo_zip, arquivos_csv, pasta_destino) {
  for (arquivo_csv in arquivos_csv) {
    unzip(arquivo_zip, files = arquivo_csv, exdir = pasta_destino)
  }
  message("Arquivos extraídos para: ", pasta_destino)
}

log_atividade <- function(mensagem) {
  log_file <- "./data/cvm/logs/extract_files.log"
  write(paste(Sys.time(), "-", mensagem), file = log_file, append = TRUE)
}

excluir_arquivo_zip <- function(arquivo_zip) {
  if (file.exists(arquivo_zip)) {
    file.remove(arquivo_zip)
    log_atividade(paste("Arquivo ZIP excluído:", arquivo_zip))
  } else {
    log_atividade(paste("Arquivo ZIP não encontrado:", arquivo_zip))
  }
}

# Criação de diretórios
pastas <- list(
  "./data/cvm/raw/zip",                 # Para arquivos ZIP baixados
  "./data/cvm/raw/csv",                 # Para arquivos CSV extraídos
  "./data/cvm/raw/csv/bp",              # Balanço Patrimonial
  "./data/cvm/raw/csv/dfc_md",          # Demonstração de Fluxo de Caixa - Método Direto
  "./data/cvm/raw/csv/dfc_mi",          # Demonstração de Fluxo de Caixa - Método Indireto
  "./data/cvm/raw/csv/dmpl",            # Demonstração de Mutações do Patrimônio Líquido
  "./data/cvm/raw/csv/dre",             # Demonstração de Resultado do Exercício
  "./data/cvm/raw/csv/dva",             # Demonstração do Valor Adicionado
  "./data/cvm/raw/csv/dados",           # Arquivos gerais de dados
  "./data/cvm/raw/csv/empresa",         # Arquivos dados das empresas
  "./data/cvm/logs"                     # Logs do processo
)

for (pasta in pastas) {
  if (!dir.exists(pasta)) {
    dir.create(pasta, recursive = TRUE)
    message("Pasta criada: ", pasta)
  }
}

# Download do FCA
dest_fca <- file.path(config$pasta_destino, "csv/empresa/cad_cia_aberta.csv")
baixar_arquivo(config$url_fca, dest_fca)

# Download e extração de arquivos ITR e DFP
for (ano in config$anos) {
  # URLs
  url_itr <- paste0(config$url_itr_base, "itr_cia_aberta_", ano, ".zip")
  url_dfp <- paste0(config$url_dfp_base, "dfp_cia_aberta_", ano, ".zip")

  # Caminhos de destino
  dest_itr <- file.path(config$pasta_destino, paste0("zip/itr_cia_aberta_", ano, ".zip"))
  dest_dfp <- file.path(config$pasta_destino, paste0("zip/dfp_cia_aberta_", ano, ".zip"))

  # Download
  baixar_arquivo(url_itr, dest_itr)
  baixar_arquivo(url_dfp, dest_dfp)

  # Extração
  tipos <- list(
    BP = c("BPA_con", "BPP_con"),
    DFC_MD = c("DFC_MD_con"),
    DFC_MI = c("DFC_MI_con"),
    DMPL = c("DMPL_con"),
    DRE = c("DRE_con"),
    DVA = c("DVA_con")
  )

  for (tipo in names(tipos)) {
    pasta_tipo <- file.path(config$pasta_destino, "csv", tolower(tipo))
    if (!file.exists(pasta_tipo)) dir.create(pasta_tipo, recursive = TRUE)

    descompactar_arquivo(dest_itr, paste0("itr_cia_aberta_", tipos[[tipo]], "_", ano, ".csv"), pasta_tipo)
    descompactar_arquivo(dest_dfp, paste0("dfp_cia_aberta_", tipos[[tipo]], "_", ano, ".csv"), pasta_tipo)
  }
}

# Download e extração dos Dados
for (ano in config$anos) {
  # Caminhos para os arquivos ZIP
  dest_itr <- file.path(config$pasta_destino, paste0("zip/itr_cia_aberta_", ano, ".zip"))
  dest_dfp <- file.path(config$pasta_destino, paste0("zip/dfp_cia_aberta_", ano, ".zip"))
  
  # Caminho para a pasta de destino
  pasta_dados <- file.path(config$pasta_destino, "csv", "dados")
  if (!file.exists(pasta_dados)) dir.create(pasta_dados, recursive = TRUE)
  
  # Extração dos arquivos "dados" diretamente
  arquivo_dados_itr <- paste0("itr_cia_aberta_", ano, ".csv")
  arquivo_dados_dfp <- paste0("dfp_cia_aberta_", ano, ".csv")
  
  descompactar_arquivo(dest_itr, arquivo_dados_itr, pasta_dados)
  descompactar_arquivo(dest_dfp, arquivo_dados_dfp, pasta_dados)
}

# Exclusão de arquivos .zip
for (ano in config$anos) {
  dest_itr <- file.path(config$pasta_destino, paste0("zip/itr_cia_aberta_", ano, ".zip"))
  dest_dfp <- file.path(config$pasta_destino, paste0("zip/dfp_cia_aberta_", ano, ".zip"))
  
  excluir_arquivo_zip(dest_itr)
  excluir_arquivo_zip(dest_dfp)
}
