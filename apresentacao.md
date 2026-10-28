# Análise dos dados — CantuStore

## Objetivo geral

Explorar os arquivos recebidos para identificar padrões na atividade de carrinhos e itens, avaliar a qualidade dos dados e apresentar achados que possam orientar análises futuras. Os registros de carrinho não serão tratados como vendas concluídas sem evidência que confirme essa interpretação.

## Método

Os arquivos de origem em CSV e Parquet foram consultados localmente com DuckDB, e as transformações foram modeladas com dbt. Após o tratamento na camada Silver, a OBT foi construída a partir dos itens de carrinho, mantendo uma linha por item e enriquecendo os registros com LEFT JOINs. Comparei a quantidade de linhas e a unicidade das PKs entre cartentries e obt_cartentries. As tabelas Gold resumem a atividade por mês e produto, o perfil dos carrinhos e as ocorrências de qualidade dos dados.

## Objetivo da camada Silver

Manter um modelo tratado para cada conjunto de origem, preservando seus registros e tornando os campos mais consistentes para consulta. Os modelos padronizam nomes e valores textuais selecionados, sinalizam chaves duplicadas e registram correções aplicadas.

Em `carts`, o CEP foi mantido como texto, o sufixo `.0` foi removido quando aplicável, e CEPs de sete dígitos receberam zero à esquerda. As linhas repetidas por PK ficaram idênticas após essa normalização; a camada mantém uma linha por PK e conserva `source_pk_copies` e `had_duplicate_pk` para auditoria.

## Objetivo da camada Gold

Combinar e organizar os dados para responder perguntas analíticas:

- `obt_cartentries`: uma linha por item de carrinho, com atributos relacionados por `LEFT JOIN`.
- `gold_cart_profile`: perfil dos carrinhos representados na OBT.
- `gold_item_quantity_value`: quantidades e valores observados agrupados por mês, produto, unidade e moeda.
- `gold_product_frequency`: frequência mensal por produto e quantidade de carrinhos distintos associados.
- `gold_data_quality`: contagens de verificações e ocorrências de qualidade.

## Conclusão — principais análises

- **Volume:** os oito conjuntos de dados somam aproximadamente **34,1 milhões de registros**. `carts` tem 16.047.042 linhas na origem; após manter uma linha por PK, a Silver contém 16.035.908. As 11.134 linhas excedentes foram removidas, com a contagem de cópias preservada.
- **CEP e duplicidade:** foram observadas representações distintas do mesmo CEP, como `04207000` e `4207000`. Após normalizar o formato, a comparação integral não encontrou versões diferentes entre as linhas com PK repetida; uma cópia foi mantida por chave.
- **Grão da OBT:** a validação encontrou **2.461.265 linhas** e PKs de item distintas tanto em `cartentries` quanto em `obt_cartentries`. Há **7 itens sem `p_order`** e nenhuma referência preenchida sem carrinho correspondente.
- **Frequência de produtos:** há **5.504 IDs de produto** com linhas registradas. Os três mais frequentes são `8797277388801` (33.785 linhas), `8800160153601` (29.472) e `8797234200577` (29.295). Não há catálogo para traduzir esses IDs em nomes.
- **Variação mensal:** as datas válidas dos itens vão de **dezembro de 2019 a julho de 2022**. Novembro de 2021 teve o maior volume, com **298.786 linhas de item**, seguido por dezembro de 2021 (264.309) e julho de 2022 (251.496).
- **Qualidade dos itens:** foram identificados 3 itens sem produto, 2 sem unidade e 1 sem data de criação válida.
- **Pagamento registrado:** entre 2.110.291 carrinhos com itens representados no perfil, `pix` é o modo mais frequente (1.138.143 registros); 903.304 não têm modo preenchido. Isso descreve o campo registrado, não pagamentos aprovados.
- **Endereços:** a origem contém `nan` como texto em 595.728 CEPs e 7.427.473 códigos IBGE. Esses valores não são NULL e permanecem sentinelas textuais no modelo atual.

## Limitações e interpretação

- Não há catálogo de produtos; análises de frequência usam IDs.
- A tabela de moedas/códigos não está disponível; valores devem ser comparados apenas dentro do mesmo `cart_currency_id`.
- Quantidades devem ser analisadas por `unit_id`; unidades diferentes não devem ser somadas como se fossem equivalentes.
- Os arquivos não confirmam que carrinhos sejam pedidos concluídos. Os resultados não devem ser chamados de vendas, receita, conversão ou abandono.
- Parte das referências e dos atributos de endereço e pagamento está ausente. Os joins preservam essas linhas e a tabela de qualidade registra ocorrências conhecidas.
