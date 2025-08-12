# Laboratório de Visualização de Dados com Grafana e TimescaleDB

Este repositório contém um ambiente completo para laboratório de visualização de dados usando Grafana, TimescaleDB (PostgreSQL) e um injetor de dados simulados. O objetivo é permitir a exploração e análise de dados de vendas através de dashboards interativos.

## 🏗️ Arquitetura do Sistema

O projeto é composto por três componentes principais executados em contêineres Docker:

```
┌─────────────────┐    ┌──────────────────┐    ┌────────────────────┐
│   Data Injetor  │───▶│  TimescaleDB     │◀───│     Grafana        │
│                 │    │  (PostgreSQL)    │    │                    │
│ Gera dados de   │    │                  │    │ Visualização e     │
│ vendas simulados│    │ Armazena dados   │    │ dashboards         │
│ em tempo real   │    │ de vendas        │    │                    │
└─────────────────┘    └──────────────────┘    └────────────────────┘
```

### Componentes:

1. **TimescaleDB (PostgreSQL)**: Banco de dados que armazena os dados de vendas em uma tabela chamada `vendas`
2. **Data Injetor**: Serviço em Python que gera dados simulados de vendas e os insere no banco de dados
3. **Grafana**: Plataforma de visualização de dados que se conecta ao banco de dados para criar dashboards

## 📊 Estrutura da Tabela de Vendas

O banco de dados contém uma única tabela chamada `vendas` com a seguinte estrutura:

- `id` (SERIAL): Identificador único para cada venda
- `produto` (VARCHAR(100)): Nome do produto vendido
- `categoria` (VARCHAR(50)): Categoria do produto (Eletrônicos, Livros ou Casa)
- `preco_unitario` (INTEGER): Preço unitário em centavos (dividir por 100 para obter valor em Reais)
- `quantidade` (INTEGER): Quantidade de unidades vendidas
- `data_venda` (TIMESTAMP): Data e hora da venda

## ▶️ Como Executar

### Pré-requisitos

- Docker e Docker Compose instalados

### Comandos Disponíveis

O projeto inclui um Makefile com comandos convenientes:

```bash
# Iniciar todos os serviços
make up

# Parar todos os serviços
make down

# Parar serviços e remover volumes (limpar dados)
make reset

# Visualizar logs dos serviços
make logs

# Verificar status dos contêineres
make ps
```

Alternativamente, você pode usar os comandos do Docker Compose diretamente:

```bash
# Iniciar serviços em modo detached
docker-compose up -d

# Parar serviços
docker-compose down

# Parar serviços e remover volumes persistentes
docker-compose down --volumes
```

## 🔧 Acesso ao Grafana

Após iniciar os serviços, o Grafana estará disponível em:

- **URL**: http://localhost:3000
- **Usuário**: admin
- **Senha**: strongpassword

O datasource do PostgreSQL já está configurado e pronto para uso.

## 📈 Importar o Dashboard

O repositório inclui um dashboard pré-configurado com visualizações de análise de vendas:

1. Acesse o Grafana em http://localhost:3000
2. No menu lateral, clique em "Dashboards" (+) → "Import"
3. Faça upload do arquivo `assets/New dashboard-1754971344100.json` OU copie seu conteúdo e cole na caixa de texto
4. Se solicitado, selecione o datasource "PostgreSQL-PROD"
5. Clique em "Import"

O dashboard inclui três painéis:
- **KPI - Ticket Médio**: Valor médio por transação
- **Análise de Receita**: Receita ao longo do tempo
- **Desempenho Relativo das Categorias**: Comparação de receita por categoria

## 🛠️ Funcionamento do Data Injetor

O serviço de data injetor gera continuamente dados simulados de vendas:

- Gera uma nova venda a cada 0.5 segundos
- Seleciona aleatoriamente um produto de uma das categorias: Eletrônicos, Livros ou Casa
- Define um preço aleatório entre R$50,00 e R$2.500,00
- Define uma quantidade aleatória entre 1 e 5 unidades
- Insere os dados diretamente no banco TimescaleDB

## 📁 Estrutura do Projeto

```
grafana-lab-data-viz-ufcg/
├── docker-compose.yml          # Configuração dos serviços Docker
├── Makefile                    # Comandos convenientes
├── assets/
│   └── New dashboard-*.json    # Dashboard pré-configurado
├── data-injector/              # Serviço de geração de dados
│   ├── data-injector.py
│   ├── Dockerfile
│   └── requirements.txt
├── grafana-provisioning/       # Configuração do Grafana
│   └── datasources/
│       └── datasource.yml      # Configuração do datasource PostgreSQL
└── postgres-data/
    └── init.sql                # Script de inicialização do banco de dados
```

## 📚 Recursos Adicionais

Consulte o arquivo [ANALISE_DE_VENDAS.md](ANALISE_DE_VENDAS.md) para:
- Detalhes sobre a estrutura do banco de dados
- Exemplos de queries SQL para análise de dados
- 10 questões para análise com sugestões de visualizações
- Boas práticas para trabalhar com dados monetários

## 🧪 Resolução de Problemas

Se o dashboard não mostrar dados:
1. Verifique se todos os serviços estão rodando: `make ps`
2. Confirme que o data injetor está inserindo dados: `make logs`
3. Verifique a conexão com o banco de dados nas configurações do datasource do Grafana

Para reiniciar todo o ambiente e começar com dados limpos:
```bash
make reset
make up
```