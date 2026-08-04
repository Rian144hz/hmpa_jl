# Previsão de Demanda de Atendimentos — HMPA
### Séries temporais aplicadas à gestão hospitalar pública
**Hospital Municipal de Paulo Afonso (BA)** · Projeto de Iniciação Científica orientado pelo Prof. Fabiano Vaz (IFBA) · parceria Prefeitura–IFBA via NCTI

---

## Proposta
Antecipar picos de demanda no HMPA para que a gestão planeje equipes, leitos e insumos com base em dados — não em adivinhação.

Este projeto desenvolve um sistema de previsão de séries temporais para o volume de atendimentos do Hospital Municipal de Paulo Afonso. A entrega é um pipeline funcional de ponta a ponta (obtenção de dados → modelo → avaliação → visualização), reprodutível e documentado, servindo como base para a adoção de dados reais do hospital.

### Objetivos
- Construir um modelo que sinalize, com antecedência, dias de alta demanda.
- Reduzir o improviso no dimensionamento de equipes e leitos.
- Estabelecer uma linha de base (baseline) mensurável contra a qual modelos mais avançados serão comparados.

### Por que importa
Paulo Afonso é o único município da Bahia na Rede Nacional de Cidades Inteligentes (Ministério das Cidades) e abriga o NCTI (Núcleo de Pesquisa em Ciência, Tecnologia e Inovação), parceria Prefeitura–IFBA. O HMPA passa por modernização (tomógrafo, ultrassom, UTI). Há, portanto, ambiente e demanda reais para ciência de dados aplicada à saúde pública.

---

## Diretrizes definidas com o orientador (reunião 03/08)
Na reunião de orientação, o Prof. Fabiano Vaz definiu os pontos centrais do trabalho:

1. **Usar dados reais**, não sintéticos — a partir de fontes públicas (DATASUS/SIA-SUS) e, futuramente, do HMPA via parceria NCTI/Prefeitura.
2. **Ataque semanal, não anual** — investigar padrões como "toda segunda-feira há X atendimentos", capturando sazonalidade de curto prazo em vez de apenas totais anuais.
3. **Potencial de pesquisa científica** — o trabalho pode evoluir para artigo/poster, dada a raridade de estudos locais de previsão de demanda ambulatorial no interior da Bahia.

> Natureza da participação: voluntariado (confirmado com o orientador), com o objetivo de tirar o projeto do papel e gerar conhecimento aplicado.

---

## Dados reais já obtidos (DATASUS / SIA-SUS)
O pipeline já consome dados públicos do Sistema de Informações Ambulatoriais do SUS, por município da Bahia.

### Paulo Afonso (cód. IBGE 292400) — foco do projeto
| Ano | Atendimentos (Qtd. apresentada) |
|-----|-------------------------------|
| 2019* | 57.605 |
| 2020 | 1.428.143 |
| 2021 | 1.885.407 |
| 2022 | 2.569.199 |
| 2023 | 1.724.598 |
| 2024 | 2.144.396 |
| 2025 | 2.476.301 |
| 2026** | 178.400 |

*\* 2019 e \** 2026 são períodos parciais (o SUS atualiza com defasagem; notas do DATASUS indicam "últimos seis meses, sujeitos a atualização").

**Resumo (média 2020–2025):**
- ~2.038.007 atendimentos/ano
- ~169.834 atendimentos/mês
- **~5.584 atendimentos/dia**

Fonte: Ministério da Saúde — SIA/SUS. Dados de livre acesso (Open Data governamental), consultados via TABNET.

---

## Pipeline (Julia)
O projeto usa Julia (ambiente hmpa_jl) para todo o processamento.

### Como reproduzir (exemplo com Paulo Afonso)
