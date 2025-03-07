# PLANEJAMENTO

## **1. Planejamento e Estruturação (1ª - 2ª semana)**

### **Objetivos:**

1. Definir **objetivos claros** e o **escopo do projeto**.
2. Estabelecer a **estrutura** e o **layout do dashboard**.
3. Planejar e decidir sobre o **armazenamento e gerenciamento de dados**.

---

### **Tarefas Detalhadas:**

1. **Reunir e organizar os scripts existentes:**
   - Consolidar todos os arquivos `.R` e outros relacionados ao projeto (e.g., `00.library.R`, `09.shiny_data.R`). ok
   - Verificar consistência e organização (nomes de variáveis, comentários). ok

2. **Identificar os principais indicadores a serem exibidos:**
   - Liste os **KPIs mais relevantes** (e.g., total exportado, número de municípios exportadores). ok
   - Classifique-os por prioridade e página do dashboard.
   - Valide se há dados suficientes para esses indicadores. ok

3. **Pesquisar soluções de armazenamento:**
   - Compare opções como **SQL**, **AWS S3** e **Docker** com base em:
     - Escalabilidade.
     - Custo.
     - Facilidade de integração com R/Shiny.
   - Documente os **prós e contras** de cada solução. ok

4. **Criar o repositório do projeto:**
   - Configure um **repositório Git** no GitHub ou GitLab.
   - Adicione um arquivo `.gitignore` para excluir dados sensíveis ou grandes (e.g., `.zip` de dados).
   - Configure uma estrutura inicial de pastas:
     ```
     .
     |--Cronograma e Planejamento
     |--data                     # Dados brutos e processados
     |--|--
     |--R                        # Scripts R
     |--|--00.library.R          
     |--|--cvm
     |--|--|--extract
     |--|--|--|--01.extract_files.R  # Funções para extração dos arquivos   
     |--|--|--transform
     |--|--|--|--02.data.analisys.R
     |--|--|--|--03.transform.files.R
     |--|--|--load
     |--|--|--|--db_operations.R      
     |www          # Arquivos estáticos (imagens, CSS, etc.)
     |modules      # Módulos de UI e Server
     README.R
     .
      |-- .gitignore                # Arquivo para ignorar dados sensíveis ou gerados automaticamente
      |-- README.md                 # Documentação do projeto
      |-- docs/                     # Documentação adicional (cronogramas, relatórios, diagramas, etc.)
      |   |-- Cronograma.pdf        # Exemplo de cronograma
      |-- data/                     # Dados do projeto
      |   |-- raw/                  # Dados brutos (originais, não tratados)
      |   |-- processed/            # Dados tratados/pré-processados
      |   |-- samples/              # Amostras ou dados de teste
      |-- scripts/                  # Scripts gerais e utilitários
      |   |-- setup/                # Configuração inicial e bibliotecas
      |   |   |-- 00.library.R      # Scripts para carregamento de bibliotecas
      |   |-- cvm/                  # Scripts relacionados aos dados da CVM
      |   |   |-- extract/          # Extração de dados
      |   |   |   |-- 01.extract_files.R
      |   |   |-- transform/        # Transformação e análise
      |   |   |   |-- 02.data.analysis.R
      |   |   |   |-- 03.transform.files.R
      |   |   |-- load/             # Carregamento no banco de dados
      |   |   |   |-- db_operations.R
      |-- shiny/                    # Arquivos específicos do Shiny App
      |   |-- modules/              # Módulos de UI e Server
      |   |-- www/                  # Arquivos estáticos (CSS, imagens, etc.)
      |-- docker/                   # Arquivos de configuração Docker
      |   |-- Dockerfile            # Configuração do contêiner
      |   |-- docker-compose.yml    # Configuração para múltiplos serviços
     ```

5. **Elaborar um mockup do layout:**
   - Use ferramentas como **Figma** ou **Adobe XD**.
   - Baseie-se no design do **AdminLTE** para:
     - Cabeçalho e rodapé.
     - Distribuição de gráficos e indicadores.
   - Valide o design com as necessidades dos usuários.

---

**Entrega esperada ao final da etapa:**
- Repositório Git configurado e organizado.
- Mockup do dashboard pronto para validação.
- Relatório sobre as soluções de armazenamento avaliadas.