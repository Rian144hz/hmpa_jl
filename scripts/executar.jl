
using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

include(joinpath(@__DIR__, "..", "src", "SimulaDados.jl"))
include(joinpath(@__DIR__, "..", "src", "Modelo.jl"))
include(joinpath(@__DIR__, "..", "src", "Visualizacao.jl"))

using .SimulaDados
using .Modelo
using .Visualizacao
using DataFrames
using CSV
using Dates

println("1) Gerando dados simulados...")
df = gerar_serie_atendimentos(data_inicio=Date(2023, 1, 1), n_dias=365)

println("2) Salvando CSV...")
mkpath(joinpath(@__DIR__, "..", "data"))
CSV.write(joinpath(@__DIR__, "..", "data", "atendimentos_hmpa.csv"), df)

println("3) Calculando previsão (média móvel, janela=7)...")
df.previsto = previsao_media_movel(df.atendimentos, 7)

println("4) Separando conjunto de teste (últimos 20% dos dias)...")
corte = Int(round(nrow(df) * 0.8))
teste = df[(corte + 1):end, :]

println("5) Calculando métricas de erro no teste...")
m = metricas_erro(teste.atendimentos, teste.previsto)
println("   MAE:  ", round(m.mae, digits=2), " atendimentos/dia")
println("   MAPE: ", round(m.mape, digits=2), "%")

println("6) Gerando gráfico...")
plotar_previsao(df, joinpath(@__DIR__, "..", "figures", "previsao_hmpa.png"))

println("Pronto!")