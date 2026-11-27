
-- ============================================================================
-- PROJETO PRÁTICO FINAL: PLATAFORMA DE GESTÃO DE EVENTOS E INGRESSOS
-- Arquivo: 03_objetos_prog.sql
-- SGBD: MySQL 8.0+
-- ============================================================================

USE sistema_eventos;

-- ============================================================================
-- 1. VIEWS (Mínimo 2)
-- ============================================================================

-- View 1: Resumo financeiro por evento
DROP VIEW IF EXISTS vw_resumo_financeiro_eventos;
CREATE VIEW vw_resumo_financeiro_eventos AS
SELECT
    e.id_evento,
    e.titulo AS evento,
    o.nome AS organizador,
    COALESCE(SUM(ip.quantidade), 0) AS total_ingressos_vendidos,
    COALESCE(SUM(ip.quantidade * ip.preco), 0.00) AS receita_bruta,
    COALESCE(SUM(ip.quantidade * ip.preco), 0.00) - COALESCE(SUM(p.taxa_servico), 0.00) AS receita_liquida
FROM EVENTO e
JOIN ORGANIZADOR o ON e.id_organizador = o.id_organizador
LEFT JOIN LOTE l ON e.id_evento = l.id_evento
LEFT JOIN ITEM_PEDIDO ip ON l.id_lote = ip.id_lote
LEFT JOIN PEDIDO p ON ip.id_pedido = p.id_pedido AND p.status = 'Pago'
GROUP BY e.id_evento, e.titulo, o.nome;

-- View 2: Detalhamento dos ingressos adquiridos por participante
DROP VIEW IF EXISTS vw_detalhe_ingressos_participante;
CREATE VIEW vw_detalhe_ingressos_participante AS
SELECT
    part.nome AS participante,
    part.cpf,
    e.titulo AS evento,
    l.nome AS lote,
    ip.quantidade,
    ip.preco AS preco_pago,
    p.status AS status_pedido,
    p.data_hora_criacao
FROM PARTICIPANTE part
JOIN PEDIDO p ON part.id_participante = p.id_participante
JOIN ITEM_PEDIDO ip ON p.id_pedido = ip.id_pedido
JOIN LOTE l ON ip.id_lote = l.id_lote
JOIN EVENTO e ON l.id_evento = e.id_evento;

-- ============================================================================
-- 2. FUNCTIONS (Mínimo 2)
-- ============================================================================

DELIMITER //

-- Function 1: Cálculo da taxa de serviço da plataforma (10% até R$ 200,00; 8% acima)
DROP FUNCTION IF EXISTS fn_calcular_taxa_servico//
CREATE FUNCTION fn_calcular_taxa_servico(valor_base DECIMAL(10, 2))
RETURNS DECIMAL(10, 2)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE taxa DECIMAL(10, 2);

    IF valor_base <= 0.00 THEN
        SET taxa = 0.00;
    ELSEIF valor_base <= 200.00 THEN
        SET taxa = ROUND(valor_base * 0.10, 2);
    ELSE
        SET taxa = ROUND(valor_base * 0.08, 2);
    END IF;

    RETURN taxa;
END//

-- Function 2: Percentual de ocupação atual do evento
DROP FUNCTION IF EXISTS fn_lotacao_percentual_evento//
CREATE FUNCTION fn_lotacao_percentual_evento(p_id_event INT)
RETURNS DECIMAL(5, 2)
READS SQL DATA
BEGIN
    DECLARE capacidade INT DEFAULT 0;
    DECLARE vendidos INT DEFAULT 0;
    DECLARE percentual DECIMAL(5, 2) DEFAULT 0.00;

    SELECT loc.capacidade_maxima INTO capacidade
    FROM EVENTO ev
    JOIN LOCAL loc ON ev.id_local = loc.id_local
    WHERE ev.id_evento = p_id_event;

    SELECT COALESCE(SUM(ip.quantidade), 0) INTO vendidos
    FROM LOTE l
    JOIN ITEM_PEDIDO ip ON l.id_lote = ip.id_lote
    JOIN PEDIDO p ON ip.id_pedido = p.id_pedido
    WHERE l.id_evento = p_id_event AND p.status = 'Pago';

    IF capacidade > 0 THEN
        SET percentual = ROUND((vendidos / capacidade) * 100, 2);
    ELSE
        SET percentual = 0.00;
    END IF;

    RETURN percentual;
END//

-- ============================================================================
-- 3. STORED PROCEDURES (Mínimo 2)
-- ============================================================================

-- Procedure 1: Registra item no pedido validando prazo e disponibilidade
DROP PROCEDURE IF EXISTS sp_registrar_item_pedido//
CREATE PROCEDURE sp_registrar_item_pedido(
    IN p_id_pedido INT,
    IN p_id_lote INT,
    IN p_quantidade INT
)
BEGIN
    DECLARE v_status_pedido VARCHAR(30);
    DECLARE v_qtd_atual INT;
    DECLARE v_preco DECIMAL(10, 2);
    DECLARE v_dt_inicio DATETIME;
    DECLARE v_dt_fim DATETIME;
    DECLARE v_soma_total DECIMAL(10, 2);

    IF p_quantidade IS NULL OR p_quantidade <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: A quantidade de ingressos deve ser maior que zero.';
    END IF;

    SELECT status INTO v_status_pedido
    FROM PEDIDO
    WHERE id_pedido = p_id_pedido;

    IF v_status_pedido IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: Pedido não encontrado.';
    ELSEIF v_status_pedido <> 'Pendente' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: Só é permitido adicionar itens a pedidos com status Pendente.';
    END IF;

    SELECT qtd_disponivel_atual, preco_unitario, data_hora_inicio_validade, data_hora_validade
    INTO v_qtd_atual, v_preco, v_dt_inicio, v_dt_fim
    FROM LOTE
    WHERE id_lote = p_id_lote;

    IF v_qtd_atual IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: Lote não encontrado.';
    ELSEIF NOW() < v_dt_inicio OR NOW() > v_dt_fim THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: O lote está fora do período de venda.';
    ELSEIF v_qtd_atual < p_quantidade THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: Quantidade solicitada maior que o estoque disponível no lote.';
    ELSE
        INSERT INTO ITEM_PEDIDO (quantidade, preco, id_pedido, id_lote)
        VALUES (p_quantidade, v_preco, p_id_pedido, p_id_lote);

        SELECT COALESCE(SUM(quantidade * preco), 0.00) INTO v_soma_total
        FROM ITEM_PEDIDO
        WHERE id_pedido = p_id_pedido;

        UPDATE PEDIDO
        SET valor_total_bruto = v_soma_total,
            taxa_servico = fn_calcular_taxa_servico(v_soma_total)
        WHERE id_pedido = p_id_pedido;
    END IF;
END//

-- Procedure 2: Cancela pedido e estorna ingressos ao estoque dos lotes
DROP PROCEDURE IF EXISTS sp_cancelar_pedido//
CREATE PROCEDURE sp_cancelar_pedido(IN p_id_pedido INT)
BEGIN
    DECLARE v_status_atual VARCHAR(30);

    SELECT status INTO v_status_atual
    FROM PEDIDO
    WHERE id_pedido = p_id_pedido;

    IF v_status_atual IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: Pedido não encontrado.';
    ELSEIF v_status_atual IN ('Cancelado', 'Estornado') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: Este pedido já se encontra Cancelado ou Estornado.';
    ELSE
        UPDATE PEDIDO
        SET status = 'Cancelado'
        WHERE id_pedido = p_id_pedido;

        UPDATE LOTE l
        JOIN ITEM_PEDIDO ip ON l.id_lote = ip.id_lote
        SET l.qtd_disponivel_atual = l.qtd_disponivel_atual + ip.quantidade
        WHERE ip.id_pedido = p_id_pedido;
    END IF;
END//

-- ============================================================================
-- 4. TRIGGERS (Mínimo 2)
-- ============================================================================

-- Trigger 1: Subtrai estoque do lote após inserção de item no pedido
DROP TRIGGER IF EXISTS trg_atualizar_estoque_apos_venda//
CREATE TRIGGER trg_atualizar_estoque_apos_venda
AFTER INSERT ON ITEM_PEDIDO
FOR EACH ROW
BEGIN
    UPDATE LOTE
    SET qtd_disponivel_atual = qtd_disponivel_atual - NEW.quantidade
    WHERE id_lote = NEW.id_lote;
END//

-- Trigger 2: Registra histórico de auditoria quando o preço do lote é alterado
DROP TRIGGER IF EXISTS trg_auditoria_preco_lote//
CREATE TRIGGER trg_auditoria_preco_lote
AFTER UPDATE ON LOTE
FOR EACH ROW
BEGIN
    IF OLD.preco_unitario <> NEW.preco_unitario THEN
        INSERT INTO LOG_ALTERACAO_PRECO (
            preco_anterior,
            preco_novo,
            data_hora_alteracao,
            usuario_alteracao,
            id_lote
        )
        VALUES (
            OLD.preco_unitario,
            NEW.preco_unitario,
            NOW(),
            CURRENT_USER(),
            NEW.id_lote
        );
    END IF;
END//

DELIMITER ;

