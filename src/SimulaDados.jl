module SimulaDados
using Dates
using Random
using DataFrames

export gerar_serie_atendimentos

    function gerar_serie_atendimentos(;data_inicio::Date = Date(2023, 1, 1),
                                                    numero_dias:: Int = 365,
                                                    seed:: Int = 42)
        numeros_aleatorios = MersenneTwister(seed);
        base = 38.0;

        datas = Date[];
        atendimentos = Int64[];

        for i in 0:(numero_dias - 1) 
            nova_data = data_inicio +day(i);
            push!(datas,nova_data);

            valor = base;

            dia_da_semana = dayofweek(nova_data);
            
            for dia_da_semana in (6,7) 
                valor = valor - 8.0;
            end
            valor = valor + randn(numeros_aleatorios) * 3.0;

            push!(atendimentos,valor);
        end
        return DataFrame =(data = datas, atendimentos = atendimentos);
    end
end 