<div align="center">

# Previsão de Demanda de Atendimentos Ambulatoriais do HMPA

### Um pipeline de séries temporais em Julia baseado em dados reais do SUS

[![Julia](https://img.shields.io/badge/Julia-1.x-9558B2?logo=julia&logoColor=white)](https://julialang.org/)
[![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)](#7-status-do-projeto)
[![Licença](https://img.shields.io/badge/dados-DATASUS%2FSIA--SUS-blue)](https://datasus.saude.gov.br/)
[![IC](https://img.shields.io/badge/Inicia%C3%A7%C3%A3o%20Cient%C3%ADfica-IFBA-006341)](https://portal.ifba.edu.br/)

**Autor:** Rian ([@Rian144hz](https://github.com/Rian144hz))
**Orientador:** Prof. Fabiano Vaz — IFBA, Campus Paulo Afonso
**Instituição:** Instituto Federal da Bahia (IFBA) · Núcleo de Ciência, Tecnologia e Inovação (NCTI) · Prefeitura Municipal de Paulo Afonso

</div>

---

## Resumo

Este projeto de iniciação científica desenvolve um pipeline de séries temporais, implementado em Julia, para prever a demanda de atendimentos ambulatoriais do **Hospital Municipal de Paulo Afonso (HMPA)**. A motivação é operacional: antecipar picos de demanda permite à gestão hospitalar planejar escala de equipes, ocupação de leitos e provisão de insumos com base em evidência, não em estimativa informal.

Diferente de abordagens que treinam modelos com dados sintéticos, este trabalho utiliza **dados públicos e oficiais do Ministério da Saúde** (SIA/SUS, via TABNET), consolidados para o município de Paulo Afonso (BA) no período 2019–2026. A fase atual do projeto estabelece a base de dados e a infraestrutura de análise; a próxima fase (Seção 5) migra a granularidade de anual para **semanal/diária**, viabilizando a modelagem preditiva propriamente dita com `MLJ.jl`.

---

## Sumário

1. [Objetivo e motivação](#1-objetivo-e-motivação)
2. [Fonte de dados](#2-fonte-de-dados)
3. [Série histórica obtida](#3-série-histórica-obtida)
4. [Metodologia](#4-metodologia)
5. [Trabalhos futuros](#5-trabalhos-futuros--refatoração-para-dados-semanais)
6. [Estrutura do repositório](#6-estrutura-do-repositório)
7. [Status do projeto](#7-status-do-projeto)
8. [Referências](#8-referências)

---

## 1. Objetivo e motivação

Antecipar picos de demanda no HMPA para que a gestão hospitalar possa planejar equipes, leitos e insumos com base em **dados reais**, seguindo diretrizes definidas em reunião de orientação (03/08):

1. Utilizar exclusivamente **dados reais** (DATASUS/SIA-SUS), descartando simulação sintética como fonte primária.
2. Priorizar granularidade **semanal** — "toda segunda-feira tem X atendimentos" — em vez de somente a série anual.
3. Manter rigor metodológico compatível com publicação futura (artigo ou pôster científico).

## 2. Fonte de dados

Os dados utilizados são públicos, oficiais e de acesso irrestrito (Open Data), disponibilizados pelo Ministério da Saúde através do DATASUS.

| Campo | Descrição |
|---|---|
| Sistema | Sistema de Informações Ambulatoriais do SUS (SIA/SUS) |
| Portal | TABNET — `tabnet.datasus.gov.br` |
| Tabela | Produção Ambulatorial do SUS — Bahia — por Local de Atendimento |
| Unidade geográfica | Paulo Afonso, BA (código IBGE 292400) |
| Período coberto | Janeiro/2019 – Maio/2026 |
| Variável | `Qtd. apresentada` (procedimentos ambulatoriais apresentados, proxy de atendimentos) |

**Procedimento de extração**, reprodutível por qualquer terceiro:

1. Acessar `tabnet.datasus.gov.br/cgi/tabcgi.exe?sia/cnv/qaba.def`.
2. Configurar Linha = `Município`, Coluna = `Ano` (ou `Ano/mês`), Conteúdo = `Qtd.apresentada`.
3. Selecionar o município **Paulo Afonso** (292400) e o período de interesse.
4. Gerar a tabela e exportar via `COPIA COMO .CSV`.

O CSV exportado pelo TABNET segue um formato específico (cabeçalho descritivo nas 4 primeiras linhas, dados na 5ª–6ª, encoding ISO-8859-1). O parser `ler_sia` (Seção 4) trata esse formato automaticamente.

> **Nota de qualidade dos dados:** o DATASUS atualiza a base com defasagem. O próprio TABNET sinaliza que os *"dados referentes aos últimos seis meses [estão] sujeitos a atualização"*. Por isso, os anos de borda da série (2019 e 2026) são tratados como **parciais** e excluídos do cálculo de médias.

## 3. Série histórica obtida

**Paulo Afonso — atendimentos ambulatoriais (SIA/SUS), por ano**

| Ano | Atendimentos | Completude |
|---|---:|---|
| 2019 | 57.605 | parcial |
| 2020 | 1.428.143 | completo |
| 2021 | 1.885.407 | completo |
| 2022 | 2.569.199 | completo |
| 2023 | 1.724.598 | completo |
| 2024 | 2.144.396 | completo |
| 2025 | 2.476.301 | completo |
| 2026 | 178.400 | parcial |

**Estatísticas descritivas (anos completos, 2020–2025):**

| Métrica | Valor |
|---|---:|
| Média anual | 2.038.007 |
| Média mensal | 169.834 |
| Média diária | 5.584 |

![Atendimentos SUS — Paulo Afonso](https://github.com/Rian144hz/hmpa_jl/raw/main/figures/pauloafonso_atendimentos.png)

*Figura 1 — Série anual de atendimentos ambulatoriais do SUS em Paulo Afonso (2019–2026). Barras em cinza indicam anos com dado parcial, excluídos do cálculo da média. Gerado com Julia + Plots.*

## 4. Metodologia

### 4.1 Pipeline de leitura e tratamento

```julia
using DataFrames, Statistics

function ler_sia(caminho)
    linhas = readlines(caminho)
    cabecalho = split(linhas[5], ";")
    limpa(s) = replace(strip(String(s)), "\"" => "")
    anos    = limpa.(cabecalho[2:end-1])
    dados   = split(linhas[6], ";")
    valores = parse.(Int, limpa.(dados[2:end-1]))
    return DataFrame(Ano=parse.(Int, anos), Atendimentos=valores)
end

pa = ler_sia("data/pauloafonso.csv")
media = mean(filter(r -> 2020 <= r.Ano <= 2025, pa).Atendimentos)
println("Média anual PA: ", round(media), " → ~", round(media/365), "/dia")
```

### 4.2 Execução do pipeline completo

```bash
julia --project=. scripts/executar.jl
```

Requer Julia 1.x e as dependências declaradas em `Project.toml` (`CSV.jl`, `DataFrames.jl`, `Statistics`, `Plots.jl`, `MLJ.jl`, `MLJDecisionTreeInterface.jl`, `ShiftedArrays.jl`).

## 5. Trabalhos futuros — refatoração para dados semanais

A fase atual estabeleceu a base de dados anual; a orientação do projeto é migrar para granularidade **semanal/diária**, indispensável para capturar sazonalidade intra-semana (efeito dia-da-semana) — sinal que a série anual, por construção, não pode carregar.

**5.1 — Obtenção de dados diários.** Os dados anuais/mensais do DATASUS não preservam o dia da semana. Ação planejada: obter a série diária de atendimentos do HMPA via parceria NCTI/Prefeitura. Enquanto o acesso não é formalizado, `data/atendimentos_hmpa.csv` (já no repositório) serve como base diária provisória.

**5.2 — Agregação por dia da semana.**

```julia
using Dates
dado_diario.dia_semana = dayofweek.(dado_diario.Data)  # 1=Seg ... 7=Dom
medias_semana = combine(groupby(dado_diario, :dia_semana),
                         :Atendimentos => mean => :media)
```

**5.3 — Baseline e avaliação.** Baseline por média móvel de 7 dias (`ShiftedArrays.jl`); avaliação por MAE e MAPE em conjunto de teste separado temporalmente (sem vazamento de informação futura); modelo avançado via árvore de decisão em `MLJ.jl` para capturar sazonalidade semanal e efeitos de feriado.

**5.4 — Visualização.** Gráfico real vs. previsto (série observada em azul, previsão em laranja), no padrão já estabelecido em `figures/previsao_hmpa.png`.

## 6. Estrutura do repositório

```
hmpa_jl/
├── Project.toml              # dependências Julia
├── Manifest.toml
├── README.md
├── data/
│   ├── atendimentos_hmpa.csv  # base diária (produção própria)
│   └── pauloafonso.csv        # SIA/SUS anual (dado real, DATASUS)
├── src/
│   ├── SimulaDados.jl         # geração/tratamento de dados
│   ├── Modelo.jl              # modelo de previsão
│   └── Visualizacao.jl        # geração de gráficos
├── scripts/
│   └── executar.jl            # pipeline ponta a ponta
└── figures/
    ├── previsao_hmpa.png
    └── pauloafonso_atendimentos.png
```

## 7. Status do projeto

- [x] Definição de diretrizes com orientador (03/08)
- [x] Obtenção de dados reais (DATASUS/SIA-SUS — Paulo Afonso)
- [x] Pipeline de leitura e tratamento em Julia
- [x] Gráfico de série histórica anual
- [ ] Dados diários do HMPA (parceria NCTI/Prefeitura)
- [ ] Refatoração da agregação para granularidade semanal
- [ ] Baseline (MAE/MAPE) e modelo preditivo (`MLJ.jl`)
- [ ] Redação de artigo/pôster científico

## 8. Referências

- BRASIL. Ministério da Saúde. **Sistema de Informações Ambulatoriais do SUS (SIA/SUS)**. DATASUS. Disponível em: <https://datasus.saude.gov.br/acesso-a-informacao/producao-ambulatorial-sia-sus/>.
- DATASUS. **TABNET — Produção Ambulatorial do SUS, Bahia, por Local de Atendimento**. Disponível em: <http://tabnet.datasus.gov.br/cgi/tabcgi.exe?sia/cnv/qaba.def>.

---

<div align="center">

*Projeto desenvolvido no âmbito da Iniciação Científica (voluntariado) — IFBA, Campus Paulo Afonso.*

</div>
