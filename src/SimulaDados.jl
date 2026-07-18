module SimulaDados

using Dates
using Random
using DataFrames

export gerar_serie_atendimentos

function gerar_serie_atendimentos(; data_inicio::Date=Date(2023, 1, 1),
                                     n_dias::Int=365,
                                     seed::Int=42)
    rng = MersenneTwister(seed)
    base = 38.0

    datas = Date[]
    atendimentos = Float64[]

    for i in 0:(n_dias - 1)
        nova_data = data_inicio + Day(i)
        push!(datas, nova_data)

        dow = dayofweek(nova_data)

        valor = base
        if dow in (6, 7)
            valor = valor - 8.0
        end
        valor = valor + randn(rng) * 3.0

        push!(atendimentos, valor)
    end

    return DataFrame(data = datas, atendimentos = atendimentos)
end

end # module