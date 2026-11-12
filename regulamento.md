# Briefing — Apuração Campanha "Giro Certo" (Out/2026)

**De:** Coordenação de Projetos
**Para:** Analista de BI/Dados
**Assunto:** Apuração da campanha de incentivo do cliente — entrega até sexta-feira

Olá! Precisamos da apuração dos resultados da campanha de incentivo **Giro Certo**, que premiou vendedores de ponto de venda ao longo de outubro. O cliente quer saber quanto vai pagar de prêmio, por participante, e precisamos ter certeza de que o valor está certo antes de enviar.

Em anexo você vai receber as bases brutas: `lojas.csv`, `participantes.csv` e `vendas.csv`. Essas bases vêm direto do distribuidor e do nosso cadastro, então **não foram tratadas** — pode haver inconsistência, precisamos que você valide tudo antes de calcular qualquer prêmio.

## Regras da campanha (regulamento assinado com o cliente)

1. **Período válido**: apenas vendas realizadas entre **01/10/2026 e 31/10/2026**, ambos inclusos.
2. **Categoria elegível**: a campanha premia apenas a categoria de produto **"bebida"**. Vendas de outras categorias não contam.
3. **Nota fiscal**: só contam vendas com nota fiscal em status **"aprovada"**. Notas canceladas, duplicadas (mesmo número de NF aparecendo mais de uma vez) não devem ser contabilizadas — nos dois casos em que a duplicidade ocorrer, a nota deve ser excluída da apuração.
4. **Participante elegível**: apenas participantes com status **"ativo"** no cadastro.
5. **Loja elegível (gatilho)**: o participante só recebe prêmio se a **loja onde ele atua** tiver atingido no mínimo **80% da meta de vendas válidas** da loja no período.
6. **Faixas de multiplicador**, aplicadas sobre o valor vendido pelo participante, conforme o percentual de atingimento da meta da loja dele:
   - 80% a 99,99% da meta: multiplicador **1,0x**
   - 100% a 119,99% da meta: multiplicador **1,2x**
   - 120% da meta ou mais: multiplicador **1,5x**
7. **Cálculo do prêmio**: `prêmio = 2% do valor vendido válido pelo participante × multiplicador da faixa da loja`.
8. **Teto por participante**: nenhum participante pode receber mais de **R$ 5.000,00**, mesmo que o cálculo dê um valor maior.

## O que precisamos que você entregue

1. Uma nota curta explicando que inconsistências você encontrou nas bases e como tratou cada uma (ex: o que fez com nota duplicada, com venda fora do período, etc.).
2. A apuração final: valor de prêmio por participante, pronta para conferência.
3. Alguma forma de garantir que o cálculo está certo — se você rodar de duas formas diferentes e bater o resultado, melhor ainda, porque o cliente costuma pedir para "provar" o número quando questiona.

Qualquer dúvida sobre o regulamento, me chama. Não precisa adivinhar regra que não está escrita aqui.
