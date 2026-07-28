using MLJ
using Plots

DecisionTreeRegressor = @load DecisionTreeRegressor pkg=DecisionTree

# dados fictícios pequenos, só pra testar o mecanismo
indice = Float64.(1:20)                          # dia 1, 2, 3... 20
dow = Float64.([mod(i-1, 7) + 1 for i in 1:20])  # dia da semana (1 a 7, repetindo)

X = (indice = indice, dow = dow)   # tabela de entrada (features)
y = [20.0, 15.0, 12.0, 18.0, 13.0, 19.0, 31.0,
     10.0, 16.0, 13.0, 19.0, 14.0, 30.0, 12.0,
     11.0, 17.0, 14.0, 20.0, 45.0, 11.0]           # valores reais (alvo)

modelo = DecisionTreeRegressor(max_depth=3)
mach = machine(modelo, X, y)
fit!(mach)                          # aqui a árvore "aprende"

previsoes = predict(mach, X)
println(previsoes)

plot(dias, y,
     label="Real", color=:steelblue, linewidth=2, marker=:circle,
     xlabel="Dia", ylabel="Atendimentos",
     title="Árvore de decisão: real vs. previsto")

plot!(dias, previsoes,
      label="Previsto (árvore)", color=:darkorange, linewidth=2,
      linestyle=:dash, marker=:diamond)

savefig("teste_arvore.png")
println("Gráfico salvo em teste_arvore.png")