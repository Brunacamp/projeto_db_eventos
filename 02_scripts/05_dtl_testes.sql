-- ============================================================================
-- PROJETO PRÁTICO FINAL: PLATAFORMA DE GESTÃO DE EVENTOS E INGRESSOS
-- Arquivo: 05_dtl_testes.sql
-- Objetivo: Testes de Transações (DTL), Views, Functions, Procedures e Triggers
-- ============================================================================
USE sistema_eventos;
-- 1. Consulta às Views e Functions criadas
SELECT * FROM vw_resumo_financeiro_eventos;
SELECT * FROM vw_detalhe_ingressos_participante WHERE participante LIKE 'Matheus Nogueira Tavares%';
SELECT
   fn_calcular_taxa_servico(150.00) AS taxa_ate_200,
   fn_calcular_taxa_servico(350.00) AS taxa_acima_200,
   fn_lotacao_percentual_evento(1) AS ocupacao_evento_1_pct;
-- 2. Trigger de Auditoria de Preço (trg_auditoria_preco_lote)
SELECT id_lote, nome, preco_unitario FROM LOTE WHERE id_lote = 14;
UPDATE LOTE SET preco_unitario = 85.00 WHERE id_lote = 14;
SELECT * FROM LOG_ALTERACAO_PRECO WHERE id_lote = 14;
-- 3. Transação com sp_registrar_item_pedido e baixa de estoque
START TRANSACTION;
INSERT INTO PEDIDO (status, id_participante) VALUES ('Pendente', 11);
SET @novo_pedido_id = LAST_INSERT_ID();
SELECT id_lote, nome, qtd_disponivel_atual FROM LOTE WHERE id_lote = 14;
CALL sp_registrar_item_pedido(@novo_pedido_id, 14, 3);
SELECT id_lote, nome, qtd_disponivel_atual FROM LOTE WHERE id_lote = 14;
SELECT * FROM PEDIDO WHERE id_pedido = @novo_pedido_id;
COMMIT;
-- 4. Cancelamento com devolução de estoque (sp_cancelar_pedido)
START TRANSACTION;
CALL sp_cancelar_pedido(@novo_pedido_id);
SELECT id_pedido, status, valor_total_bruto, taxa_servico FROM PEDIDO WHERE id_pedido = @novo_pedido_id;
SELECT id_lote, nome, qtd_disponivel_atual FROM LOTE WHERE id_lote = 14;
COMMIT;
-- 5. Controle de transação com ROLLBACK
START TRANSACTION;
UPDATE PEDIDO SET status = 'Pago' WHERE id_pedido = 6;
INSERT INTO PAGAMENTO (metodo_pagamento, status_pagamento, id_pedido) VALUES ('PIX', 'Confirmado', 6);
SELECT id_pedido, status FROM PEDIDO WHERE id_pedido = 6;
ROLLBACK;
SELECT id_pedido, status FROM PEDIDO WHERE id_pedido = 6;
-- 6. Teste de erro customizado (SIGNAL SQLSTATE)
CALL sp_registrar_item_pedido(6, 14, 9999);
