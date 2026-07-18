
module Visualizacao
using Plots
using DataFrames
export plotar_previsao

function plotar_previsao(df::DataFrame, caminho::String="figures/previsao_hmpa.png")
    plot(df.data, df.atendimentos,
         label="Real", color=:steelblue, linewidth=2,
         xlabel="Data", ylabel="Atendimentos/dia",
         title="HMPA - atendimentos reais vs. previstos",
         legend=:topleft, size=(900, 450))

    plot!(df.data, df.previsto,
          label="Previsto", color=:darkorange, linewidth=2, linestyle=:dash)
    mkpath(dirname(caminho))
    savefig(caminho)
end

end 