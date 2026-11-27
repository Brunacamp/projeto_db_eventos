
-- ============================================================================
-- PROJETO PRÁTICO FINAL: PLATAFORMA DE GESTÃO DE EVENTOS E INGRESSOS
-- Arquivo: 01_ddl_estrutura.sql
-- SGBD: MySQL 8.0+
-- ============================================================================

DROP DATABASE IF EXISTS sistema_eventos;
CREATE DATABASE sistema_eventos
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sistema_eventos;

-- 1. Tabela ORGANIZADOR
CREATE TABLE ORGANIZADOR (
    id_organizador INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    tipo VARCHAR(35) NOT NULL,
    contato VARCHAR(50),
    cpf_cnpj VARCHAR(18) NOT NULL,
    CONSTRAINT uq_organizador_cpf_cnpj UNIQUE (cpf_cnpj)
) ENGINE=InnoDB;

-- 2. Tabela LOCAL
CREATE TABLE LOCAL (
    id_local INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    endereco_completo VARCHAR(100) NOT NULL,
    capacidade_maxima INT NOT NULL,
    CONSTRAINT chk_local_capacidade CHECK (capacidade_maxima > 0)
) ENGINE=InnoDB;

-- 3. Tabela EVENTO
CREATE TABLE EVENTO (
    id_evento INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(50) NOT NULL,
    descricao VARCHAR(35),
    categoria VARCHAR(15) NOT NULL,
    data_hora_inicio DATETIME NOT NULL,
    data_hora_fim DATETIME NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Agendado',
    id_organizador INT NOT NULL,
    id_local INT NOT NULL,
    CONSTRAINT fk_evento_organizador FOREIGN KEY (id_organizador)
        REFERENCES ORGANIZADOR(id_organizador) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_evento_local FOREIGN KEY (id_local)
        REFERENCES LOCAL(id_local) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_evento_datas CHECK (data_hora_fim > data_hora_inicio),
    CONSTRAINT chk_evento_status CHECK (status IN ('Agendado', 'Em Andamento', 'Encerrado', 'Cancelado'))
) ENGINE=InnoDB;

-- 4. Tabela LOTE
CREATE TABLE LOTE (
    id_lote INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    preco_unitario DECIMAL(10, 2) NOT NULL,
    qtd_total_disponivel INT NOT NULL,
    qtd_disponivel_atual INT NOT NULL,
    data_hora_inicio_validade DATETIME NOT NULL,
    data_hora_validade DATETIME NOT NULL,
    id_evento INT NOT NULL,
    CONSTRAINT fk_lote_evento FOREIGN KEY (id_evento)
        REFERENCES EVENTO(id_evento) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_lote_preco CHECK (preco_unitario >= 0.00),
    CONSTRAINT chk_lote_qtd_total CHECK (qtd_total_disponivel > 0),
    CONSTRAINT chk_lote_qtd_disponivel CHECK (qtd_disponivel_atual >= 0 AND qtd_disponivel_atual <= qtd_total_disponivel),
    CONSTRAINT chk_lote_validade CHECK (data_hora_validade > data_hora_inicio_validade)
) ENGINE=InnoDB;

-- 5. Tabela PARTICIPANTE
CREATE TABLE PARTICIPANTE (
    id_participante INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    cpf VARCHAR(14) NOT NULL,
    email VARCHAR(50) NOT NULL,
    telefone VARCHAR(15),
    CONSTRAINT uq_participante_cpf UNIQUE (cpf),
    CONSTRAINT uq_participante_email UNIQUE (email)
) ENGINE=InnoDB;

-- 6. Tabela PEDIDO
CREATE TABLE PEDIDO (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    data_hora_criacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'Pendente',
    taxa_servico DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    valor_total_bruto DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    id_participante INT NOT NULL,
    CONSTRAINT fk_pedido_participante FOREIGN KEY (id_participante)
        REFERENCES PARTICIPANTE(id_participante) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_pedido_status CHECK (status IN ('Pendente', 'Pago', 'Cancelado', 'Estornado')),
    CONSTRAINT chk_pedido_valores CHECK (valor_total_bruto >= 0.00 AND taxa_servico >= 0.00)
) ENGINE=InnoDB;

-- 7. Tabela ITEM_PEDIDO
CREATE TABLE ITEM_PEDIDO (
    id_item_pedido INT AUTO_INCREMENT PRIMARY KEY,
    quantidade INT NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    id_pedido INT NOT NULL,
    id_lote INT NOT NULL,
    CONSTRAINT fk_item_pedido FOREIGN KEY (id_pedido)
        REFERENCES PEDIDO(id_pedido) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_item_lote FOREIGN KEY (id_lote)
        REFERENCES LOTE(id_lote) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_pedido_lote UNIQUE (id_pedido, id_lote),
    CONSTRAINT chk_item_quantidade CHECK (quantidade > 0),
    CONSTRAINT chk_item_preco CHECK (preco >= 0.00)
) ENGINE=InnoDB;

-- 8. Tabela PAGAMENTO
CREATE TABLE PAGAMENTO (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    metodo_pagamento VARCHAR(30) NOT NULL,
    data_hora_confirmacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_pagamento VARCHAR(30) NOT NULL DEFAULT 'Confirmado',
    id_pedido INT NOT NULL UNIQUE,
    CONSTRAINT fk_pagamento_pedido FOREIGN KEY (id_pedido)
        REFERENCES PEDIDO(id_pedido) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_pagamento_metodo CHECK (metodo_pagamento IN ('PIX', 'Cartão de Crédito', 'Boleto'))
) ENGINE=InnoDB;

-- 9. Tabela LOG_ALTERACAO_PRECO
CREATE TABLE LOG_ALTERACAO_PRECO (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    preco_anterior DECIMAL(10, 2) NOT NULL,
    preco_novo DECIMAL(10, 2) NOT NULL,
    data_hora_alteracao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_alteracao VARCHAR(50) NOT NULL,
    id_lote INT NOT NULL,
    CONSTRAINT fk_log_lote FOREIGN KEY (id_lote)
        REFERENCES LOTE(id_lote) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================================
-- ÍNDICES SECUNDÁRIOS
-- ============================================================================
CREATE INDEX idx_evento_data_status ON EVENTO (data_hora_inicio, status);
CREATE INDEX idx_pedido_participante ON PEDIDO (id_participante);
CREATE INDEX idx_pedido_status_data ON PEDIDO (status, data_hora_criacao);
