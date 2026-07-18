# Previsão de Demanda de Atendimentos — HMPA (Paulo Afonso/BA)

Projeto de ciência de dados em Julia para prever picos de demanda de
atendimento no Hospital Municipal de Paulo Afonso (HMPA), com o objetivo de
apoiar o planejamento de equipe e leitos.

## Motivação

Paulo Afonso é o único município da Bahia integrante da **Rede Nacional de
Cidades Inteligentes** do Ministério das Cidades, e conta hoje com o **NCTI —
Núcleo de Pesquisa em Ciência, Tecnologia e Inovação**, fruto da parceria
entre a Prefeitura e o IFBA. O HMPA, por sua vez, está passando por
modernização (novo tomógrafo, ultrassom, UTI em construção).

Este projeto nasce da pergunta: **dá para prever, com dias de antecedência,
quando o hospital vai enfrentar um pico de demanda?** Se sim, isso ajuda a
planejar escala de equipe, estoque e leitos com mais eficiência.

## O que este projeto faz

1. **Gera uma série temporal sintética** de atendimentos diários, com padrões
   realistas: sazonalidade semanal, sazonalidade anual (período de chuvas /
   arboviroses, comum no Nordeste) e surtos esporádicos (`src/SimulaDados.jl`).
   > Dados reais de atendimento são sensíveis e não são públicos. A simulação
   > serve como prova de conceito: o pipeline inteiro (features → modelo →
   > avaliação → gráfico) já fica pronto para receber dados reais assim que
   > houver acesso — via o NCTI ou o DATASUS/SIH-SUS.
2. **Constrói features de calendário** (dia da semana, tendência, sazonalidade
   via termos de Fourier) — `src/Modelo.jl`.
3. **Treina um modelo de regressão** (GLM.jl) e avalia com MAE e MAPE em um
   conjunto de teste separado no tempo (sem vazamento de dados).
4. **Gera um gráfico** comparando atendimentos reais vs. previstos, destacando
   o período de teste — `src/Visualizacao.jl`.

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

## Próximos passos (roadmap)

- [ ] Substituir dados simulados por dados reais (DATASUS/SIH-SUS ou dados
      internos do HMPA, via parceria com o NCTI)
- [ ] Testar modelos não-lineares (árvores de decisão via `MLJ.jl`, ou redes
      neurais simples via `Flux.jl`) e comparar com o baseline linear
- [ ] Incorporar variáveis externas: temperatura, chuva, calendário de
      feriados/eventos da cidade
- [ ] Empacotar como painel interativo (`Genie.jl`) para uso pela gestão
      municipal

## Estrutura do repositório

```
previsao-hmpa/
├── Project.toml          # dependências do projeto Julia
├── src/
│   ├── SimulaDados.jl     # geração da série sintética
│   ├── Modelo.jl          # features + regressão + métricas
│   └── Visualizacao.jl    # gráfico real vs. previsto
├── scripts/
│   └── executar.jl        # pipeline completo (rodar este arquivo)
├── data/                  # dados gerados (não versionado)
└── figures/               # gráficos gerados (não versionado)
```

## Autor

Projeto desenvolvido como proposta para bolsa de pesquisa no NCTI
(Núcleo de Pesquisa em Ciência, Tecnologia e Inovação) — Paulo Afonso/BA.
