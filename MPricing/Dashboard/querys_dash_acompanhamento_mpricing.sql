USE MPRICING

DECLARE @DTINICIO DATE 
DECLARE @DTFIM DATE
DECLARE @CANAL NVARCHAR(10)
DECLARE @ZONA NVARCHAR(10)
DECLARE @ORCINICIO NVARCHAR(10) 
DECLARE @ORCFIM NVARCHAR(10)


SET @DTINICIO = '2023-04-01' 
SET @DTFIM = '2023-04-30'
SET @CANAL = '41'
SET @ZONA = '57, 64'
SET @ORCINICIO = CONVERT(INT, CONVERT(NVARCHAR(6), SUBSTRING(CONVERT(NVARCHAR(10),@DTINICIO), 0, 5) + SUBSTRING(CONVERT(NVARCHAR(10),@DTINICIO), 6, 2)))
SET @ORCFIM = CONVERT( INT, CONVERT(NVARCHAR(6), SUBSTRING(CONVERT(NVARCHAR(10),@DTFIM), 0, 5) + SUBSTRING(CONVERT(NVARCHAR(10),@DTFIM), 6, 2)))



---------- VOLUME REALIZADO ----------------
SELECT 
	SUM(V.QTD_FATURADA) VOLUME_REALIZADO
FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_VENDAS (NOLOCK) V INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON V.COD_CLIENTE = C.CD_CLIENTE AND V.COD_CANAL = C.CD_CANAL_VENDA 
WHERE 
	V.DATAEMISSÃONF BETWEEN @DTINICIO AND @DTFIM  AND V.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))


---------- VOLUME ORÇADO ----------------
SELECT 
	SUM(O.QUANTIDADE) VOLUME_ORCADO
FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_ORCAMENTO (NOLOCK) O INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON O.COD_CLIENTE = C.CD_CLIENTE AND O.COD_CANAL = C.CD_CANAL_VENDA 
WHERE 
	O.PERIODO BETWEEN @ORCINICIO AND @ORCFIM  AND O.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
	AND O.VERSAO = 'ORÇADO' AND CENARIO = 'CENÁRIO 2'


---------- RECEITA REALIZADA ----------------
SELECT 
	SUM(V.RECEITALIQUIDA) RECEITA_LIQUIDA_REALIZADO_REAIS
FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_VENDAS (NOLOCK) V INNER JOIN VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON V.COD_CLIENTE = C.CD_CLIENTE AND V.COD_CANAL = C.CD_CANAL_VENDA 
WHERE 
	V.DATAEMISSÃONF BETWEEN @DTINICIO AND @DTFIM  AND V.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) 
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))

---------- RECEITA ORÇADO ----------------
SELECT 
	SUM(O.RECEITA_LIQUIDA) RECEITA_LIQUIDA_ORCADO_REAIS
FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_ORCAMENTO (NOLOCK) O INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON O.COD_CLIENTE = C.CD_CLIENTE AND O.COD_CANAL = C.CD_CANAL_VENDA 
WHERE 
	O.PERIODO BETWEEN @ORCINICIO AND @ORCFIM  AND O.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
	AND O.VERSAO = 'ORÇADO' AND CENARIO = 'CENÁRIO 2'


---------- RECEITA ORÇADA E REALIZADA DOLAR----------------
SELECT 
	SUM(V.RECEITALIQUIDA / V.TX_DOLAR) RECEITA_LIQUIDA_REALIZADO_DOLAR, SUM(O.RECEITA_LIQUIDA / V.TX_DOLAR) RECEITA_LIQUIDA_ORCADO_DOLAR
FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_VENDAS (NOLOCK) V INNER JOIN VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON V.COD_CLIENTE = C.CD_CLIENTE AND V.COD_CANAL = C.CD_CANAL_VENDA 
	INNER JOIN	PROJETO_BI_REVITALIZA.DBO.FATO_ORCAMENTO (NOLOCK) O ON V.COD_CLIENTE = O.COD_CLIENTE AND V.COD_CANAL = O.COD_CANAL 
WHERE 
	V.DATAEMISSÃONF BETWEEN @DTINICIO AND @DTFIM  AND V.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) 
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
	AND O.VERSAO = 'ORÇADO' AND O.CENARIO = 'CENÁRIO 2'


---------- MARGEM LIQUIDA REALIZADO ----------------
SELECT 
	SUM(V.VL_MARGEM_TOTAL_COM_ENCARGO) MARGEM_LIQUIDA_REALIZADO_REAIS
FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_VENDAS (NOLOCK) V INNER JOIN VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON V.COD_CLIENTE = C.CD_CLIENTE AND V.COD_CANAL = C.CD_CANAL_VENDA 
WHERE 
	V.DATAEMISSÃONF BETWEEN @DTINICIO AND @DTFIM  AND V.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) 
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))



---------- MARGEM LIQUIDA ORÇADO ----------------
SELECT 
	SUM(O.LUCRO_BRUTO_SEM_DESPESASVENDAS) MARGEM_LIQUIDA_ORCADO_REAIS
FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_ORCAMENTO (NOLOCK) O INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON O.COD_CLIENTE = C.CD_CLIENTE AND O.COD_CANAL = C.CD_CANAL_VENDA 
WHERE 
	O.PERIODO BETWEEN @ORCINICIO AND @ORCFIM  AND O.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
	AND O.VERSAO = 'ORÇADO' AND CENARIO = 'CENÁRIO 2'

------- PRAZO DE PAGAMENTO -----------------------

SELECT 
	YEAR(V.DATAEMISSÃONF) AS ANO, AVG(V.VALORPRECOUNITARIOANTERIOR) PRAZO_PAGAMENTO
FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_VENDAS (NOLOCK) V INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON V.COD_CLIENTE = C.CD_CLIENTE AND V.COD_CANAL = C.CD_CANAL_VENDA 
WHERE 
	(V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -1, @DTINICIO) AND DATEADD(YEAR, -1, @DTFIM) OR
	 V.DATAEMISSÃONF BETWEEN @DTINICIO AND @DTFIM) AND V.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
GROUP BY YEAR(V.DATAEMISSÃONF)


------- CLIENTE -----------------------


SELECT 
	YEAR(V.DATAEMISSÃONF) AS ANO, COUNT(DISTINCT COD_CLIENTE) CLIENTES
FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_VENDAS (NOLOCK) V INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON V.COD_CLIENTE = C.CD_CLIENTE AND V.COD_CANAL = C.CD_CANAL_VENDA 
WHERE 
	(V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -1, @DTINICIO) AND DATEADD(YEAR, -1, @DTFIM) OR
	 V.DATAEMISSÃONF BETWEEN @DTINICIO AND @DTFIM) AND V.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
GROUP BY YEAR(V.DATAEMISSÃONF)


------- COTAÇÃO -----------------------

SELECT 
	YEAR(P.DATA_ULTIMO_CALCULO) AS ANO, COUNT(P.PDW_N_NUMPEDIDOWEB) COTACAO
FROM 
	PRICING.DBO.SF_PEDWEB (NOLOCK) P INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON P.PDW_N_CODIGOEMITENTE = C.CD_CLIENTE AND P.PDW_N_CODIGOCANALVENDA = C.CD_CANAL_VENDA 
WHERE 
	(P.DATA_ULTIMO_CALCULO BETWEEN DATEADD(YEAR, -1, @DTINICIO) AND DATEADD(YEAR, -1, @DTFIM) OR
	 P.DATA_ULTIMO_CALCULO BETWEEN @DTINICIO AND @DTFIM) AND P.PDW_N_CODIGOCANALVENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
GROUP BY YEAR(P.DATA_ULTIMO_CALCULO)



------- PEDIDOS -----------------------

SELECT 
	YEAR(P.DATA_ULTIMO_CALCULO) AS ANO, COUNT(V.PDV_N_NUMPEDIDO) PEDIDO
FROM 
	PRICING.DBO.SF_PEDWEB (NOLOCK) P INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON P.PDW_N_CODIGOEMITENTE = C.CD_CLIENTE AND P.PDW_N_CODIGOCANALVENDA = C.CD_CANAL_VENDA INNER JOIN
	PRICING.DBO.SF_PED_VENDA (NOLOCK) V ON P.PDW_N_NUMPEDIDOWEB = V.PDV_N_NUMPEDIDOWEB
WHERE 
	(P.DATA_ULTIMO_CALCULO BETWEEN DATEADD(YEAR, -1, @DTINICIO) AND DATEADD(YEAR, -1, @DTFIM) OR
	 P.DATA_ULTIMO_CALCULO BETWEEN @DTINICIO AND @DTFIM) AND P.PDW_N_CODIGOCANALVENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
GROUP BY YEAR(P.DATA_ULTIMO_CALCULO)


------- PERDAS REGISTRADAS -----------------------

SELECT 
	YEAR(P.DATA_ARQUIVO) AS ANO, COUNT(P.PDW_N_NUMPEDIDOWEB) PERDAS_REGISTRADAS
FROM 
	PRICING.DBO.SF_PEDWEB (NOLOCK) P INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON P.PDW_N_CODIGOEMITENTE = C.CD_CLIENTE AND P.PDW_N_CODIGOCANALVENDA = C.CD_CANAL_VENDA
WHERE 
	(P.DATA_ARQUIVO BETWEEN DATEADD(YEAR, -1, @DTINICIO) AND DATEADD(YEAR, -1, @DTFIM) OR
	 P.DATA_ARQUIVO BETWEEN @DTINICIO AND @DTFIM) AND P.PDW_N_CODIGOCANALVENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
	AND P.DATA_ARQUIVO IS NOT NULL
GROUP BY YEAR(P.DATA_ARQUIVO)



------- PEDIDOS EM CARTEIRA -----------------------

SELECT 
	SUM(I.PDI_N_QTD_PEDIDA) AS VOLUME, SUM(I.PDI_N_VALOR_TOTAL_ITEM) RECEITA
FROM 
	PRICING.DBO.SF_PED_VENDA (NOLOCK) V INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON V.PDV_N_CODIGOEMITENTE = C.CD_CLIENTE AND V.PDV_N_CODIGOCANALVENDA = C.CD_CANAL_VENDA INNER JOIN
	PRICING.DBO.SF_PED_ITEM I ON V.PDV_N_NUMPEDIDO = I.PDI_N_NUMPEDIDO AND I.PDI_N_CODIGOEMPRESA = 1 LEFT JOIN
	PRICING.DBO.SF_NOTAFISCAL N ON V.PDV_N_NUMPEDIDO = N.NFL_N_NUMPEDIDO AND N.NFL_N_CODIGOEMPRESA = 1
WHERE 
	N.NFL_C_NUMNOTAFICAL IS NULL
	AND V.PDV_D_DATA_CANCELAMENTO IS NULL
	AND V.PDV_N_CODIGOCANALVENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))



------- ESPECIALIDADES -----------------------

SELECT TOP 3
	P.NOMEPRODUTOITEM AS ESPECIALIDADE, SUM(V.RECEITALIQUIDA) RECEITA,
	(SUM(V.RECEITALIQUIDA) / SUM(SUM(V.RECEITALIQUIDA)) OVER()) * 100 AS PERCENTUAL
FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_VENDAS (NOLOCK) V INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON V.COD_CLIENTE = C.CD_CLIENTE AND V.COD_CANAL = C.CD_CANAL_VENDA INNER JOIN
	PROJETO_BI_REVITALIZA.DBO.DIM_PRODUTO P ON V.COD_PRODUTO = P.COD_PRODUTO
WHERE 
	 V.DATAEMISSÃONF BETWEEN @DTINICIO AND @DTFIM AND V.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
GROUP BY P.COD_PRODUTO, P.NOMEPRODUTOITEM
ORDER BY PERCENTUAL DESC


------- DEPENDENCIA -----------------------

SELECT TOP 3
	P.NOMECLIENTE AS DEPENDENCIA, SUM(V.RECEITALIQUIDA) RECEITA,
	(SUM(V.RECEITALIQUIDA) / SUM(SUM(V.RECEITALIQUIDA)) OVER()) * 100 AS PERCENTUAL
FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_VENDAS (NOLOCK) V INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON V.COD_CLIENTE = C.CD_CLIENTE AND V.COD_CANAL = C.CD_CANAL_VENDA INNER JOIN
	PROJETO_BI_REVITALIZA.DBO.DIM_CLIENTE P ON V.COD_CLIENTE = P.COD_CLIENTE
WHERE 
	 V.DATAEMISSÃONF BETWEEN @DTINICIO AND @DTFIM AND V.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
GROUP BY P.COD_CLIENTE, P.NOMECLIENTE
ORDER BY PERCENTUAL DESC



------- RECORD CLIENTES -----------------------

SELECT TOP 1 YEAR(V.DATAEMISSÃONF) AS ANO, COUNT(DISTINCT COD_CLIENTE) AS RECORDE_CLIENTES, 
	(AVG(COUNT(DISTINCT COD_CLIENTE)) OVER()) AS MEDIA
FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_VENDAS (NOLOCK) V INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON V.COD_CLIENTE = C.CD_CLIENTE AND V.COD_CANAL = C.CD_CANAL_VENDA 
WHERE 
   (V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -1, @DTINICIO) AND DATEADD(YEAR, -1, @DTFIM) OR
    V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -2, @DTINICIO) AND DATEADD(YEAR, -2, @DTFIM) OR
	V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -3, @DTINICIO) AND DATEADD(YEAR, -3, @DTFIM) OR
	V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -4, @DTINICIO) AND DATEADD(YEAR, -4, @DTFIM) OR
	V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -4, @DTINICIO) AND DATEADD(YEAR, -5, @DTFIM) OR
	V.DATAEMISSÃONF BETWEEN @DTINICIO AND @DTFIM) AND
	V.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
GROUP BY YEAR(V.DATAEMISSÃONF)
ORDER BY RECORDE_CLIENTES DESC


------- RECORD PEDIDOS -----------------------

SELECT TOP 1 YEAR(V.DATAEMISSÃONF) AS ANO, COUNT(DISTINCT V.NUMERONOTA) AS RECORDE_PEDIDOS, 
	(AVG(COUNT(DISTINCT V.NUMERONOTA)) OVER()) AS MEDIA
FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_VENDAS (NOLOCK) V INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON V.COD_CLIENTE = C.CD_CLIENTE AND V.COD_CANAL = C.CD_CANAL_VENDA 
WHERE 
   (V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -1, @DTINICIO) AND DATEADD(YEAR, -1, @DTFIM) OR
    V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -2, @DTINICIO) AND DATEADD(YEAR, -2, @DTFIM) OR
	V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -3, @DTINICIO) AND DATEADD(YEAR, -3, @DTFIM) OR
	V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -4, @DTINICIO) AND DATEADD(YEAR, -4, @DTFIM) OR
	V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -4, @DTINICIO) AND DATEADD(YEAR, -5, @DTFIM) OR
	V.DATAEMISSÃONF BETWEEN @DTINICIO AND @DTFIM) AND
	V.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
GROUP BY YEAR(V.DATAEMISSÃONF)
ORDER BY RECORDE_PEDIDOS DESC

------- RECORD VOLUME -----------------------

SELECT TOP 1 YEAR(V.DATAEMISSÃONF) AS ANO, SUM(V.QTD_FATURADA) AS RECORDE_VOLUME, 
	(AVG(SUM(V.QTD_FATURADA)) OVER()) AS MEDIA
FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_VENDAS (NOLOCK) V INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON V.COD_CLIENTE = C.CD_CLIENTE AND V.COD_CANAL = C.CD_CANAL_VENDA 
WHERE 
   (V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -1, @DTINICIO) AND DATEADD(YEAR, -1, @DTFIM) OR
    V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -2, @DTINICIO) AND DATEADD(YEAR, -2, @DTFIM) OR
	V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -3, @DTINICIO) AND DATEADD(YEAR, -3, @DTFIM) OR
	V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -4, @DTINICIO) AND DATEADD(YEAR, -4, @DTFIM) OR
	V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -4, @DTINICIO) AND DATEADD(YEAR, -5, @DTFIM) OR
	V.DATAEMISSÃONF BETWEEN @DTINICIO AND @DTFIM) AND
	V.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
GROUP BY YEAR(V.DATAEMISSÃONF)
ORDER BY RECORDE_VOLUME DESC

------- RECORD VOLUME -----------------------

SELECT TOP 1 YEAR(V.DATAEMISSÃONF) AS ANO, SUM(V.RECEITALIQUIDA) AS RECORDE_RECEITA, 
	(AVG(SUM(V.RECEITALIQUIDA)) OVER()) AS MEDIA
FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_VENDAS (NOLOCK) V INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON V.COD_CLIENTE = C.CD_CLIENTE AND V.COD_CANAL = C.CD_CANAL_VENDA 
WHERE 
   (V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -1, @DTINICIO) AND DATEADD(YEAR, -1, @DTFIM) OR
    V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -2, @DTINICIO) AND DATEADD(YEAR, -2, @DTFIM) OR
	V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -3, @DTINICIO) AND DATEADD(YEAR, -3, @DTFIM) OR
	V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -4, @DTINICIO) AND DATEADD(YEAR, -4, @DTFIM) OR
	V.DATAEMISSÃONF BETWEEN DATEADD(YEAR, -4, @DTINICIO) AND DATEADD(YEAR, -5, @DTFIM) OR
	V.DATAEMISSÃONF BETWEEN @DTINICIO AND @DTFIM) AND
	V.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
GROUP BY YEAR(V.DATAEMISSÃONF)
ORDER BY RECORDE_RECEITA DESC
 
------- MEDIA MOVEL VOLUME REALIZADO ---------------------

SELECT 
	YEAR(V.DATAEMISSÃONF) ANO, MONTH(V.DATAEMISSÃONF) MES, SUM(V.QTD_FATURADA) VOLUME_REALIZADO, 
	(AVG(SUM(V.QTD_FATURADA)) OVER(ORDER BY YEAR(V.DATAEMISSÃONF), MONTH(V.DATAEMISSÃONF) ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)) AS MEDIA_MOVEL

FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_VENDAS (NOLOCK) V INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON V.COD_CLIENTE = C.CD_CLIENTE AND V.COD_CANAL = C.CD_CANAL_VENDA 
WHERE 
	V.DATAEMISSÃONF BETWEEN @DTINICIO AND @DTFIM  AND V.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ','))
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
GROUP BY YEAR(V.DATAEMISSÃONF), MONTH(V.DATAEMISSÃONF)
ORDER BY ANO, MES

------- MEDIA MOVEL RECEITA_LIQUIDA_REALIZADO_REAIS ---------------------

SELECT 
	YEAR(V.DATAEMISSÃONF) ANO, MONTH(V.DATAEMISSÃONF) MES, 	SUM(V.RECEITALIQUIDA) RECEITA_LIQUIDA_REALIZADO_REAIS, 
	(AVG (SUM(V.RECEITALIQUIDA)) OVER(ORDER BY YEAR(V.DATAEMISSÃONF), MONTH(V.DATAEMISSÃONF) ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)) AS MEDIA_MOVEL
FROM 
	PROJETO_BI_REVITALIZA.DBO.FATO_VENDAS (NOLOCK) V INNER JOIN 
	VW_CLI_REP_ZONA_CANAL (NOLOCK) C ON V.COD_CLIENTE = C.CD_CLIENTE AND V.COD_CANAL = C.CD_CANAL_VENDA 
WHERE 
	V.DATAEMISSÃONF BETWEEN @DTINICIO AND @DTFIM  AND V.COD_CANAL IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) 
	AND C.CD_CANAL_VENDA IN (SELECT * FROM STRING_SPLIT(@CANAL, ',')) AND C.CD_ZONA_VENDA IN (SELECT * FROM STRING_SPLIT(@ZONA, ','))
GROUP BY YEAR(V.DATAEMISSÃONF), MONTH(V.DATAEMISSÃONF)
ORDER BY ANO, MES