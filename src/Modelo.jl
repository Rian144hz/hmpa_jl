module Modelo
export previsao_media_movel, metricas_erro
using Statistics
export previsao_media_movel

function previsao_media_movel(valores::AbstractVector, janela::Int=7)
    n = length(valores)
    previsoes = zeros(Float64, n)

    for i in 1:n
        if i == 1
            previsoes[i] = valores[1]
        elseif i <= janela
            previsoes[i] = mean(valores[1:(i-1)])
        else
            previsoes[i] = mean(valores[(i - janela):(i - 1)])
        end
    end

    return previsoes
end

end

function metricas_erro(real::AbstractVector, previsto::AbstractVector)
    diferencas = real .- previsto
    erros_absolutos = abs.(diferencas)

    mae = mean(erros_absolutos)
    mape = mean(erros_absolutos ./ real .* 100)

    return (mae = mae, mape = mape)
end