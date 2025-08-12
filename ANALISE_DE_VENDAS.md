# Análise de Vendas com Grafana e TimescaleDB

Este documento serve como um guia para explorar e visualizar dados de vendas utilizando um banco de dados PostgreSQL com a extensão TimescaleDB e a plataforma de visualização Grafana.

## 1. O Banco de Dados: Tabela `vendas`

Nosso banco de dados contém uma única tabela chamada `vendas`, projetada para armazenar informações sobre transações de produtos. Cada linha representa uma venda individual.

### Estrutura da Tabela (Schema)

- **`id` (SERIAL):** Identificador único para cada venda (Chave Primária).
- **`produto` (VARCHAR(100)):** Nome do produto vendido.
- **`categoria` (VARCHAR(50)):** Categoria à qual o produto pertence.
- **`preco_unitario` (INTEGER):** Preço de uma única unidade do produto, **armazenado em centavos**.
- **`quantidade` (INTEGER):** Número de unidades vendidas na transação.
- **`data_venda` (TIMESTAMP):** Data e hora exatas da venda.

> **Nota sobre Preços em Centavos:**
> Armazenar valores monetários como inteiros (centavos) é uma prática recomendada em desenvolvimento de software. Isso elimina completamente os erros de arredondamento e precisão que podem ocorrer com tipos de dados de ponto flutuante (`NUMERIC` ou `FLOAT`). Ao fazer queries, sempre dividimos o valor por `100.0` para convertê-lo de volta para a unidade principal da moeda (Reais, Dólares, etc.) antes de exibi-lo.

---

## 2. O que é o Grafana?

**Grafana** é uma plataforma de código aberto para visualização e análise de dados. Ele permite que você crie dashboards interativos a partir de diversas fontes de dados, transformando dados brutos em gráficos elegantes que facilitam a identificação de tendências, padrões e anomalias.

### Como Montar Queries e Visualizações: Exemplos Práticos

O processo consiste em escrever uma query para buscar os dados e, em seguida, escolher e refinar uma visualização para apresentar esses dados de forma eficaz.

---

**Exemplo 1: Análise de Receita Dinâmica e Responsiva (Visualização: *Time Series*)**

O gráfico mais fundamental para análise de tendências. Vamos criar um gráfico de receita que se adapta automaticamente ao período de tempo selecionado.

1.  **A Query SQL:**
    ```sql
    SELECT
      time_bucket('$__interval', data_venda) AS time,
      SUM((preco_unitario / 100.0) * quantidade) AS "Receita"
    FROM
      vendas
    WHERE
      $__timeFilter(data_venda)
    GROUP BY
      time
    ORDER BY
      time;
    ```
    - **Por que essa query funciona?**
        - `(preco_unitario / 100.0)`: Convertemos o preço de centavos para Reais antes de qualquer cálculo.
        - `'$__interval'`: Garante que o agrupamento de tempo seja dinâmico e se ajuste ao zoom do dashboard, evitando erros.

2.  **Refinando a Visualização no Grafana:**
    - **Tipo de Gráfico:** `Time series`.
    - **Eixo Y:** Em "Axes", no campo "Unit", selecione a unidade de moeda apropriada (ex: `currency/BRL (R$)`).

---

**Exemplo 2: Desempenho Relativo das Categorias (Visualização: *Bar Chart*)**

Para comparar a receita total de cada categoria de produto. 

1.  **A Query SQL:**
    ```sql
    SELECT
      categoria,
      SUM((preco_unitario / 100.0) * quantidade) AS "total_receita"
    FROM
      vendas
    WHERE
      $__timeFilter(data_venda)
    GROUP BY
      categoria
    ORDER BY
      "total_receita" DESC;
    ```

2.  **Refinando a Visualização no Grafana:**
    - **Tipo de Gráfico:** `Bar chart`.
    - **Orientação:** `Horizontal` é ótimo para nomes de categoria longos.
    - **Eixo X:** Formate o eixo de valor como moeda.

---

**Exemplo 3: Monitorando um KPI - Ticket Médio (Visualização: *Stat*)**

Para exibir um indicador de performance chave (KPI) como o valor médio por transação.

1.  **A Query SQL:**
    ```sql
    SELECT
      AVG((preco_unitario / 100.0) * quantidade) AS "Ticket Médio"
    FROM
      vendas
    WHERE
      $__timeFilter(data_venda);
    ```

2.  **Refinando a Visualização no Grafana:**
    - **Tipo de Gráfico:** `Stat`.
    - **Formatação:** Configure a "Unit" para moeda e defina limiares de cores (`Thresholds`) para um feedback visual rápido (ex: vermelho para baixo, verde para alto).

---

## 3. Desafios: 10 Questões para Análise

**Lembrete:** Em todas as queries, você precisará dividir `preco_unitario` por `100.0`!

**Questão 1:** Qual foi a receita total de vendas (soma de `(preco_unitario / 100.0) * quantidade`) mês a mês no último ano?
*   **Dica de Visualização:** `Time series`. Use `time_bucket` com intervalo de `'1 month'`.

**Questão 2:** Qual categoria de produto gera mais receita?
*   **Dica de Visualização:** `Bar chart`.

**Questão 3:** Quais são os 5 produtos mais vendidos em termos de quantidade?
*   **Dica de Visualização:** `Bar chart`. (Não precisa dividir por 100, pois é sobre quantidade).

**Questão 4:** Como a quantidade de produtos vendidos varia por dia da semana?
*   **Dica de Visualização:** `Bar chart`. Use `EXTRACT(DOW FROM data_venda)`.

**Questão 5:** Qual é o preço médio (em Reais) dos produtos vendidos em cada categoria?
*   **Dica de Visualização:** `Bar chart`. Use `AVG(preco_unitario / 100.0)`.

**Questão 6:** Existe alguma correlação entre a quantidade de vendas e a hora do dia?
*   **Dica de Visualização:** `Time series`. Agrupe por hora usando `EXTRACT(HOUR FROM data_venda)`.

**Questão 7:** Como as vendas da categoria "Eletrônicos" se comparam com as da categoria "Livros" ao longo do tempo?
*   **Dica de Visualização:** `Time series` com múltiplas linhas.

**Questão 8:** Qual foi o dia com o maior pico de receita no último ano?
*   **Dica de Visualização:** `Stat` com cálculo de `MAX` ou explorando o gráfico de série temporal.

**Questão 9:** Qual o ticket médio por transação?
*   **Dica de Visualização:** `Stat`. Use `AVG((preco_unitario / 100.0) * quantidade)`.

**Questão 10:** Mostre a distribuição de produtos vendidos por faixa de preço (em Reais).
*   **Dica de Visualização:** `Histogram`. Use uma `CASE` statement sobre `preco_unitario / 100.0` para criar as faixas.