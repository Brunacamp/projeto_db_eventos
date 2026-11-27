
-- ============================================================================
-- PROJETO PRÁTICO FINAL: PLATAFORMA DE GESTÃO DE EVENTOS E INGRESSOS
-- Arquivo: 02_dml_carga.sql
-- SGBD: MySQL 8.0+
-- ============================================================================

USE sistema_eventos;

-- 1. ORGANIZADOR (5 registros)
INSERT INTO ORGANIZADOR (nome, tipo, contato, cpf_cnpj) VALUES
('Serra do Itapeti Produções', 'PJ', 'contato@serraitapeti.com.br', '27.481.930/0001-42'),
('Núcleo Paulista de TI', 'PJ', 'eventos@nucleopaulista.org', '39.104.852/0001-76'),
('Renata Vasconcelos', 'PF', 'renata@curadoria.art.br', '418.920.376-15'),
('Liga Metropolitana Esportes', 'PJ', 'inscricoes@ligametrop.br', '58.291.044/0001-19'),
('Henrique Bastos', 'PF', 'henrique@hbtreinamentos.com', '629.184.053-88');

-- 2. LOCAL (5 registros)
INSERT INTO LOCAL (nome, endereco_completo, capacidade_maxima) VALUES
('Pavilhão Pró-Hiper', 'Av. Pref. Carlos Ferreira Lopes, 540 - Mogilar', 2500),
('Anfiteatro Biblioteca Municipal', 'Rua Coronel Souza Franco, 993 - Centro', 220),
('Centro Esportivo Heliópolis', 'Av. Amazonas, 780 - Vila Industrial', 1800),
('Auditório Parque Centenário', 'Av. Francisco Rodrigues Filho, 3500 - César', 600),
('Espaço Casarão do Carmo', 'Rua José Bonifácio, 516 - Centro', 300);

-- 3. EVENTO (10 registros - respeitando descricao <= 35 caracteres e data_hora_fim > data_hora_inicio)
INSERT INTO EVENTO (titulo, descricao, categoria, data_hora_inicio, data_hora_fim, status, id_organizador, id_local) VALUES
('Noite do Samba de Raiz', 'Grupos regionais e convidados.', 'Show', '2026-12-11 19:00:00', '2026-12-12 01:30:00', 'Agendado', 1, 1),
('Conferência Cloud e DevOps', 'Containers, observabilidade e SRE.', 'Congresso', '2026-12-03 08:30:00', '2026-12-03 18:00:00', 'Agendado', 2, 4),
('Mostra de Teatro Contemporâneo', 'Espetáculo cênico autoral.', 'Teatro', '2026-12-19 20:00:00', '2026-12-19 22:15:00', 'Agendado', 3, 5),
('Copa Mogi de Vôlei Semifinais', 'Partidas decisivas da liga.', 'Esporte', '2026-12-13 15:00:00', '2026-12-13 20:00:00', 'Agendado', 4, 3),
('Imersão Modelagem e SQL', 'Oficina prática de banco de dados.', 'Workshop', '2027-01-23 09:00:00', '2027-01-23 17:00:00', 'Agendado', 5, 2),
('Festival Jazz na Serra', 'Shows instrumentais e gastronomia.', 'Show', '2026-10-17 15:00:00', '2026-10-17 23:00:00', 'Encerrado', 1, 1),
('Talk IA Aplicada a Negócios', 'Automação e análise preditiva.', 'Palestra', '2026-10-29 19:00:00', '2026-10-29 21:30:00', 'Encerrado', 2, 2),
('Sarau Poético e Acústico', 'Leitura de obras e violão ao vivo.', 'Teatro', '2027-02-06 19:30:00', '2027-02-06 22:00:00', 'Agendado', 3, 5),
('Desafio Regional de Judô', 'Competição cancelada.', 'Esporte', '2026-11-08 09:00:00', '2026-11-08 16:00:00', 'Cancelado', 4, 3),
('Fórum de Governança de TI', 'Conformidade digital e auditoria.', 'Palestra', '2027-02-20 13:30:00', '2027-02-20 18:30:00', 'Agendado', 5, 4);

-- 4. LOTE (14 registros)
INSERT INTO LOTE (nome, preco_unitario, qtd_total_disponivel, qtd_disponivel_atual, data_hora_inicio_validade, data_hora_validade, id_evento) VALUES
('1º Lote - Pista Geral', 65.00, 1800, 1796, '2026-10-10 00:00:00', '2026-12-10 23:59:59', 1),
('Área Mesa Bistrô', 140.00, 500, 497, '2026-10-10 00:00:00', '2026-12-10 23:59:59', 1),
('Ingresso Acadêmico', 45.00, 250, 247, '2026-10-20 00:00:00', '2026-12-02 23:59:59', 2),
('Ingresso Corporativo', 110.00, 300, 298, '2026-10-20 00:00:00', '2026-12-02 23:59:59', 2),
('Plateia Inferior', 55.00, 180, 178, '2026-11-01 00:00:00', '2026-12-19 18:00:00', 3),
('Galeria Superior', 35.00, 100, 98, '2026-11-01 00:00:00', '2026-12-19 18:00:00', 3),
('Arquibancada Azul', 25.00, 1500, 1495, '2026-11-02 00:00:00', '2026-12-13 13:00:00', 4),
('Vaga Prática SQL', 160.00, 180, 178, '2026-11-10 00:00:00', '2027-01-22 23:59:59', 5),
('Passaporte Gratuito', 0.00, 1200, 1197, '2026-09-20 00:00:00', '2026-10-17 12:00:00', 6),
('Acesso Auditório', 30.00, 200, 196, '2026-10-05 00:00:00', '2026-10-29 17:30:00', 7),
('1º Lote - Inteira', 50.00, 150, 148, '2026-11-15 00:00:00', '2027-02-06 17:00:00', 8),
('1º Lote - Meia-Entrada', 25.00, 120, 120, '2026-11-15 00:00:00', '2027-02-06 17:00:00', 8),
('Credencial Torcedor', 15.00, 800, 800, '2026-10-15 00:00:00', '2026-11-07 23:59:59', 9),
('Lote Antecipado', 75.00, 450, 450, '2026-11-20 00:00:00', '2027-02-19 23:59:59', 10);

-- 5. PARTICIPANTE (12 registros - os 2 últimos sem pedidos para LEFT JOIN)
INSERT INTO PARTICIPANTE (nome, cpf, email, telefone) VALUES
('Matheus Nogueira Tavares', '149.283.746-50', 'matheus.tavares@provedor.com.br', '11991045521'),
('Isabela Cardoso Monteiro', '258.369.147-02', 'isabela.monteiro@dominio.com.br', '11992186634'),
('Diego Santana Vasques', '369.258.147-89', 'diego.vasques@correio.com.br', '11993471108'),
('Carolina Rezende Farias', '471.829.365-04', 'carolina.farias@mail.com.br', '11994509923'),
('Bruno Henrique Castilho', '582.930.471-66', 'bruno.castilho@webmail.com.br', '11995623340'),
('Amanda Queiroz Braga', '693.041.582-77', 'amanda.braga@online.com.br', '11996748815'),
('Vinicius Moura Peixoto', '714.253.647-88', 'vinicius.peixoto@rede.com.br', '11997812290'),
('Letícia Campos Silveira', '825.364.758-99', 'leticia.silveira@digital.com.br', '11998934461'),
('André Luis Sampaio', '936.475.869-10', 'andre.sampaio@caixa.com.br', '11981207745'),
('Natália Drummond Lemos', '159.357.486-21', 'natalia.lemos@portal.com.br', '11982356619'),
('Gustavo Pacheco Prado', '264.859.137-40', 'gustavo.prado@contato.com.br', '11983490082'),
('Bianca Fontes Guedes', '375.918.264-53', 'bianca.guedes@mensagem.com.br', '11984615573');

-- 6. PEDIDO (12 registros)
INSERT INTO PEDIDO (data_hora_criacao, status, taxa_servico, valor_total_bruto, id_participante) VALUES
('2026-11-01 09:40:00', 'Pago', 20.80, 260.00, 1),
('2026-11-02 15:10:00', 'Pago', 29.60, 370.00, 2),
('2026-11-04 11:25:00', 'Pago', 9.00, 90.00, 3),
('2026-11-05 17:50:00', 'Pago', 17.60, 220.00, 4),
('2026-11-07 20:15:00', 'Pago', 20.00, 250.00, 5),
('2026-11-09 13:05:00', 'Pendente', 7.00, 70.00, 6),
('2026-11-10 18:45:00', 'Pago', 12.50, 125.00, 7),
('2026-11-12 10:30:00', 'Pago', 25.60, 320.00, 8),
('2026-10-03 14:15:00', 'Pago', 0.00, 0.00, 9),
('2026-10-18 16:40:00', 'Pago', 12.00, 120.00, 10),
('2026-11-16 21:00:00', 'Pago', 10.00, 100.00, 1),
('2026-11-18 09:20:00', 'Cancelado', 13.00, 130.00, 2);

-- 7. ITEM_PEDIDO (14 registros)
INSERT INTO ITEM_PEDIDO (quantidade, preco, id_pedido, id_lote) VALUES
(4, 65.00, 1, 1),
(2, 140.00, 2, 2),
(2, 45.00, 3, 3),
(2, 110.00, 4, 4),
(2, 55.00, 5, 5),
(2, 35.00, 6, 6),
(5, 25.00, 7, 7),
(2, 160.00, 8, 8),
(3, 0.00, 9, 9),
(4, 30.00, 10, 10),
(2, 50.00, 11, 11),
(2, 65.00, 12, 1),
(2, 45.00, 2, 3),
(1, 140.00, 5, 2);

-- 8. PAGAMENTO (para pedidos com status 'Pago' e valor > 0)
INSERT INTO PAGAMENTO (metodo_pagamento, data_hora_confirmacao, status_pagamento, id_pedido) VALUES
('PIX', '2026-11-01 09:42:10', 'Confirmado', 1),
('Cartão de Crédito', '2026-11-02 15:12:45', 'Confirmado', 2),
('PIX', '2026-11-04 11:26:30', 'Confirmado', 3),
('Boleto', '2026-11-07 08:15:00', 'Confirmado', 4),
('Cartão de Crédito', '2026-11-07 20:17:05', 'Confirmado', 5),
('PIX', '2026-11-10 18:46:20', 'Confirmado', 7),
('Cartão de Crédito', '2026-11-12 10:32:00', 'Confirmado', 8),
('PIX', '2026-10-18 16:41:50', 'Confirmado', 10),
('PIX', '2026-11-16 21:01:40', 'Confirmado', 11);

