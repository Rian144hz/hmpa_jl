# Previsão de Demanda de Atendimentos — HMPA

Projeto de séries temporais em Julia para prever picos de demanda no
Hospital Municipal de Paulo Afonso (HMPA), dando suporte ao planejamento
de equipes e leitos. TCC/bolsa de pesquisa no NCTI (Paulo Afonso/BA).

---

## O problema

Dado o histórico diário de atendimentos `y_1, y_2, ..., y_n`, queremos
estimar `ŷ_{t}` para os próximos dias. No estágio atual usamos um
*baseline* simples — **média móvel** de janela `w = 7`:

```
ŷ_t = (1 / w) · Σ y_{t-i},   i = 1..w
```

É o ponto de partida contra o qual modelos mais complexos serão medidos.

## Pipeline

O repo roda de ponta a ponta em 4 etapas (`scripts/executar.jl`):

| Etapa | Arquivo | O que faz |
| --- | --- | --- |
| 1. Dados | `src/SimulaDados.jl` | gera série sintética (~38/dia, queda no fim de semana, ruído gaussiano); semente fixa = reprodutível |
| 2. Modelo | `src/Modelo.jl` | previsão por média móvel + métricas de erro |
| 3. Avaliação | `src/Modelo.jl` | MAE e MAPE no conjunto de teste (últimos 20% dos dias) |
| 4. Plot | `src/Visualizacao.jl` | gráfico real × previsto |

### Núcleo do modelo (`src/Modelo.jl`)

```julia
function previsao_media_movel(valores::AbstractVector, janela::Int=7)
    n = length(valores)
    previsoes = zeros(Float64, n)
    for i in 1:n
        if i <= janela
            previsoes[i] = mean(valores[1:(i-1)])
        else
            previsoes[i] = mean(valores[(i-janela):(i-1)])
        end
    end
    return previsoes
end

# MAE e MAPE
mae  = mean(abs.(real .- previsto))
mape = mean(abs.(real .- previsto) ./ real .* 100)
```

A divisão em treino/teste é **temporal** (corte em `0.8 · n`), então não
há *data leakage* — o modelo só "vê" o passado para prever o futuro.

## Resultados

Um ano de dados simulados (2023), janela de 7 dias:

![HMPA — atendimentos reais vs. previstos](figures/previsao_hmpa.png)

A linha laranja (previsão) acompanha a tendência central, mas a linha azul
(real) mostra a volatilidade diária que o baseline não captura — exatamente
o que os próximos modelos têm que resolver.

As métricas (MAE/MAPE) são impressas no terminal a cada execução.

## Como rodar

Requer [Julia 1.9+](https://julialang.org/downloads/).

```bash
git clone <url-do-repositorio>
cd previsao-hmpa
julia --project=. -e 'using Pkg; Pkg.instantiate()'   # baixa as deps (1ª vez)
julia --project=. scripts/executar.jl                 # roda o pipeline
```

Saídas:

- `data/atendimentos_hmpa.csv` — série gerada
- `figures/previsao_hmpa.png` — gráfico real × previsto
- MAE/MAPE no terminal

## Estrutura

```
previsao-hmpa/
├── Project.toml          # deps do projeto
├── Manifest.toml         # versões travadas
├── src/
│   ├── SimulaDados.jl     # série sintética
│   ├── Modelo.jl          # média móvel + MAE/MAPE
│   └── Visualizacao.jl    # plot
├── scripts/
│   └── executar.jl        # pipeline (entrypoint)
├── data/                  # gerado (não versionado)
└── figures/               # gerado (PNG versionado p/ o README)
```

## Próximos passos

- [ ] Sazonalidade anual (chuvas/arboviroses) na geração sintética
- [ ] Regressão (`GLM.jl`) com *features* de calendário + termos de Fourier
- [ ] Dados reais (DATASUS/SIH-SUS ou HMPA via NCTI)
- [ ] Modelos não-lineares: árvores (`MLJ.jl`) / redes (`Flux.jl`)
- [ ] Variáveis externas: temperatura, chuva, feriados
- [ ] Dashboard interativo (`Genie.jl`)

---

Autor: projeto de bolsa de pesquisa no NCTI — Paulo Afonso/BA. Licença MIT.
