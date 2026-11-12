# Apuração — Campanha de Incentivo "Giro Certo"

Exercício de preparação que fiz simulando uma apuração real de campanha de incentivo: tratamento de bases brutas e sujas, aplicação de regras de elegibilidade, cálculo de prêmio por participante e uma trilha de auditoria dos erros que encontrei e corrigi no caminho — feito em Excel (Power Query + fórmulas) e validado de forma independente em SQL.

**Painel visual:** [LINK_DO_NETLIFY_AQUI]

## Regulamento

- Período: 01/10/2026 a 31/10/2026
- Categoria elegível: "bebida"
- Nota fiscal aprovada e sem duplicidade (as duas ocorrências de uma NF duplicada são excluídas)
- Participante ativo, loja existente no cadastro
- Gatilho: loja precisa atingir ≥ 80% da meta
- Faixas: 80–99,99% = 1,0x · 100–119,99% = 1,2x · ≥120% = 1,5x
- Prêmio = 2% do valor vendido válido × multiplicador da faixa
- Teto: R$ 5.000 por participante

## 1. Tratamento — o que foi excluído e por quê

| Linha | Motivo da exclusão |
|---|---|
| V0016, V0090, V0168 | Vendas fora do período de outubro |
| V0015 e V0132 | NF100041 duplicada — as duas ocorrências foram excluídas, conforme o regulamento |
| V0177 | Venda de R$ 15.230,00, muito acima do padrão da participante e sem motivo de exclusão previsto no regulamento. Decisão de apuração: excluída por julgamento, não por regra escrita — premissa a validar com o cliente |
| V0018, V0158, V0162 | Participante Marcelo Gomes (P011) inativo |
| V0085, V0170, V0185 | Participante João Pereira (P003) inativo |

Também tratado: padronização de códigos de loja com grafia inconsistente (ex.: "001" e " l001" → "L001").

De 192 vendas brutas, 162 ficaram válidas para a apuração.

## 2. Atingimento por loja (sobre as vendas válidas)

| Loja | Meta | Realizado válido | % atingido | Status |
|---|---|---|---|---|
| L001 | R$ 290.900 | R$ 243.293,09 | 84% | APTA · faixa 1,0x |
| L002 | R$ 19.000 | R$ 13.723,16 | 72% | NÃO APTA |
| L003 | R$ 59.000 | R$ 30.211,26 | 51% | NÃO APTA |
| L004 | R$ 33.600 | R$ 40.012,02 | 119% | APTA · faixa 1,2x |
| L005 | R$ 100.100 | R$ 49.944,78 | 50% | NÃO APTA |
| L006 | R$ 21.000 | R$ 30.161,58 | 144% | APTA · faixa 1,5x |
| L007 | R$ 33.600 | R$ 43.696,36 | 130% | APTA · faixa 1,5x |
| L008 | R$ 25.200 | R$ 21.860,11 | 87% | APTA · faixa 1,0x |

## 3. Prêmio por participante

| Participante | Loja | Vendido válido | Faixa | Prêmio |
|---|---|---|---|---|
| Carlos Souza | L001 | 227.809,04 | 1,0x | R$ 4.556,18 |
| Larissa Barbosa | L007 | 25.331,04 | 1,5x | R$ 759,93 |
| Bruno Araújo | L007 | 18.365,32 | 1,5x | R$ 550,96 |
| Patrícia Almeida | L004 | 20.693,98 | 1,2x | R$ 496,66 |
| Lucas Ferreira | L004 | 19.318,04 | 1,2x | R$ 463,63 |
| Camila Martins* | L006 | 14.931,58 | 1,5x | R$ 447,95 |
| Mariana Lima | L001 | 15.484,05 | 1,0x | R$ 309,68 |
| Renata Dias | L008 | 14.989,23 | 1,0x | R$ 299,78 |
| Thiago Rocha | L008 | 6.870,88 | 1,0x | R$ 137,42 |
| Roberto Oliveira | L003 | 16.913,69 | — | R$ 0,00 (loja não bateu o gatilho) |
| Fernanda Santos | L003 | 13.297,57 | — | R$ 0,00 (loja não bateu o gatilho) |
| Diego Ribeiro | L005 | 20.495,04 | — | R$ 0,00 (loja não bateu o gatilho) |
| Juliana Carvalho | L005 | 29.449,74 | — | R$ 0,00 (loja não bateu o gatilho) |
| Ana Costa | L002 | 13.723,16 | — | R$ 0,00 (loja não bateu o gatilho) |

**Total pago: R$ 8.022,19.** Ninguém atingiu o teto de R$ 5.000 neste ciclo.

\* O valor de Camila Martins já exclui a venda-outlier de R$ 15.230,00 (V0177) — decisão por julgamento, não por regra escrita do regulamento. Ver seção 1. Se essa venda for confirmada como válida pelo cliente, o prêmio dela sobe para R$ 904,85 e o total pago para R$ 8.479,09.

## 4. Reconciliação

Apurado em Excel (fórmulas + Power Query) e em SQL (`apuracao.sql`), de forma independente. Os dois bateram em todos os participantes, sem divergência.

## Decisão de auditoria

Roberto Oliveira, Fernanda Santos, Diego Ribeiro, Juliana Carvalho e Ana Costa venderam de forma válida (R$ 16.913,69, R$ 13.297,57, R$ 20.495,04, R$ 29.449,74 e R$ 13.723,16, respectivamente), mas não recebem prêmio porque as lojas deles — L003 (51% da meta), L005 (50% da meta) e L002 (72% da meta) — não atingiram o gatilho de 80%. Isso é esperado pela regra do gatilho, não é erro de cálculo.

O caso de Ana Costa só ficou correto depois de excluir as duas ocorrências da nota fiscal duplicada NF100041 (V0015 e V0132): mantendo só uma delas, a loja L002 parecia ter atingido 82% da meta e ela receberia R$ 311,78 indevidamente.

## Estrutura do repositório

```
├── README.md
├── dados/
│   ├── lojas.csv
│   ├── participantes.csv
│   └── vendas.csv
├── regulamento.md
├── apuracao.sql
└── Apuracao_Campanha_Giro_Certo.xlsx
```
