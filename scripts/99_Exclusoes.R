# Lista todos os arquivos na pasta BP
arquivos <- list.files("./data/CVM/Dados_CVM/DemonstracoesFinanceiras/BP/")

# Remove cada arquivo individualmente
for (arquivo in arquivos) {
  file.remove(paste0("./data/CVM/Dados_CVM/DemonstracoesFinanceiras/BP/", arquivo))
}

# Lista todos os arquivos na pasta DRE
arquivos <- list.files("./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DRE/")

# Remove cada arquivo individualmente
for (arquivo in arquivos) {
  file.remove(paste0("./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DRE/", arquivo))
}

# Lista todos os arquivos na pasta DFC_MD
arquivos <- list.files("./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DFC_MD/")

# Remove cada arquivo individualmente
for (arquivo in arquivos) {
  file.remove(paste0("./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DFC_MD/", arquivo))
}

# Lista todos os arquivos na pasta DFC_MI
arquivos <- list.files("./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DFC_MI/")

# Remove cada arquivo individualmente
for (arquivo in arquivos) {
  file.remove(paste0("./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DFC_MI/", arquivo))
}

# Lista todos os arquivos na pasta DMPL
arquivos <- list.files("./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DMPL/")

# Remove cada arquivo individualmente
for (arquivo in arquivos) {
  file.remove(paste0("./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DMPL/", arquivo))
}

# Lista todos os arquivos na pasta DVA
arquivos <- list.files("./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DVA/")

# Remove cada arquivo individualmente
for (arquivo in arquivos) {
  file.remove(paste0("./data/CVM/Dados_CVM/DemonstracoesFinanceiras/DVA/", arquivo))
}

