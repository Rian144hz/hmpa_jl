# Previsão de Demanda de Atendimentos — HMPA (Paulo Afonso/BA)

> **Projeto de ciência de dados em Julia** para prever, com antecedência, picos de
> demanda de atendimento no Hospital Municipal de Paulo Afonso (HMPA), apoiando o
> planejamento de equipes, leitos e insumos da unidade.

![Status](https://img.shields.io/badge/status-prova%20de%20conceito-yellow)
![Linguagem](https://img.shields.io/badge/linguagem-Julia%201.9%2B-blue)
![Licença](https://img.shields.io/badge/licença-MIT-green)
![Pipeline](https://img.shields.io/badge/pipeline-end--to--end-success)

---

## Resumo

Este repositório implementa um **pipeline completo de previsão de séries
temporais** de atendimentos hospitalares — da geração dos dados à avaliação do
modelo e à visualização dos resultados. O objetivo é responder a uma pergunta
concreta da gestão pública de saúde:

> **É possível antecipar, com alguns dias de antecedência, quando o hospital
> enfrentará um pico de demanda?** Se sim, isso permite planejar escalas,
> estoque e leitos com muito mais eficiência.

O modelo atual é um *baseline* de referência (média móvel de 7 dias), já
funcional de ponta a ponta e pronto para receber dados reais assim que houver
acesso — via parceria com o **NCTI** (Núcleo de Pesquisa em Ciência, Tecnologia
e Inovação) ou fontes públicas como o **DATASUS/SIH-SUS**.

---

## Contexto e Motivação

Paulo Afonso é o único município da Bahia integrante da **Rede Nacional de
Cidades Inteligentes** do Ministério das Cidades, e conta hoje com o **NCTI**,
fruto da parceria entre a Prefeitura e o IFBA. O HMPA, por sua vez, está em
processo de modernização (novo tomógrafo, ultrassom e UTI em construção).

Nesse cenário, ferramentas de apoio à decisão baseadas em dados deixam de ser
luxo e passam a ser necessidade. Este projeto nasce como proposta de bolsa de
pesquisa no NCTI, com potencial de evoluir para um painel de apoio à gestão
municipal.

---

## O que o projeto entrega (hoje)

O pipeline cobre as quatro etapas essenciais de um projeto de previsão:

1. **Geração de dados sintéticos** (`src/SimulaDados.jl`)
   Cria uma série temporal de atendimentos diários (~38/dia, com queda aos fins
   de semana e ruído gaussiano). É reproduzível (semente fixa) e serve para
   exercitar todo o fluxo. Dados reais de saúde são sensíveis e não públicos; a
   simulação permite validar a metodologia antes do acesso aos dados oficiais.

2. **Modelo preditivo** (`src/Modelo.jl`)
   Previsão por **média móvel de 7 dias**: cada dia é previsto pela média dos 7
   dias anteriores. Este é o *baseline* contra o qual modelos mais sofisticados
   serão comparados.

3. **Avaliação rigorosa** (`src/Modelo.jl`)
   Erro medido por **MAE** (Erro Absoluto Médio) e **MAPE** (Erro Percentual
   Absoluto Médio) em um conjunto de teste separado no tempo (últimos 20% dos
   dias), evitando *data leakage* (vazamento de dados).

4. **Visualização** (`src/Visualizacao.jl`)
   Gráfico comparando atendimentos reais vs. previstos ao longo do ano.

---

## Resultados — um exemplo de previsão

Abaixo, a saída do pipeline sobre um ano de dados simulados (2023). A linha
laranja tracejada (previsão) acompanha a tendência central capturada pela média
móvel, enquanto a linha azul (real) mostra a volatilidade diária do hospital —
ilustrando exatamente o desafio que modelos mais avançados (roadmap abaixo)
precisarão enfrentar.

![HMPA — atendimentos reais vs. previstos](figures/previsao_hmpa.png)

| Métrica | Descrição | Conjunto de teste |
| --- | --- | --- |
| **MAE** | Erro absoluto médio (atendimentos/dia) | impresso no terminal |
| **MAPE** | Erro percentual absoluto médio (%) | impresso no terminal |

> As métricas exatas são calculadas e exibidas no terminal a cada execução do
> pipeline (`scripts/executar.jl`).

---

## Como reproduzir

**Pré-requisitos:** [Julia 1.9+](https://julialang.org/downloads/) instalado.

```bash
git clone <url-do-repositorio>
cd previsao-hmpa

# 1) instala as dependências do projeto (CSV, DataFrames, Plots, ...)
julia --project=. -e 'using Pkg; Pkg.instantiate()'

# 2) roda o pipeline completo (dados → previsão → avaliação → gráfico)
julia --project=. scripts/executar.jl
```

Ao final, o pipeline produz:

- `data/atendimentos_hmpa.csv` — a série de dados gerada
- `figures/previsao_hmpa.png` — o gráfico real vs. previsto
- métricas de erro (MAE e MAPE) impressas no terminal

> Na primeira execução, o `Pkg.instantiate()` baixa os pacotes e pode levar
> alguns minutos.

---

## Estrutura do repositório

```
previsao-hmpa/
├── Project.toml          # dependências do projeto Julia
├── Manifest.toml         # versões travadas (gerado pelo Pkg)
├── src/
│   ├── SimulaDados.jl     # geração da série sintética
│   ├── Modelo.jl          # média móvel + métricas de erro (MAE/MAPE)
│   └── Visualizacao.jl    # gráfico real vs. previsto
├── scripts/
│   └── executar.jl        # pipeline completo (ponto de entrada)
├── data/                  # dados gerados (não versionado)
└── figures/               # gráficos gerados (não versionado)
```

---

## Roadmap — próximos passos

Itens ainda **não** implementados; representam o caminho de maturação do
*baseline* atual até a solução descrita na motivação:

- [ ] **Dados realistas**: sazonalidade anual (período de chuvas / arboviroses,
      comum no Nordeste) e surtos esporádicos na geração sintética.
- [ ] **Modelo de regressão**: substituir a média móvel por regressão
      (`GLM.jl`) com *features* de calendário — dia da semana, tendência e
      sazonalidade via termos de Fourier.
- [ ] **Dados reais**: trocar os simulados por dados reais (DATASUS/SIH-SUS ou
      internos do HMPA, via parceria com o NCTI).
- [ ] **Modelos não-lineares**: árvores de decisão (`MLJ.jl`) ou redes neurais
      simples (`Flux.jl`), comparando com o *baseline* linear.
- [ ] **Variáveis externas**: temperatura, precipitação e calendário de
      feriados/eventos da cidade.
- [ ] **Painel interativo**: empacotar como *dashboard* (`Genie.jl`) para uso
      pela gestão municipal.

---

## Stack e metodologia

- **Linguagem:** Julia 1.9+
- **Ecossistema:** `DataFrames` (manipulação), `CSV` (I/O), `Plots` (visualização)
- **Abordagem:** séries temporais, divisão temporal de treino/teste, métricas de
  erro padronizadas (MAE/MAPE)
- **Reprodutibilidade:** semente fixa na geração de dados; manifesto de
  dependências versionado

---

## Autor

Projeto desenvolvido como proposta de **bolsa de pesquisa no NCTI** (Núcleo de
Pesquisa em Ciência, Tecnologia e Inovação) — Paulo Afonso/BA.

Licença: MIT.
