<p align="center">
  <img src="figures/previsao_hmpa.png" alt="HMPA — atendimentos reais vs. previstos" width="720">
</p>

<h1 align="center">Previsão de Demanda de Atendimentos — HMPA</h1>

<p align="center">
  <b>Séries temporais aplicadas à gestão hospitalar pública</b><br>
  Hospital Municipal de Paulo Afonso (BA) · Projeto de Iniciação Científica / Bolsa de Pesquisa — NCTI
</p>

<p align="center">
  <img src="https://img.shields.io/badge/linguagem-Julia%201.9%2B-blue" alt="Julia">
  <img src="https://img.shields.io/badge/status-pipeline%20funcional-brightgreen" alt="Status">
  <img src="https://img.shields.io/badge/licença-MIT-green" alt="Licença">
</p>

---

## Proposta

> **Antecipar picos de demanda no HMPA para que a gestão planeje equipes, leitos e
> insumos com base em dados — não em adivinhação.**

Este projeto propõe o desenvolvimento de um sistema de **previsão de séries
temporais** para o volume diário de atendimentos do Hospital Municipal de Paulo
Afonso. A entrega atual é um **pipeline funcional de ponta a ponta** (geração de
dados → modelo → avaliação → visualização), servindo como prova de conceito e
base reprodutível para a futura adoção de dados reais do hospital.

**Objetivos**
- Construir um modelo que sinalize, com antecedência, dias de alta demanda.
- Reduzir o improviso no dimensionamento de equipes e leitos.
- Estabelecer uma linha de base (*baseline*) mensurável contra a qual modelos
  mais avançados serão comparados.

**Por que importa:** Paulo Afonso é o único município da Bahia na *Rede Nacional
de Cidades Inteligentes* (Ministério das Cidades) e abriga o **NCTI** (Núcleo de
Pesquisa em Ciência, Tecnologia e Inovação), parceria Prefeitura–IFBA. O HMPA
passa por modernização (tomógrafo, ultrassom, UTI). Há, portanto, ambiente e
demanda reais para ciência de dados aplicada à saúde pública.

---

## Resultados

O gráfico abaixo é a saída direta do pipeline sobre um ano de dados simulados
(2023). A linha laranja (previsão por média móvel de 7 dias) acompanha a
tendência central; a azul (real) revela a volatilidade diária que modelos mais
sofisticados deverão capturar.

![HMPA — atendimentos reais vs. previstos](figures/previsao_hmpa.png)

Erro do *baseline* avaliado em conjunto de teste separado no tempo
(últimos 20% dos dias, ~73 dias), sem vazamento de dados:

| Métrica | Valor | Significado |
| --- | --- | --- |
| **MAE** | 3,71 atendimentos/dia | erro absoluto médio — desvio típico da previsão |
| **MAPE** | 11,03% | erro percentual médio em relação à demanda real |

Ou seja, o modelo de referência erra, em média, cerca de **3 a 4 atendimentos
por dia** — um ponto de partida sólido e quantificado para as próximas
iterações (ver Roadmap).

---

## Metodologia

O problema é modelado como previsão univariada de séries temporais. O *baseline*
atual estima o dia `t` pela média dos `w = 7` dias anteriores:

```
ŷ_t = (1/w) · Σ y_{t-i},   i = 1..w
```

| Etapa | Arquivo | Descrição |
| --- | --- | --- |
| Dados | `src/SimulaDados.jl` | série sintética (~38/dia, queda no fim de semana, ruído gaussiano); semente fixa = reprodutível |
| Modelo | `src/Modelo.jl` | previsão por média móvel de 7 dias |
| Avaliação | `src/Modelo.jl` | MAE e MAPE no teste (últimos 20% dos dias) |
| Visualização | `src/Visualizacao.jl` | gráfico real × previsto |

A divisão treino/teste é **temporal** (corte em 80% dos dias), evitando
*data leakage*: o modelo só utiliza o passado para prever o futuro.

> **Em teste (fora do pipeline principal):** um `DecisionTreeRegressor`
> (`MLJ.jl`) já foi validado com dados sintéticos isolados, usando dia da
> semana e índice de tendência como features. Escolhido em vez de rede
> neural por ser mais adequado a um dataset tabular deste porte, e mais
> interpretável para explicar cada previsão. Próximo passo: integrar ao
> pipeline e comparar MAE/MAPE com o baseline de média móvel.

---

## Como reproduzir

Requer [Julia 1.9+](https://julialang.org/downloads/).

```bash
git clone https://github.com/Rian144hz/hmpa_jl.git
cd hmpa_jl
julia --project=. -e 'using Pkg; Pkg.instantiate()'   # instala dependências (1ª vez)
julia --project=. scripts/executar.jl                 # roda o pipeline completo
```

**Saídas:** `data/atendimentos_hmpa.csv` · `figures/previsao_hmpa.png` · MAE/MAPE no terminal.

---

## Roadmap

- [ ] Sazonalidade anual (período de chuvas/arboviroses) na geração sintética
- [ ] **Árvore de decisão** (`DecisionTreeRegressor`, via `MLJ.jl`) com features de
      calendário (dia da semana, índice de tendência) — já testada isoladamente,
      próximo passo é integrar ao pipeline e comparar o MAE/MAPE com o baseline
      de média móvel
- [ ] Dados reais (DATASUS/SIH-SUS ou HMPA via parceria com o NCTI)
- [ ] Regressão (`GLM.jl`) com features de calendário + termos de Fourier
- [ ] Variáveis externas: temperatura, chuva, feriados
- [ ] Dashboard interativo (`Genie.jl`) para a gestão municipal

---

## Estrutura

```
hmpa_jl/
├── Project.toml           # dependências do projeto
├── src/
│   ├── SimulaDados.jl     # geração da série sintética
│   ├── Modelo.jl          # média móvel + MAE/MAPE
│   └── Visualizacao.jl    # gráfico
├── scripts/
│   └── executar.jl        # pipeline (ponto de entrada)
├── data/                  # CSV gerado pelo pipeline (versionado como evidência)
└── figures/                # gráfico gerado pelo pipeline (PNG versionado p/ o README)
```

> `Manifest.toml` não é versionado (está no `.gitignore`): ele trava as
> versões exatas de cada dependência e é próprio de cada máquina. Quem
> clonar o repositório gera o seu com `Pkg.instantiate()`.

---

<p align="center">
  Projeto de bolsa de pesquisa no <b>NCTI</b> — Paulo Afonso/BA &nbsp;·&nbsp; Licença MIT
</p>
