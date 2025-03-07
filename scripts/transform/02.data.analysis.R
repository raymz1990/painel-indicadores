rm_list()

# Carregando bibliotecas
source("./scripts/setup/00.library.R")

# Diretório base dos arquivos extraídos
pasta_csv <- "./data/cvm/raw/csv"

# Lista arquivos por tipo
tipos <- c("bp", "dfc_md", "dfc_mi", "dmpl", "dre", "dva", "empresa", "dados")
arquivos <- lapply(tipos, function(tipo) {
  list.files(file.path(pasta_csv, tipo), pattern = "\\.csv$", full.names = TRUE)
})
names(arquivos) <- tipos

# Verifica a presença dos arquivos
lapply(names(arquivos), function(tipo) {
  message("Arquivos encontrados para ", tipo, ": ", length(arquivos[[tipo]]))
})

# Empresas ----

## Carregando arquivo
dir_cadastro <- file.path("./data/cvm/raw/csv/empresa/cad_cia_aberta.csv")
cadastro <- read.csv(dir_cadastro, sep = ";", fileEncoding = "ISO-8859-1", stringsAsFactors = FALSE)

## Verificando variaveis
colnames(cadastro)

### Excluindo cadastros inativos
unique(cadastro$SIT)
cad_sit <- cadastro$SIT == "ATIVO"

cadastro <- cadastro %>%
  subset(cad_sit)

### Verificando CNPJ duplicados
cad_duplicated <- cadastro %>%
  group_by(CNPJ_CIA) %>%
  filter(SIT == "ATIVO") %>%
  filter(n() > 1) %>%
  ungroup() %>%
  select("CNPJ_CIA", "DENOM_SOCIAL", "CATEG_REG", "SETOR_ATIV", "SIT_EMISSOR")

### Não encontrado o padrão das duplicações. Solução dividir tabelas (ID é pk)

#### empresa
empresa <- cadastro %>%
  select(CNPJ_CIA, DENOM_SOCIAL, DENOM_COMERC, CD_CVM, DT_REG, DT_CONST, SIT)%>%
  distinct()
unique(empresa$CNPJ_CIA)

#### Setor atividade
setor <- cadastro %>%
  select(CNPJ_CIA, DENOM_SOCIAL, SETOR_ATIV) %>%
  distinct()

#### padronização de setores
unique(setor$SETOR_ATIV)

# Criação do dicionário de padronização
padronizacao_setores <- list(
  "Energia" = c("Energia Elétrica", "Emp. Adm. Part. - Energia Elétrica", "Petróleo e Gás", "Emp. Adm. Part. - Petróleo e Gás"),
  "Metalurgia" = c("Metalurgia e Siderurgia", "Emp. Adm. Part. - Metalurgia e Siderurgia"),
  "Saneamento" = c("Saneamento, Serv. Água e Gás", "Emp. Adm. Part. - Saneamento, Serv. Água e Gás"),
  "Máquinas e Equipamentos" = c("Máquinas, Equipamentos, Veículos e Peças", "Emp. Adm. Part. - Máqs., Equip., Veíc. e Peças"),
  "Comunicação e Informática" = c("Comunicação e Informática", "Emp. Adm. Part. - Comunicação e Informática"),
  "Comércio" = c("Comércio (Atacado e Varejo)", "Emp. Adm. Part. - Comércio (Atacado e Varejo)"),
  "Saúde" = c("Serviços Médicos", "Farmacêutico e Higiene", "Emp. Adm. Part. - Serviços médicos"),
  "Construção Civil" = c("Construção Civil, Mat. Constr. e Decoração", "Emp. Adm. Part. - Const. Civil, Mat. Const. e Decoração"),
  "Alimentos" = c("Alimentos", "Emp. Adm. Part. - Alimentos"),
  "Turismo" = c("Hospedagem e Turismo", "Emp. Adm. Part. - Hospedagem e Turismo"),
  "Bancos" = c("Bancos", "Emp. Adm. Part. - Bancos"),
  "Mercado Financeiro" = c("Bolsas de Valores/Mercadorias e Futuros", "Arrendamento Mercantil", "Securitização de Recebíveis"),
  "Participações" = c("Emp. Adm. Part. - Sem Setor Principal"),
  "Intermediação Financeira" = c("Emp. Adm. Part. - Intermediação Financeira", "Intermediação Financeira"),
  "Extração Mineral" = c("Emp. Adm. Part. - Extração Mineral", "Extração Mineral"),
  "Transporte e Logística" = c("Emp. Adm. Part. - Serviços Transporte e Logística", "Serviços Transporte e Logística"),
  "Educação" = c("Emp. Adm. Part. - Educação", "Educação"),
  "Seguradoras" = c("Emp. Adm. Part. - Seguradoras e Corretoras", "Seguradoras e Corretoras"),
  "Crédito Imobiliário" = c("Emp. Adm. Part. - Crédito Imobiliário"),
  "Agricultura" = c("Agricultura (Açúcar, Álcool e Cana)", "Emp. Adm. Part. - Agricultura (Açúcar, Álcool e Cana)"),
  "Telecomunicações" = c("Emp. Adm. Part. - Telecomunicações", "Telecomunicações"),
  "Brinquedos e Lazer" = c("Emp. Adm. Part. - Brinquedos e Lazer", "Brinquedos e Lazer"),
  "Papel e Celulose" = c("Emp. Adm. Part. - Papel e Celulose", "Papel e Celulose"),
  "Têxtil e Vestuário" = c("Têxtil e Vestuário"),
  "Bebidas" = c("Bebidas e Fumo"),
  "Petroquímicos" = c("Petroquímicos e Borracha"),
  "Reflorestamento" = c("Reflorestamento"),
  "Embalagens" = c("Embalagens")
)

# Aplicação da padronização

## Setores de Atividades
setor$SETOR_PADRONIZADO <- setor$SETOR_ATIV
for (categoria in names(padronizacao_setores)) {
  setores_correspondentes <- padronizacao_setores[[categoria]]
  setor$SETOR_PADRONIZADO[setor$SETOR_ATIV %in% setores_correspondentes] <- categoria
}

unique(setor$SETOR_PADRONIZADO)

setor %>%
  group_by(SETOR_PADRONIZADO) %>%
  summarise(n = n()) %>%
  print(n = Inf)

## Nome de empresas
empresas <- setor %>%
  select(CNPJ_CIA, DENOM_SOCIAL, SETOR_PADRONIZADO) %>%
  distinct()

## Remoção de Sufixos Comuns
empresas$EMPRESA <- empresas$DENOM_SOCIAL
# nome$NOME_PADRONIZADO <- gsub(" S\\.?A\\.?| LTDA\\.?| CORP\\.?| EM LIQUIDAÇÃO EXTRAJUDICIAL| S\\/?A\\.?", "", nome$NOME_PADRONIZADO, ignore.case = TRUE)
# 2. Corrigir erros comuns de digitação (adicione correções específicas conforme necessário)
lista_nomes <- list(
  "2W ECOBANK S.A." = "2W Ecobank",
  "521 PARTICIPAÇOES S.A. - EM LIQUIDAÇÃO EXTRAJUDICIAL" = NULL, ## sem RI
  "524 PARTICIPAÇOES SA" = "524 Participações",
  "ACO VERDE DO BRASIL S.A" = "Aço Verde do Brasil",
  "AEGEA SANEAMENTO E PARTICIPAÇÕES S.A." = "Aegea",
  "AERIS IND. E COM. DE EQUIP. PARA GER. DE ENG. S.A." = "Aeris",
  "AFLUENTE TRANSMISSÃO DE ENERGIA ELETRICA S/A" = "Afluente", ## controlada pela Neonergia SA
  "AGASUS S.A." = "Voke",
  "AGROGALAXY PARTICIPAÇÕES S.A. - EM RECUPERAÇÃO JUDICIAL" = "AgroGalaxy",
  "ÁGUAS DE TERESINA SANEAMENTO SPE S.A." = "Águas de Teresina",
  ÁGUAS DO RIO 1 SPE S.A.
  ÁGUAS DO RIO 4 SPE S.A.
  ÁGUAS DO SERTAO S.A.
  AGUAS GUARIROBA S.A.
  ALFA HOLDINGS S.A.
  ALGAR TELECOM S/A
  ALLIANÇA SAÚDE E PARTICIPAÇÕES S.A.
  ALLIED TECNOLOGIA S.A.
  ALLOS S.A.
  ALLPARK EMPREENDIMENTOS, PARTICIPAÇÕES E SERVIÇOS S.A.
  ALMEIDA JUNIOR SHOPPING CENTERS S.A.
  ALPARGATAS SA
  ALPHAVILLE S.A.
  ALTHAIA S.A. INDÚSTRIA FARMACÊUTICA
  ALUBAR METAIS E CABOS S.A.
  ALUPAR INVESTIMENTO S/A
  ALVAREZ & MARSAL INVESTIMENTOS I S.A.
  AMBEV S.A.
  AMBIPAR PARTICIPAÇÕES E EMPREENDIMENTOS S.A.
  AMERICANAS S.A. - EM RECUPERAÇÃO JUDICIAL
  AMPLA ENERGIA E SERVIÇOS S.A.
  ANEMUS WIND HOLDING S.A.
  ANIMA HOLDING S/A
  ARGO ENERGIA EMPREENDIMENTOS E PARTICIPAÇÕES S.A.
  ARGO TRANSMISSÃO DE ENERGIA S.A.
  ARGO V TRANSMISSAO DE ENERGIA S.A.
  ARGO VI TRANSMISSAO DE ENERGIA S.A.
  ARGO VII TRANSMISSAO DE ENERGIA S.A.
  ARMAC LOCAÇÃO, LOGÍSTICA E SERVIÇOS S.A.
  ARTERIS S.A.
  ASA BRANCA HOLDING S.A.
  ASSURUÁ 4 E 5 HOLDING ENERGIA S.A.
  ATACADÃO S.A.
  ATMA PARTICIPACOES S.A. EM RECUPERACAO JUDICIAL
  ATOM EDUCAÇÃO E EDITORA S.A.
  ATOM EMPREENDIMENTOS E PARTICIPAÇÕES S.A.
  AURA ALMAS MINERAÇÃO S.A.
  AUREN ENERGIA S.A
  AUREN OPERAÇÕES S.A.
  AUREN PARTICIPAÇÕES S.A.
  AUTOMOB PARTICIPAÇÕES S.A.
  AUTOMOB S.A.
  AUTOPISTA FERNÃO DIAS SA
  AUTOPISTA FLUMINENSE SA
  AUTOPISTA LITORAL SUL
  AUTOPISTA PLANALTO SUL SA
  AUTOPISTA REGIS BITTENCOURT SA
  AZEVEDO & TRAVASSOS ENERGIA S.A.
  AZEVEDO & TRAVASSOS SA
  AZUL S.A.
  AZZAS 2154 S.A.
  B3 S.A. - BRASIL, BOLSA, BALCÃO
  BAHEMA EDUCACAO S.A.
  BANCO ABC BRASIL S/A
  BANCO BMG S/A
  BANCO BRADESCO S.A.
  BANCO BTG PACTUAL S/A
  BANCO DA AMAZÔNIA S.A.
  BANCO DAYCOVAL S.A.
  BANCO DO BRASIL S.A.
  BANCO DO ESTADO DE SERGIPE SA
  BANCO DO ESTADO DO PARÁ S/A.
  BANCO DO ESTADO DO RIO GRANDE DO SUL SA
  BANCO DO NORDESTE DO BRASIL SA
  BANCO MERCANTIL BRASIL SA
  BANCO MERCANTIL DE INVESTIMENTOS S.A.
  BANCO NACIONAL S.A. - EM LIQUIDAÇÃO EXTRAJUDICIAL
  BANCO PAN SA
  BANCO PINE S/A
  BANCO RCI BRASIL S.A.
  BANCO SANTANDER (BRASIL) S.A.
  BANESTES SA BANCO DO ESTADO DO ESPIRITO SANTO
  BARDELLA S.A. INDUSTRIAS MECANICAS - EM RECUPERAÇÃO JUDICIAL
  BAUMER SA
  BB SEGURIDADE PARTICIPAÇÕES S.A.
  BBM LOGÍSTICA S.A.
  BEMOBI MOBILE TECH S.A.
  BETAPART PARTICIPAÇÕES SA
  BICICLETAS MONARK SA
  BIOMM SA
  BIONEXO S.A.
  BLAU FARMACÊUTICA S.A.
  BLUE TECH SOLUTIONS EQI S.A.
  BLUEFIT ACADEMIAS DE GINÁSTICA E PARTICIPAÇÕES S.A
  BNDES PARTICIPAÇÕES S.A. - BNDESPAR
  BOA SAFRA SEMENTES S.A
  BOMBRIL SA
  BONAIRE PARTICIPAÇÕES S.A.- EM LIQUIDAÇÃO
  BORRACHAS VIPAL S.A.
  BR ADVISORY PARTNERS PARTICIPACOES S.A.
  BR MALLS PARTICIPAÇOES S.A.
  BRADESCO LEASING S.A. - ARRENDAMENTO MERCANTIL
  BRADESPAR S/A
  BRASIL BIOFUELS S.A.
  BRASIL TECNOLOGIA E PARTICIPAÇÕES S.A.
  BRASILAGRO CIA BRAS DE PROP AGRICOLAS
  BRASILIANA PARTICIPAÇÕES S.A.
  BRASKEM S.A.
  BRAVA ENERGIA S.A.
  BRAZIL TOWER, CESSÃO DE INFRA-ESTRUTURAS S.A
  BRAZILIAN SECURITIES CIA SECURITIZAÇÃO
  BRB BANCO DE BRASILIA SA
  BRF S.A.
  BRISANET SERVIÇOS DE TELECOMUNICAÇÕES S.A.
  BRK AMBIENTAL - REGIÃO METROPOLITANA DE MACEIÓ S.A.
  BRK AMBIENTAL PARTICIPAÇÕES S.A.
  BRQ SOLUÇÕES EM INFORMÁTICA S.A.
  BRZ EMPREENDIMENTOS E CONSTRUÇÕES S.A.
  BSB ENERGÉTICA S.A.
  C&A MODAS S.A.
  CABINDA PARTICIPAÇÕES SA
  CACHOEIRA PAULISTA TRANSMISSORA DE ENERGIA SA
  CACONDE PARTICIPAÇÕES SA
  CAIANDA PARTICIPAÇÕES SA
  CAIXA ADM DIV PUB ESTADUAL SA
  CAIXA SEGURIDADE PARTICIPAÇÕES S.A.
  CAMBUCI SA
  CAMIL ALIMENTOS S/A
  CANTU STORE S.A.
  CAPITALPART PARTICIPAÇÕES SA
  CARAMURU ALIMENTOS S.A.
  CARBOMIL SA MINER. E INDUSTRIA
  CBO HOLDING S.A.
  CCR S.A.
  CEL PARTICIPAÇÕES S.A. - CELPAR
  CELEO REDES TRANSMISSÃO DE ENERGIA S.A.
  CEMEPE INVESTIMENTOS SA
  CEMIG DISTRIBUIÇÃO S/A
  CEMIG GERAÇÃO E TRANSMISSÃO S/A
  CENCOSUD BRASIL COMERCIAL S.A.
  CENTRAIS ELETRICAS BRASILEIRAS SA
  CENTRAIS ELETRICAS DE SANTA CATARINA S.A
  CENTRAIS ELÉTRICAS DO NORTE DO BRASIL S.A.
  CERRADINHO BIOENERGIA S.A.
  CESP - COMPANHIA ENERGÉTICA DE SÃO PAULO
  CHINA THREE GORGES BRASIL ENERGIA S.A.
  CIA CAT. DE ÁGUAS E SANEAMENTO - CASAN
  CIA DE ELETRICIDADE DO ESTADO DA BAHIA - COELBA
  CIA DE GER. E TRANS. DE ENERGIA ELÉTRICA DO SUL DO BRASIL
  CIA DE PARTICIPAÇÕES ALIANÇA DA BAHIA
  CIA ENERG CEARA - COELCE
  CIA ENERG MINAS GERAIS - CEMIG
  CIA ENERGÉTICA DE PERNAMBUCO - CELPE
  CIA ENERGÉTICA DO RIO GRANDE DO NORTE
  CIA ESTADUAL DE ÁGUAS E ESGOTOS - CEDAE
  CIA ESTADUAL DE DISTRIBUIÇÃO DE ENERGIA ELETRICA
  CIA FERRO LIGAS BAHIA FERBASA
  CIA HIDRO ELÉTRICA DO SÃO FRANCISCO
  CIA INDUSTRIAL SCHLOSSER S.A.
  CIA PIRATININGA DE FORÇA E LUZ
  CIA RIOGRANDENSE DE SANEAMENTO
  CIA SANEAMENTO BÁSICO ESTADO SÃO PAULO
  CIA SECURITIZADORA DE CRED. FIN. CARTÕES CONSIGNADOS II
  CIA SIDERURGICA NACIONAL
  CIA TECIDOS SANTANENSE - EM RECUPERAÇÃO JUDICIAL
  CIA. DE SANEAMENTO DO PARANÁ - SANEPAR
  CIA. DISTRIB. DE GÁS DO RIO DE JANEIRO
  CICLUS AMBIENTAL RIO S.A.
  CIELO S.A. - INSTITUIÇÃO DE PAGAMENTO
  CIMS SA
  CLARO TELECOM PARTICIPAÇÕES S.A.
  CLEAR SALE S.A
  CLI SUL S.A.
  CM HOSPITALAR S.A
  COBRASMA SA
  COGNA EDUCAÇÃO S.A.
  COMERC ENERGIA S.A.
  COMPANHIA  MELHORAMENTOS DE SÃO PAULO
  COMPANHIA BRASILEIRA DE ALUMINIO
  COMPANHIA BRASILEIRA DE DISTRIBUIÇÃO
  COMPANHIA CELG DE PARTICIPAÇÕES - CELGPAR
  COMPANHIA DE ÁGUA E ESGOTO DO CEARÁ  - CAGECE
  COMPANHIA DE FIACAO E TECIDOS CEDRO E CACHOEIRA
  COMPANHIA DE GÁS DE MINAS GERAIS - GASMIG
  COMPANHIA DE GÁS DE SÃO PAULO - COMGÁS
  COMPANHIA DE LOCAÇÃO DAS AMERICAS
  COMPANHIA DE SANEAMENTO DE MINAS GERAIS
  COMPANHIA DO METROPOLITANO DE SÃO PAULO - METRÔ
  COMPANHIA ENERGÉTICA DE BRASÍLIA - CEB
  COMPANHIA ENERGÉTICA JAGUARA
  COMPANHIA ENERGÉTICA MIRANDA
  COMPANHIA ENERGÉTICA SINOP S.A.
  COMPANHIA ESTADUAL DE GERAÇÃO DE ENERGIA ELÉTRICA - CEEE-G
  COMPANHIA INDUSTRIAL CATAGUASES
  COMPANHIA ITAUNENSE ENERGIA E PARTICIPAÇÕES
  COMPANHIA PARANAENSE DE ENERGIA COPEL
  COMPANHIA PAULISTA DE FORCA LUZ - CPFL
  COMPANHIA SECURITIZADORA DE CRÉDITOS FINANCEIROS CARTÕES CONSIGNADOS I
  COMPANHIIA HABITASUL DE PARTICIPAÇÕES
  COMPASS GÁS E ENERGIA S.A.
  CONC RODOVIAS DO TIETÊ S.A.- EM RECUPERAÇÃO JUDICIAL
  CONC. DO AEROPORTO INTERNACIONAL DE GUARULHOS S.A.
  CONCEBRA - CONCESSIONARIA DAS RODOVIAS CENTRAIS DO BRASIL S.A.
  CONCESSÃO METROVIÁRIA DO RIO DE JANEIRO SA
  CONCESSIONARIA AUTO RAPOSO TAVARES SA-CART
  CONCESSIONARIA CATARINENSE DE RODOVIAS S.A.
  CONCESSIONÁRIA DA LINHA 4 DO METRÔ DE SÃO PAULO S.A.
  CONCESSIONÁRIA DA RODOVIA MG-050 S.A.
  CONCESSIONÁRIA DAS RODOVIAS AYRTON SENNA E CARVALHO PINTO S/A-ECOPISTAS
  CONCESSIONÁRIA DAS RODOVIAS INTEGRADAS DO SUL S.A.
  CONCESSIONÁRIA DE RODOVIA SUL-MATOGROSSENSE S.A.
  CONCESSIONARIA DE RODOVIAS DO INTERIOR PAULISTA S/A
  CONCESSIONÁRIA DE RODOVIAS NOROESTE PAULISTA S.A
  CONCESSIONÁRIA DO SISTEMA ANHANGUERA-BANDEIRANTES S.A.
  CONCESSIONÁRIA DO SISTEMA RODOVIÁRIO RIO-SÃO PAULO S.A.
  CONCESSIONARIA ECOVIAS DO ARAGUAIA S.A.
  CONCESSIONÁRIA ECOVIAS DO CERRADO S.A.
  CONCESSIONARIA ECOVIAS DOS IMIGRANTES SA
  CONCESSIONARIA PONTE RIO-NITERÓI S.A. - ECOPONTE
  CONCESSIONARIA RIO-TERESOPOLIS SA
  CONCESSIONÁRIA RODOVIAS DO CAFÉ SPE S.A.
  CONCESSIONÁRIA RODOVIAS DO SUL DE MINAS SPE S.A.
  CONCESSIONÁRIA RODOVIAS DO TRIÂNGULO SPE S.A.
  CONCESSIONÁRIA ROTA DAS BANDEIRAS S/A
  CONCESSIONARIA ROTA DE SANTA MARIA S.A
  CONCESSIONÁRIA ROTA DO OESTE S.A.
  CONCESSIONÁRIA VIARIO S.A.
  CONPEL CIA. NORDESTINA DE PAPEL - EM RECUPERAÇÃO JUDICIAL
  CONSERVAS ODERICH SA
  CONSTRUTORA ADOLPHO LINDENBERG S.A.
  CONSTRUTORA METROCASA S.A.
  CONSTRUTORA SULTEPA S.A. - EM RECUPERAÇÃO JUDICIAL
  CONSTRUTORA TENDA S/A
  COPEL DISTRIBUIÇÃO S.A.
  COPEL GERAÇÃO E TRANSMISSÃO S/A
  CORPÓREOS - SERVIÇOS TERAPÊUTICOS S.A.
  CORREDOR LOGÍSTICA E INFRAESTRUTURA S.A.
  COSAN S.A.
  CPFL ENERGIA SA
  CPFL ENERGIAS RENOVÁVEIS S.A.
  CPFL GERAÇÃO DE ENERGIA S/A
  CPFL TRANSMISSÃO S.A.
  CRUZEIRO DO SUL EDUCACIONAL S.A.
  CSN MINERAÇÃO S.A.
  CSU DIGITAL S.A.
  CTC - CENTRO DE TECNOLOGIA CANAVIEIRA S.A.
  CURY CONSTRUTORA E INCORPORADORA S.A.
  CVC BRASIL OPERADORA E AGÊNCIA DE VIAGENS SA
  CVLB BRASIL S.A.
  CYRELA BRAZIL REALTY S.A.EMPREEND E PART
  D1000 VAREJO FARMA PARTICIPAÇÕES S.A.
  DESKTOP S.A
  DEXCO S.A.
  DEXXOS PARTICIPAÇÕES S.A.
  DIAGNOSTICOS DA AMERICA SA
  DIBENS LEASING S.A.- ARREND. MERCANTIL
  DIMED SA DISTRIBUIDORA DE MEDICAMENTOS
  DINAMICA ENERGIA S/A
  DIRECIONAL ENGENHARIA SA
  DM FINANCEIRA S.A. - CRÉDITO, FINANCIAMENTO E INVESTIMENTO
  DOHLER S.A.
  DOTZ S.A.
  DTCOM - DIRECT TO COMPANY S.A.
  ECO050 - CONCESSIONÁRIA DE RODOVIAS S.A.
  ECO101 CONCESSIONÁRIA DE RODOVIAS S.A.
  ECORIOMINAS CONCESSIONÁRIA DE RODOVIAS S.A.
  ECORODOVIAS CONCESSÕES E SERVIÇOS S/A
  ECORODOVIAS INFRAESTRUTURA E LOGÍSTICA S.A.
  EDP ENERGIAS DO BRASIL S/A
  EDP ESPIRITO SANTO DISTRIBUIÇÃO DE ENERGIA S.A.
  EDP SÃO PAULO DISTRIBUIÇÃO DE ENERGIA S.A.
  EIXO SP CONCESSIONARIA DE RODOVIAS S.A.
  ELDORADO BRASIL CELULOSE S.A.
  ELEA DIGITAL INFRAESTRUTURA E REDES DE TELECOMUNICAÇÕES S.A.
  ELECTRO AÇO ALTONA S/A
  ELEKTRO REDES S.A.
  ELETROBRÁS PARTICIPAÇÕES S.A. - ELETROPAR
  ELETROMIDIA S.A.
  ELETROPAULO METROP. ELET. SAO PAULO S.A.
  ELETRORIVER S.A.
  ELFA MEDICAMENTOS S.A.
  EMAE - EMPRESA METROP.AGUAS ENERGIA S.A.
  EMBPAR PARTICIPAÇÕES S/A
  EMBRAER S.A.
  EMCCAMP RESIDENCIAL S.A.
  EMPREENDIMENTOS PAGUE MENOS SA
  ENAUTA PARTICIPAÇÕES S.A.
  ENERGISA MATO GROSSO DO SUL - DIST DE ENERGIA S.A.
  ENERGISA MATO GROSSO-DISTRIBUIDORA DE ENERGIA S/A
  ENERGISA MINAS RIO - DISTRIBUIDORA DE ENERGIA S/A
  ENERGISA PARAÍBA - DISTRIBUIDORA DE ENERGIA S/A
  ENERGISA SA
  ENERGISA SERGIPE - DISTRIBUIDORA DE ENERGIA S/A
  ENERGISA SUL-SUDESTE - DISTRIBUIDORA DE ENERGIA S.A.
  ENERGISA TRANSMISSÃO DE ENERGIA S.A.
  ENEVA S.A.
  ENGELHART CTP (BRASIL) S.A.
  ENGIE BRASIL ENERGIA S.A.
  ENJOEI S.A.
  ENTREVIAS CONCESSIONÁRIA DE RODOVIAS S.A.
  ENVIRONMENTAL ESG PARTICIPAÇÕES S.A.
  EPR INFRAESTRUTURA PR S.A.
  EPR LITORAL PIONEIRO S.A.
  EQUATORIAL GOIAS DISTRIBUIDORA DE ENERGIA S.A.
  EQUATORIAL MARANHÃO DISTRIBUIDORA DE ENERGIA S.A.
  EQUATORIAL PARÁ DISTRIBUIDORA DE ENERGIA S.A.
  EQUATORIAL S.A.
  EQUATORIAL TRANSMISSORA 7 SPE S.A.
  EQUATORIAL TRANSMISSORA 8 SPE S.A.
  EQUIPAV SANEAMENTO S.A.
  ESSENTIA PCHS S.A.
  ETERNIT S.A.
  EUCATEX S.A. INDUSTRIA E COMERCIO
  EUROFARMA LABORATÓRIOS S.A.
  EVEN CONSTRUTORA E INCORPORADORA S/A
  EXCELSIOR ALIMENTOS SA.
  EZ INC INCORPORAÇÕES COMERCIAIS S.A.
  EZ TEC EMPREEND. E PARTICIPAÇÕES S/A
  FARMÁCIA E DROGARIA NISSEI S.A.
  FERREIRA GOMES ENERGIA S.A.
  FERROVIA CENTRO-ATLANTICA S.A.
  FERROVIA NORTE SUL S/A
  FERTILIZANTES HERINGER S.A.
  FIACAO E TECELAGEM SAO JOSE S/A - EM RECUPERAÇÃO JUDICIAL
  FICA EMPREENDIMENTOS IMOBILIARIOS S.A.
  FISIA COMÉRCIO DE PRODUTOS ESPORTIVOS S.A.
  FLEURY SA
  FORPART S.A. - EM LIQUIDAÇÃO
  FOZ DO RIO CLARO ENERGIA S.A.
  FRAS-LE SA
  FTL - FERROVIA TRANSNORDESTINA LOGÍSTICA S.A.
  GAFISA SA
  GAMA PARTICIPAÇÕES S.A.
  GENERAL SHOPPING E OUTLETS DO BRASIL BRASIL S.A.
  GERDAU S.A.
  GIGA MAIS FIBRA TELECOMUNICAÇÕES S.A.
  GOL LINHAS AEREAS INTELIGENTES SA
  GPS PARTICIPAÇÕES E EMPREENDIMENTOS S/A
  GRANBIO INVESTIMENTOS S.A.
  GRANJA FARIA S.A.
  GRAZZIOTIN SA
  GRENDENE SA
  GRUPO CASAS BAHIA S.A.
  GRUPO FARTURA DE HORTIFRUT S.A.
  GRUPO MATEUS S.A.
  GRUPO MULTI S.A.
  GRUPO SBF S.A.
  GSH CORP PARTICIPAÇÕES S.A.
  GUARARAPES CONFECÇÕES SA
  HAGA S.A. INDÚSTRIA E COMÉRCIO
  HAPVIDA PARTICIPAÇÕES E INVESTIMENTOS S.A.
  HAUSCENTER SA
  HBR REALTY EMPREENDIMENTOS IMOBILIÁRIOS S.A.
  HELBOR EMPREENDIMENTOS S/A
  HÉLIO VALGAS SOLAR PARTICIPAÇÕES S.A.
  HERCULES S/A - FABRICA DE TALHERES
  HIDROVIAS DO BRASIL S.A.
  HMOBI PARTICIPAÇÕES S.A
  HOLDING DO ARAGUAIA S.A.
  HOSPITAL ANCHIETA S.A.
  HOSPITAL CARE CALEDONIA S.A.
  HOSPITAL MATER DEI S.A.
  HOTEIS OTHON S.A. - EM RECUPERAÇÃO JUDICIAL
  HUMBERG AGRIBRASIL COMÉRCIO E EXPORTAÇÃO DE GRÃOS S.A
  HYPERA S/A
  IFIN PARTICIPACOES S.A.
  IGUÁ RIO DE JANEIRO S.A.
  IGUA SANEAMENTO S.A.
  IGUATEMI EMPRESA DE SHOPPING CENTERS S/A
  IGUATEMI S.A.
  INBRANDS SA
  INC EMPREENDIMENTOS IMOBILIÁRIOS S.A.
  INEPAR EQUIPAMENTOS E MONTAGENS S/A - EM RECUPERACAO JUDICIA
  INEPAR S.A. INDUSTRIA E CONSTRUCOES EM RECUPERACAO JUDICIAL
  INFRACOMMERCE CXAAS S.A.
  INFRASEC SECURITIZADORA S/A
  INSPIRALI EDUCAÇÃO S.A.
  INTELBRAS S.A. IND. DE TELECOMUNICAÇÃO ELETRÔNICA BRASILEIRA
  INTERCEMENT BRASIL SA
  INTERNATIONAL MEAL COMPANY ALIMENTAÇÃO S.A.
  INVESTCO S/A
  INVESTIMENTOS BEMGE S.A.
  INVESTIMENTOS E PARTICIP EM INFRA SA INVEPAR
  IOCHPE MAXION SA
  IRANI PAPEL E EMBALAGEM S.A.
  IRB - BRASIL RESSEGUROS S.A.
  ISA ENERGIA BRASIL S.A.
  ITAPEBI GERAÇÃO DE ENERGIA S/A
  ITAÚ UNIBANCO HOLDING S.A.
  ITAUSA S.A.
  J. MACEDO S/A
  JALLES MACHADO S.A.
  JBS SA
  JHSF PARTICIPAÇÕES SA
  JOAO FORTES ENGENHARIA SA - EM RECUPERAÇÃO JUDICIAL
  JOSAPAR-JOAQUIM OLIVEIRA S.A. - PARTICIP
  JSL S.A.
  K-INFRA RODOVIA DO AÇO S.A.
  KALLAS INCORPORAÇÕES E CONSTRUÇÕES S.A.
  KALUNGA S.A.
  KARSTEN SA
  KEPLER WEBER SA
  KLABIN S.A.
  KORA SAÚDE PARTICIPAÇÕES S.A.
  LABORATÓRIO TEUTO BRASILEIRO S.A.
  LAVVI EMPREENDIMENTOS IMOBILIÁRIOS S.A
  LEADS CIA. SECURITIZADORA
  LET'S RENT A CAR S.A.
LIFEMED INDUSTRIAL DE EQUIP. E ART. MEDICOS E HOSP. S.A.
LIGGA TELECOMUNICAÇÕES S.A.
LIGHT ENERGIA S.A.
LIGHT S.A. - EM RECUPERAÇÃO JUDICIAL
LIGHT SERVIÇOS DE ELETRICIDADE SA
LINHA AMARELA S.A.- LAMSA
LINHAS DE MACAPÁ TRANSMISSORA DE ENERGIA S.A.
LINHAS DE XINGU TRANSMISSORA DE ENERGIA S.A.
LITEL PARTICIPACOES SA
LITELA PARTICIPAÇÕES S.A. - EM LIQUIDAÇÃO
LIVETECH DA BAHIA INDÚSTRIA E COMÉRCIO S.A.
LM TRANSPORTES INTERESTADUAIS SERVIÇOS E COMÉRCIO S.A.
LOCALIZA  FLEET S.A.
LOCALIZA RENT A CAR SA
LOG COMMERCIAL PROPERTIES E PARTICIPAÇÕES
LOG-IN LOGISTICA INTERMODAL SA
LOJAS QUERO QUERO S.A.
LOJAS RENNER SA
LONGDIS SA
LPS BRASIL CONSULTORIA DE IMOVEIS S/A
LUPATECH S.A.
LUPO S.A.
LWSA S/A
M. DIAS BRANCO SA IND E COM DE ALIMENTOS
MADERO INDÚSTRIA E COMÉRCIO S.A.
MAESTRO LOCADORA DE VEÍCULOS S.A.
MAGAZINE LUIZA SA
MAHLE METAL LEVE S.A.
MANAUS TRANSMISSORA DE ENERGIA S.A
MANGELS INDUSTRIAL S.A.
MANUFATURA DE  BRINQUEDOS ESTRELA SA
MARCOPOLO SA
MARFRIG GLOBAL FOODS SA
MARINA DE IRACEMA PARK SA
MARISA LOJAS SA
MASSA FALIDA DA SA IND E COMERCIO CHAPECO
MASSA FALIDA DE POMIFRUTAS S/A
MELIUZ S.A.
MELNICK DESENVOLVIMENTO IMOBILIÁRIO S.A.
MENDES JUNIOR ENGENHARIA SA
MERCANTIL FINANCEIRA S.A. CRÉDITO, FINANCIAMENTO E INVESTIMENTO
METALFRIO SOLUTIONS S/A
METALURGICA GERDAU SA
METALURGICA RIOSULENSE SA
METANOR SA METANOL DO NE
METISA METALÚRGICA  TIMBOENSE SA
MILLS LOCAÇÃO, SERVIÇOS E LOGÍSTICA S.A.
MINASMAQUINAS SA
MINERVA S/A
MINUPAR PARTICIPACOES SA
MITRE REALTY EMPREENDIMENTOS E PARTICIPAÇÕES S.A.
MLOG S.A.
MNLT S.A.
MOBLY S.A.
MONTE RODOVIAS S.A.
MONTEIRO ARANHA SA
MOTTU I S.A
MOURA DUBEUX ENGENHARIA S/A
MOVIDA LOCAÇÃO DE VEÍCULOS S.A
MOVIDA PARTICIPAÇÕES S.A.
MPM CORPÓREOS S.A.
MRS LOGÍSTICA S/A
MRV ENGENHARIA E PARTICIPAÇÕES S/A
MULTINER S/A
MULTIPLAN - EMPREEND IMOBILIARIOS S.A.
MUNDIAL S.A - PRODUTOS DE CONSUMO
NATURA & CO HOLDING S.A.
NATURA COSMETICOS SA
NEOENERGIA S.A
NEOGRID PARTICIPACÕES S.A.
NEWTEL PARTICIPAÇÕES S.A. - EM LIQUIDAÇÃO
NEXPE PARTICIPAÇÕES S.A. - EM RECUPERAÇÃO JUDICIAL
NORDON INDUSTRIAS METALURGICAS S.A.
NORTE BRASIL TRANSMISSORA DE ENERGIA S.A.
NORTE ENERGIA S.A
NORTEC QUIMICA S.A.
NOVA SOCIEDADE DE NAVEGAÇÃO S.A.
NOVA TRANSPORTADORA DO SUDESTE S.A. - NTS
NUTRIPLANT INDUSTRIA E COMÉRCIO S/A
OCEÂNICA ENGENHARIA E CONSULTORIA S.A.
OCEANPACT SERVIÇOS MARÍTIMOS S.A.
ODONTOPREV S/A
OI S.A. - EM RECUPERAÇÃO JUDICIAL
OLIVEIRA TRUST S.A.
ONCOCLÍNICAS DO BRASIL SERVIÇOS MÉDICOS S.A.
ORIGEM ENERGIA S.A.
ORIZON MEIO AMBIENTE S.A.
ORIZON VALORIZAÇÃO DE RESÍDUOS S.A.
OSX BRASIL S.A. - EM RECUPERAÇÃO JUDICIAL
OUROFINO S.A.
PACAEMBU CONSTRUTORA S.A.
PADTEC HOLDING S.A.
PANATLANTICA SA
PARANA BANCO S.A.
PARANAPANEMA S.A. - EM RECUPERAÇÃO JUDICIAL
PARCOM PARTICIPACOES SA EM LIQUIDACAO
PARSAN S.A.
PATRIMAR ENGENHARIA S.A.
PBG S/A
PDG COMPANHIA SECURITIZADORA
PDG REALTY S.A. EMPREEND E PARTICIPACOES
PET CENTER COMÉRCIO E PARTICIPAÇÕES S.A.
PETRO RIO JAGUAR PETRÓLEO S.A.
PETRÓLEO BRASILEIRO  S.A.  - PETROBRAS
PETROLEO LUB DO NORDESTE SA
PETRORECÔNCAVO S.A.
PETTENATI S.A. INDUSTRIA TEXTIL
PLANO & PLANO DESENVOLVIMENTO IMOBILIÁRIO S.A.
PLASCAR PARTICIPAÇÕES INDUSTRIAIS S.A
POLPAR S.A.
PORTO DE VITÓRIA COMPANHIA SECURITIZADORA DE CRÉDITOS FINANCEIROS S.A.
PORTO PONTA DO FELIX S/A
PORTO SAÚDE PARTICIPAÇÕES S.A.
PORTO SEGURO SA
PORTO SERVIÇO S.A
PORTO SUDESTE V.M. S.A.
PORTUENSE FERRAGENS S/A
POSITIVO TECNOLOGIA S.A.
PRÁTICA PRODUTOS S.A.
PRINER SERVIÇOS INDUSTRIAIS S.A.
PRIO FORTE S.A.
PRIO S.A.
PRODUTORES ENERGET.DE MANSO S.A.- PROMAN
PROFARMA DISTRIB PROD FARMACEUTICOS S.A.
PROLAGOS S/A - CONC.DE SERVICOS PÚBLICOS DE ÁGUA E ESGOTO
PROMPT PARTICIPAÇÕES S.A.
QESTRA TECNOLOGIA ADMINISTRAÇÃO E PARTICIPAÇÕES S.A.
QUALICORP CONSULTORIA E CORRETORA DE SEGUROS S.A.
QUALITY SOFTWARE S.A.
RAIA DROGASIL S.A.
RAÍZEN ENERGIA S.A.
RAÍZEN S.A.
RANDON S.A. IMPLEMENTOS E PARTICIPAÇÕES
RDVC CITY S.A.
REAG ASSET MANAGEMENT PART S.A.
REAG CAPITAL HOLDING S.A.
REAG INVESTIMENTOS S.A.
REAG TRUST S.A
REAG WEALTH MANAGEMENT S.A.
RECRUSUL SA
REDE D'OR SÃO LUIZ S.A.
  REDE ENERGIA PARTICIPAÇÕES S.A.
  REFINARIA PET MANGUINHOS SA
  RENOVA ENERGIA S.A. -  EM RECUPERAÇÃO JUDICIAL
  REVEE S.A.
  RGE SUL DISTRIBUIDORA DE ENERGIA S.A.
  RIO ALTO ENERGIAS RENOVÁVEIS S.A.
  RIO ALTO STL HOLDING I S.A.
  RIO PARANA ENERGIA S.A.
  RIO PARANAPANEMA ENERGIA SA
  RIO+ SANEAMENTO BL 3 S.A.
  RNI NEGÓCIOS IMOBILIÁRIOS S.A.
  RODOBENS S.A.
  RODOVIAS DAS COLINAS S.A.
  RODOVIAS DO BRASIL HOLDING S.A.
  ROMI S.A.
  ROSSI RESIDENCIAL S.A. - EM RECUPERAÇÃO JUDICIAL
  RUMO MALHA CENTRAL S.A.
  RUMO MALHA NORTE S.A.
  RUMO MALHA OESTE S.A.
  RUMO MALHA PAULISTA S.A.
  RUMO MALHA SUL S.A.
  RUMO S.A.
  SAFIRA HOLDING S.A.
  SALUS INFRAESTRUTURA PORTUÁRIA S.A.
  SANEAMENTO DE GOIAS SA
  SANESALTO SANEAMENTO SA
  SANSUY SA INDÚSTRIA  DE PLASTICOS
  SANTA CATARINA PART INVEST SA
  SANTO ANTONIO ENERGIA S.A.
  SANTOS BRASIL PARTICIPAÇÕES S.A.
  SAO CARLOS EMPREEND E PARTICIPACOES S.A.
  SÃO MARTINHO SA
  SÃO PAULO TURISMO S.A.
  SARAIVA LIVREIROS S.A. - FALIDA
  SBF COMÉRCIO DE PRODUTOS ESPORTIVOS S.A.
  SCHULZ SA
  SECME - COMPANHIA SECURITIZADORA DE CRÉDITOS IMOBILIÁRIOS
  SEIVA S.A. - FLORESTAS E INDÚSTRIAS
  SENDAS DISTRIBUIDORA S.A.
  SENIOR SISTEMAS S.A.
  SEQUOIA LOGÍSTICA E TRANSPORTES S.A.
  SER EDUCACIONAL S.A.
  SERENA ENERGIA S.A.
  SERENA GERAÇÃO S.A.
  SIDERURGICA J L ALIPERTI SA
  SIMPAR S.A.
  SLC AGRICOLA SA
  SMARTFIT ESCOLA DE GINÁSTICA E DANÇA S.A.
  SNB PARTICIPACOES SA
  SOCIEDADE ABASTECIMENTO DE AGUA E SANEAMENTO SA
  SOLAR BEBIDAS S.A.
  SOLVI ESSENCIS AMBIENTAL S.A.
  SONDOTECNICA ENGENHARIA SOLOS S.A.
  SUDESTE SA
  SUGOI S.A.
  SUL 116 PARTICIPAÇÕES S.A.
  SUZANO HOLDING S.A.
  SUZANO S.A.
  SYN PROP & TECH S.A.
  T4F ENTRETENIMENTO SA
  TAURUS ARMAS S.A.
  TC S.A.
  TCP - TERMINAL DE CONTÊINERES DE PARANAGUÁ S.A.
  TECBLU - TECELAGEM BLUMENAU S/A.
  TECHNOS SA
  TECIDOS E ARMARINHOS MIGUEL BARTOLOMEU S.A.
  TECNISA S/A
  TECNOSOLO ENGENHARIA SA EMPRESA FALIDA
  TEGMA GESTÃO LOGÍSTICA SA
  TEGRA INCORPORADORA S.A.
  TEKA TECELAGEM KUEHNRICH SA - EM RECUPERAÇÃO JUDICIAL
  TEKNO S.A. INDÚSTRIA E COMÉRCIO
  TELEC. BRASILEIRAS S.A. - TELEBRÁS
  TELEFÔNICA BRASIL S.A.
  TERMELÉTRICA PERNAMBUCO III S.A.
  TERMINAL GARAGEM MENEZES CORTES SA
  TERMOPERNAMBUCO SA
  TERRA SANTA PROPRIEDADES AGRÍCOLAS S.A.
  TÊXTIL RENAUXVIEW S/A
  TIGRE S.A. PARTICIPAÇÕES
  TIM BRASIL SERVIÇOS E PARTICIPAÇÕES S.A.
  TIM S.A.
  TOTVS S.A
  TPI - TRIUNFO PARTICIPACOES E INVESTIMENTOS S.A.
  TRACK & FIELD CO S.A
  TRANSBRASILIANA CONCESSIONÁRIA DE RODOVIA SA
  TRANSMISSORA ALIANÇA DE ENERGIA ELÉTRICA S.A.
  TRANSNORDESTINA LOGISTICA SA
  TRAVESSIA SECURITIZADORA DE CRÉDITOS FINANCEIROS S.A.
  TRAVESSIA SECURITIZADORA DE CRÉDITOS MERCANTIS VI S.A.
  TRAVESSIA SECURITIZADORA S.A.
  TRÊS TENTOS AGROINDUSTRIAL S.A.
  TREVISA  INVESTIMENTOS SA
  TRIPLE PLAY BRASIL PARTICIPAÇÕES S.A.
  TRISUL S/A
  TRONOX PIGMENTOS DO BRASIL S.A.
  TUPY SA
  TURBI COMPARTILHAMENTO DE VEÍCULOS S.A.
  ULTRAPAR PARTICIPAÇÕES SA
  UNIÃO QUÍMICA FARMACÊUTICA NACIONAL S.A.
  UNICASA INDÚSTRIA DE MÓVEIS S.A.
  UNIDAS LOCAÇÕES E SERVIÇOS S.A.
  UNIDAS LOCADORA S.A.
  UNIFIQUE TELECOMUNICAÇÕES S.A.
  UNIGEL PARTICIPAÇÕES S.A.
  UNIPAR CARBOCLORO S.A.
  UPTICK PARTICIPACOES S.A. - EM LIQUIDAÇÃO
  URBA DESENVOLVIMENTO URBANO S.A.
  USINA TERMELÉTRICA PAMPA SUL S.A.
  USINAS SID DE MINAS GERAIS S.A.-USIMINAS
  V. TAL - REDE NEUTRA DE TELECOMUNICAÇÕES S.A.
  VALE S.A.
  VALID SOLUÇÕES S.A.
  VAMOS LOCAÇÃO DE CAMINHÕES, MÁQUINAS E EQUIPAMENTOS S.A.
  VENTOS DO SUL ENERGIA S.A.
  VERO S.A.
  VESTE SA ESTILO
  VIA BRASIL BR 163 CONCESSIONARIA DE RODOVIAS S.A.
  VIABAHIA CONCESSIONÁRIA DE RODOVIAS SA
  VIAPAULISTA S.A.
  VIARONDON CONCESSIONÁRIA DE RODOVIA SA
  VIBRA ENERGIA S/A
  VITAL ENGENHARIA AMBIENTAL S.A.
  VITRU BRASIL EMPREENDIMENTOS, PARTICIPAÇÕES E COMÉRCIO S.A.
  VITTIA S.A.
  VIVARA PARTICIPAÇÕES S.A.
  VIVER INCORPORADORA E CONSTRUTORA S.A
  VIX LOGÍSTICA S/A
  VOTORANTIM CIMENTOS S.A.
  VRENTAL LOCAÇÃO DE MÁQUINAS E EQUIPAMENTOS S.A.
  VULCABRAS S.A.
  W2W E-COMMERCE DE VINHOS S.A.
  WEG SA
  WESTWING COMÉRCIO VAREJISTA S.A.
  WETZEL S.A.
  WHIRLPOOL S.A
  WILSON SONS S.A.
  WIZ CO PARTICIPAÇÕES E CORRETAGEM DE SEGUROS S.A.
  WLM PART. E COMÉRCIO DE MÁQUINAS E VEÍCULOS S.A.
  WTC AMAZONAS SUITE HOTEL S.A.
  WTC RIO EMPREEND. E PARTICIPAÇÕES S.A.
  XP INVESTIMENTOS S/A
  XX DE NOVEMBRO INVESTIMENTOS E PARTICIPAÇÕES S.A
  YBYRA CAPITAL S.A
  YDUQS PARTICIPACOES S.A.
  YOU INC INCORPORADORA E PARTICIPAÇÃO S.A
  YUNY INCORPORADORA HOLDING S.A.
  ZAMP S.A.
  
  
)

for (nomes in names(lista_nomes)) {
  correto <- lista_nomes[[nomes]]
  empresas$EMPRESA <- gsub(nomes, correto, empresas$EMPRESA, ignore.case = TRUE)
}

# 3. Remover caracteres especiais e espaços extras
# nome$NOME_PADRONIZADO <- gsub("[^A-Za-z0-9 ]", "", nome$NOME_PADRONIZADO)
nome$NOME_PADRONIZADO <- trimws(nome$NOME_PADRONIZADO)

write.csv(empresas, "./data/nome.csv", row.names = FALSE, fileEncoding = "UTF-8")

# BP ----

# DRE ----

# DFC_MD ----

# DFC_MI ----

# DVA ----

# Dados ----

# Carregando arquivos do BP

# definir os diretórios onde estão os arquivos CSV
dir_dados <- file.path("./data/cvm/raw/csv/dados")
# obter a lista de nomes de arquivos em cada diretório
arquivos_dados <- list.files(dir_dados, pattern = "\\.csv$")
# inicializar listas para armazenar os data frames
lista_dados <- list()
# loop através dos arquivos em cada diretório e ler cada um com read.csv
for (arquivo in arquivos_dados) {
  caminho_arquivo <- file.path(dir_dados, arquivo)
  df <- read.csv(caminho_arquivo, sep = ";", fileEncoding = "ISO-8859-1", stringsAsFactors = FALSE)
  lista_dados[[arquivo]] <- df
}
# combinar todos os data frames em um único data frame
dados <- do.call(rbind, lista_dados)

unique(dados$CNPJ_CIA)
unique(dados$DT_REFER) 

# Filtrar as datas que não contém os padrões indesejados
filtro <- !grepl("-03-31|-06-30|-09-30|-12-31", dados$DT_REFER)
dados_filtrados <- dados[filtro, ]

# Exibir os dados filtrados
print(dados_filtrados$DENOM_CIA)

## divindo os periodos por trimestre e ano (CAMIL a classificação será diferente. 1t termina em maio, 2t = ago, 3t = nov, 4t = fev)

# Criando colunas Trimestre e Ano
dados$TRIMESTRE <- ifelse(floor(as.numeric(substr(dados$DT_REFER, 6, 7)) / 3) < 1,
                          paste0('4T',as.numeric(substr(dados$DT_REFER, 3, 4)) - 1),
  
  paste0(floor(as.numeric(substr(dados$DT_REFER, 6, 7)) / 3), 'T', 
                       as.numeric(substr(dados$DT_REFER, 3, 4))))
dados$ANO <- ifelse(floor(as.numeric(substr(dados$DT_REFER, 6, 7)) / 3) < 1,
                    as.numeric(substr(dados$DT_REFER, 1, 4)) - 1,
                    as.numeric(substr(dados$DT_REFER, 1, 4)))

# Filtrando a versão mais atual dos dados
dados <-
  dados %>%
  group_by(DT_REFER, CNPJ_CIA) %>%
  filter(VERSAO == max(VERSAO)) %>%
  ungroup()

# criando df final de dados
dados <-
  dados %>%
  select(CNPJ_CIA, TRIMESTRE, ANO, VERSAO, ID_DOC, LINK_DOC)
