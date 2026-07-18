# Previsão de Demanda de Atendimentos — HMPA (Paulo Afonso/BA)

Projeto de ciência de dados em Julia para prever picos de demanda de
atendimento no Hospital Municipal de Paulo Afonso (HMPA), com o objetivo de
apoiar o planejamento de equipe e leitos. **Status atual:** prova de conceito
— o pipeline completo (geração de dados → previsão → avaliação → gráfico) já
roda de ponta a ponta; o modelo ainda é um baseline simples (média móvel).

## Motivação

Paulo Afonso é o único município da Bahia integrante da **Rede Nacional de
Cidades Inteligentes** do Ministério das Cidades, e conta hoje com o **NCTI —
Núcleo de Pesquisa em Ciência, Tecnologia e Inovação**, fruto da parceria
entre a Prefeitura e o IFBA. O HMPA, por sua vez, está passando por
modernização (novo tomógrafo, ultrassom, UTI em construção).

Este projeto nasce da pergunta: **dá para prever, com dias de antecedência,
quando o hospital vai enfrentar um pico de demanda?** Se sim, isso ajuda a
planejar escala de equipe, estoque e leitos com mais eficiência.

## O que este projeto faz (hoje)

1. **Gera uma série temporal sintética** de atendimentos diários
   (`src/SimulaDados.jl`): uma base de ~38 atendimentos/dia, com queda aos fins
   de semana e ruído gaussiano. É reproduzível (semente fixa) e serve como
   base para exercitar o pipeline.
   > Dados reais de atendimento são sensíveis e não são públicos. A simulação
   > serve como prova de conceito: o pipeline inteiro já fica pronto para
   > receber dados reais assim que houver acesso — via o NCTI ou o
   > DATASUS/SIH-SUS.
2. **Prevê com média móvel** de 7 dias (`src/Modelo.jl`): a previsão de cada
   dia é a média dos atendimentos dos 7 dias anteriores. É o baseline de
   referência contra o qual modelos mais sofisticados serão comparados.
3. **Avalia o erro** com MAE e MAPE em um conjunto de teste separado no tempo
   (últimos 20% dos dias), evitando vazamento de dados.
4. **Gera um gráfico** comparando atendimentos reais vs. previstos
   (`src/Visualizacao.jl`).

## Como rodar

Pré-requisitos: [Julia 1.9+](https://julialang.org/downloads/) instalado.

```bash
git clone <url-do-seu-repositorio>
cd previsao-hmpa
julia --project=. -e 'using Pkg; Pkg.instantiate()'   # instala as dependências
julia --project=. scripts/executar.jl                  # roda o pipeline completo
```

Ao final, você terá:
- `data/atendimentos_hmpa.csv` — a série de dados gerada
- `figures/previsao_hmpa.png` — o gráfico real vs. previsto
- métricas de erro impressas no terminal (MAE e MAPE)

> Na primeira execução, o `Pkg.instantiate()` baixa os pacotes (CSV,
> DataFrames, Plots, etc.) — pode demorar alguns minutos.

## Próximos passos (roadmap)

Estes itens ainda **não** estão implementados — são o caminho para transformar
o baseline atual na solução descrita na motivação:

- [ ] **Dados realistas**: incluir sazonalidade anual (período de chuvas /
      arboviroses, comum no Nordeste) e surtos esporádicos na geração
      sintética.
- [ ] **Modelo de regressão**: substituir a média móvel por regressão (ex.:
      GLM.jl) com features de calendário — dia da semana, tendência e
      sazonalidade via termos de Fourier.
- [ ] **Dados reais**: substituir os simulados por dados reais (DATASUS/SIH-SUS
      ou dados internos do HMPA, via parceria com o NCTI).
- [ ] **Modelos não-lineares**: testar árvores de decisão (`MLJ.jl`) ou redes
      neurais simples (`Flux.jl`) e comparar com o baseline linear.
- [ ] **Variáveis externas**: temperatura, chuva, calendário de feriados/eventos
      da cidade.
- [ ] **Painel interativo**: empacotar como dashboard (`Genie.jl`) para uso pela
      gestão municipal.

## Estrutura do repositório

```
previsao-hmpa/
├── Project.toml          # dependências do projeto Julia
├── Manifest.toml         # versões travadas (gerado pelo Pkg)
├── src/
│   ├── SimulaDados.jl     # geração da série sintética
│   ├── Modelo.jl          # média móvel + métricas de erro
│   └── Visualizacao.jl    # gráfico real vs. previsto
├── scripts/
│   └── executar.jl        # pipeline completo (rodar este arquivo)
├── data/                  # dados gerados (não versionado)
└── figures/               # gráficos gerados (não versionado)
```

## Autor

Projeto desenvolvido como proposta para bolsa de pesquisa no NCTI
(Núcleo de Pesquisa em Ciência, Tecnologia e Inovação) — Paulo Afonso/BA.
