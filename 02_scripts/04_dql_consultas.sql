
-- ============================================================================
-- PROJETO PRÁTICO FINAL: PLATAFORMA DE GESTÃO DE EVENTOS E INGRESSOS
-- Arquivo: 04_dql_consultas.sql
-- ============================================================================

USE sistema_eventos;

-- ============================================================================
-- CONSULTA 1: Relatório detalhado de ingressos vendidos por participante
-- Requisito: INNER JOIN envolvendo 3 ou mais tabelas (6 tabelas unidas)
-- Objetivo: Listar os participantes com pedidos pagos, exibindo o evento,
--           o local, o lote adquirido e a quantidade de ingressos comprados.
-- ============================================================================
SELECT
    p.nome AS participante,
    p.cpf,
    ped.id_pedido,
    ped.data_hora_criacao,
    ev.titulo AS evento,
    loc.nome AS local_realizacao,
    lt.nome AS lote,
    ip.quantidade,
    ip.preco,
    (ip.quantidade * ip.preco) AS subtotal_item
FROM PARTICIPANTE p
INNER JOIN PEDIDO ped ON p.id_participante = ped.id_participante
INNER JOIN ITEM_PEDIDO ip ON ped.id_pedido = ip.id_pedido
INNER JOIN LOTE lt ON ip.id_lote = lt.id_lote
INNER JOIN EVENTO ev ON lt.id_evento = ev.id_evento
INNER JOIN LOCAL loc ON ev.id_local = loc.id_local
WHERE ped.status = 'Pago'
ORDER BY ped.data_hora_criacao DESC, p.nome ASC;

-- ============================================================================
-- CONSULTA 2: Identificação de participantes cadastrados sem nenhum pedido
-- Requisito: LEFT JOIN para identificar registros sem correspondência
-- Objetivo: Identificar participantes na base que ainda não realizaram
--           nenhum pedido na plataforma.
-- ============================================================================
SELECT
    p.id_participante,
    p.nome,
    p.email,
    p.telefone
FROM PARTICIPANTE p
LEFT JOIN PEDIDO ped ON p.id_participante = ped.id_participante
WHERE ped.id_pedido IS NULL
ORDER BY p.id_participante ASC;

-- ============================================================================
-- CONSULTA 3: Desempenho financeiro e volume de vendas por evento
-- Requisito: Funções de agregação (COUNT, SUM, AVG) com GROUP BY
-- Objetivo: Consolidar o total de pedidos pagos, total de ingressos vendidos,
--           faturamento bruto e ticket médio por evento.
-- ============================================================================
SELECT
    ev.id_evento,
    ev.titulo AS evento,
    ev.categoria,
    COUNT(DISTINCT ped.id_pedido) AS qtd_pedidos_pagos,
    SUM(ip.quantidade) AS total_ingressos_vendidos,
    SUM(ip.quantidade * ip.preco) AS receita_bruta,
    ROUND(AVG(ip.preco), 2) AS preco_medio_ingresso
FROM EVENTO ev
INNER JOIN LOTE lt ON ev.id_evento = lt.id_evento
INNER JOIN ITEM_PEDIDO ip ON lt.id_lote = ip.id_lote
INNER JOIN PEDIDO ped ON ip.id_pedido = ped.id_pedido
WHERE ped.status = 'Pago'
GROUP BY ev.id_evento, ev.titulo, ev.categoria
ORDER BY receita_bruta DESC;

-- ============================================================================
-- CONSULTA 4: Taxa de ocupação dos eventos agendados para o próximo trimestre
-- Requisito: Ordenação (ORDER BY), filtros de data e uso de Function criada
-- Objetivo: Monitorar a lotação percentual dos eventos futuros agendados.
-- ============================================================================
SELECT
    ev.id_evento,
    ev.titulo AS evento,
    org.nome AS organizador,
    loc.nome AS local_realizacao,
    loc.capacidade_maxima,
    ev.data_hora_inicio,
    fn_lotacao_percentual_evento(ev.id_evento) AS percentual_ocupacao
FROM EVENTO ev
INNER JOIN ORGANIZADOR org ON ev.id_organizador = org.id_organizador
INNER JOIN LOCAL loc ON ev.id_local = loc.id_local
WHERE ev.status = 'Agendado'
  AND ev.data_hora_inicio BETWEEN '2026-11-23 00:00:00' AND '2027-02-28 23:59:59'
ORDER BY percentual_ocupacao DESC, ev.data_hora_inicio ASC;

-- ============================================================================
-- CONSULTA 5: Análise de meios de pagamento utilizados nos pedidos liquidados
-- Requisito: Consulta analítica complementar (Agregação + Agrupamento)
-- Objetivo: Avaliar a preferência por método de pagamento nos pedidos pagos.
-- ============================================================================
SELECT
    pag.metodo_pagamento,
    COUNT(pag.id_pagamento) AS quantidade_transacoes,
    ROUND(AVG(ped.valor_total_bruto), 2) AS ticket_medio_bruto,
    MIN(pag.data_hora_confirmacao) AS primeira_confirmacao,
    MAX(pag.data_hora_confirmacao) AS ultima_confirmacao
FROM PAGAMENTO pag
INNER JOIN PEDIDO ped ON pag.id_pedido = ped.id_pedido
WHERE ped.status = 'Pago'
GROUP BY pag.metodo_pagamento
ORDER BY quantidade_transacoes DESC;
