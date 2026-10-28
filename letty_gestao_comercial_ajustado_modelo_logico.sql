CREATE DATABASE IF NOT EXISTS letty_gestao_comercial
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE letty_gestao_comercial;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- 1. ESTRUTURA DDL (CRIAR TABELAS)
-- =====================================================================

CREATE TABLE super_mercado (
    id_rede INT AUTO_INCREMENT,
    cd_cnpj VARCHAR(14) NOT NULL,
    nm_razao_social VARCHAR(120) NOT NULL,
    ds_portal_url VARCHAR(150) NULL,
    dt_inicio_relacionamento DATE NOT NULL,
    nm_representante_geral VARCHAR(100) NOT NULL,
    ds_inscricao_estadual VARCHAR(20) NOT NULL,
    nm_fantasia VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_rede),
    CONSTRAINT uq_super_mercado_cnpj UNIQUE (cd_cnpj)
) ENGINE=InnoDB;

CREATE TABLE fabricante (
    id_fabricante INT AUTO_INCREMENT,
    cd_cnpj CHAR(14) NOT NULL,
    nm_razao_social VARCHAR(120) NOT NULL,
    cd_inscricao_estadual VARCHAR(20) NOT NULL,
    nm_fantasia VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_fabricante),
    CONSTRAINT uq_fabricante_cnpj UNIQUE (cd_cnpj)
) ENGINE=InnoDB;

CREATE TABLE promotor (
    id_promotor INT AUTO_INCREMENT,
    cd_cpf CHAR(11) NOT NULL,
    nm_empresa_terceirizada VARCHAR(100) NOT NULL,
    nm_promotor VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_promotor),
    CONSTRAINT uq_promotor_cpf UNIQUE (cd_cpf)
) ENGINE=InnoDB;

CREATE TABLE loja (
    id_loja INT AUTO_INCREMENT,
    id_rede INT NOT NULL,
    cd_cnpj VARCHAR(14) NOT NULL,
    cd_loja_rede VARCHAR(20) NOT NULL,
    nm_loja VARCHAR(100) NOT NULL,
    in_ativa BOOLEAN NOT NULL,
    PRIMARY KEY (id_loja),
    CONSTRAINT uq_loja_cnpj UNIQUE (cd_cnpj),
    CONSTRAINT fk_loja_super_mercado FOREIGN KEY (id_rede)
        REFERENCES super_mercado(id_rede) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE endereco_fabricante (
    id_endereco_fabricante INT AUTO_INCREMENT,
    id_fabricante INT NOT NULL,
    ds_logradouro VARCHAR(120) NOT NULL,
    nr_endereco VARCHAR(15) NOT NULL,
    ds_complemento VARCHAR(80) NULL,
    nm_bairro VARCHAR(80) NOT NULL,
    nm_cidade VARCHAR(80) NOT NULL,
    sg_estado CHAR(2) NOT NULL,
    nr_cep VARCHAR(8) NOT NULL,
    nm_pais VARCHAR(60) NOT NULL DEFAULT 'Brasil',
    PRIMARY KEY (id_endereco_fabricante),
    CONSTRAINT fk_endereco_fabricante FOREIGN KEY (id_fabricante)
        REFERENCES fabricante(id_fabricante)
) ENGINE=InnoDB;

CREATE TABLE endereco_super_mercado (
    id_endereco_super_mercado INT AUTO_INCREMENT,
    id_rede INT NOT NULL,
    ds_logradouro VARCHAR(120) NOT NULL,
    nr_endereco VARCHAR(15) NOT NULL,
    ds_complemento VARCHAR(80) NULL,
    nm_bairro VARCHAR(80) NOT NULL,
    nm_cidade VARCHAR(80) NOT NULL,
    sg_estado CHAR(2) NOT NULL,
    nr_cep VARCHAR(8) NOT NULL,
    nm_pais VARCHAR(60) NOT NULL DEFAULT 'Brasil',
    PRIMARY KEY (id_endereco_super_mercado),
    CONSTRAINT fk_endereco_super_mercado FOREIGN KEY (id_rede)
        REFERENCES super_mercado(id_rede)
) ENGINE=InnoDB;

CREATE TABLE endereco_loja (
    id_endereco_loja INT AUTO_INCREMENT,
    id_loja INT NOT NULL,
    ds_logradouro VARCHAR(120) NOT NULL,
    nr_endereco VARCHAR(15) NOT NULL,
    ds_complemento VARCHAR(80) NULL,
    nm_bairro VARCHAR(80) NOT NULL,
    nm_cidade VARCHAR(80) NOT NULL,
    sg_estado CHAR(2) NOT NULL,
    nr_cep VARCHAR(8) NOT NULL,
    nm_pais VARCHAR(60) NOT NULL DEFAULT 'Brasil',
    PRIMARY KEY (id_endereco_loja),
    CONSTRAINT fk_endereco_loja FOREIGN KEY (id_loja)
        REFERENCES loja(id_loja)
) ENGINE=InnoDB;

CREATE TABLE contato (
    id_contato INT AUTO_INCREMENT,
    id_rede INT NOT NULL,
    nm_contato VARCHAR(100) NOT NULL,
    ds_cargo VARCHAR(50) NOT NULL,
    ds_setor VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_contato),
    CONSTRAINT fk_contato_super_mercado FOREIGN KEY (id_rede)
        REFERENCES super_mercado(id_rede) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT,
    id_fabricante INT NOT NULL,
    cd_ean VARCHAR(14) NOT NULL,
    qt_peso_liquido DECIMAL(10,3) NOT NULL,
    cd_ncm VARCHAR(8) NOT NULL,
    qt_peso_bruto DECIMAL(10,3) NOT NULL,
    ds_produto VARCHAR(150) NOT NULL,
    tp_regime_tributario VARCHAR(50) NOT NULL,
    tp_unidade_medida VARCHAR(10) NOT NULL,
    tp_embalagem VARCHAR(30) NOT NULL,
    nm_marca VARCHAR(60) NOT NULL,
    vl_preco_tabela DECIMAL(10,2) NOT NULL,
    in_ativo BOOLEAN NOT NULL,
    PRIMARY KEY (id_produto, id_fabricante),
    CONSTRAINT uq_produto_ean UNIQUE (cd_ean),
    -- Indice unico auxiliar: as FKs do modelo referenciam apenas id_produto
    -- (a PK e composta). O MySQL 8.4+ exige chave unica na tabela referenciada.
    CONSTRAINT uq_produto_id_produto UNIQUE (id_produto),
    CONSTRAINT fk_produto_fabricante FOREIGN KEY (id_fabricante)
        REFERENCES fabricante(id_fabricante) ON DELETE CASCADE,
    CONSTRAINT chk_produto_precos CHECK (vl_preco_tabela >= 0),
    CONSTRAINT chk_produto_pesos CHECK (qt_peso_bruto >= 0 AND qt_peso_liquido >= 0)
) ENGINE=InnoDB;

CREATE TABLE lote (
    id_lote INT AUTO_INCREMENT,
    id_produto INT NOT NULL,
    dt_validade_ DATE NOT NULL,
    qt_produzida DECIMAL(10,2) NOT NULL,
    dt_fabricacao DATE NOT NULL,
    cd_numero_lote VARCHAR(30) NOT NULL,
    PRIMARY KEY (id_lote, id_produto),
    CONSTRAINT fk_lote_produto FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto) ON DELETE CASCADE,
    CONSTRAINT chk_lote_quantidade CHECK (qt_produzida >= 0)
) ENGINE=InnoDB;

CREATE TABLE contrato (
    id_contrato INT AUTO_INCREMENT,
    id_fabricante INT NOT NULL,
    dt_inicio DATE NOT NULL,
    status_contrato VARCHAR(30) NOT NULL,
    meta_vendas DECIMAL(12,2) NULL,
    territorio_atuacao_ VARCHAR(100) NULL,
    percentual_comissao DECIMAL(5,2) NOT NULL,
    dt_fim DATE NULL,
    exclusividade BOOLEAN NOT NULL,
    PRIMARY KEY (id_contrato),
    CONSTRAINT fk_contrato_fabricante FOREIGN KEY (id_fabricante)
        REFERENCES fabricante(id_fabricante) ON DELETE RESTRICT,
    CONSTRAINT chk_contrato_comissao CHECK (percentual_comissao BETWEEN 0 AND 100),
    CONSTRAINT chk_contrato_datas CHECK (dt_fim IS NULL OR dt_fim >= dt_inicio)
) ENGINE=InnoDB;

CREATE TABLE comissao (
    id_comissao INT AUTO_INCREMENT,
    id_contrato INT NOT NULL,
    valor_base DECIMAL(10,2) NOT NULL,
    valor_comissao DECIMAL(10,2) NOT NULL,
    status_pagamento VARCHAR(30) NOT NULL,
    percentual_aplicado DECIMAL(5,2) NOT NULL,
    dt_pagamento DATE NULL,
    dt_apuracao DATE NOT NULL,
    PRIMARY KEY (id_comissao),
    CONSTRAINT fk_comissao_contrato FOREIGN KEY (id_contrato)
        REFERENCES contrato(id_contrato) ON DELETE CASCADE,
    CONSTRAINT chk_comissao_percentual CHECK (percentual_aplicado BETWEEN 0 AND 100),
    CONSTRAINT chk_comissao_valores CHECK (valor_base >= 0)
) ENGINE=InnoDB;

CREATE TABLE pedido (
    id_pedido INT AUTO_INCREMENT,
    id_loja INT NOT NULL,
    id_rede INT NOT NULL,
    id_fabricante INT NOT NULL,
    dt_pedido DATE NOT NULL,
    ds_condicao_pagamento VARCHAR(50) NOT NULL,
    vl_preco_total DECIMAL(10,2) NOT NULL,
    dt_prevista_entrega DATE NULL,
    tp_status_atual VARCHAR(30) NOT NULL,
    PRIMARY KEY (id_pedido),
    CONSTRAINT fk_pedido_loja FOREIGN KEY (id_loja)
        REFERENCES loja(id_loja) ON DELETE CASCADE,
    CONSTRAINT fk_pedido_super_mercado FOREIGN KEY (id_rede)
        REFERENCES super_mercado(id_rede) ON DELETE CASCADE,
    CONSTRAINT fk_pedido_fabricante FOREIGN KEY (id_fabricante)
        REFERENCES fabricante(id_fabricante) ON DELETE CASCADE,
    CONSTRAINT chk_pedido_total CHECK (vl_preco_total >= 0)
) ENGINE=InnoDB;

CREATE TABLE item_pedido (
    id_item_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    id_pedido INT NOT NULL,
    qt_solicitada DECIMAL(10,2) NOT NULL,
    vl_preco_negociado DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_pedido, id_produto, id_item_pedido),
    CONSTRAINT fk_item_pedido_produto FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto) ON DELETE RESTRICT,
    CONSTRAINT fk_item_pedido_pedido FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido),
    CONSTRAINT chk_item_pedido_valores CHECK (qt_solicitada > 0 AND vl_preco_negociado >= 0)
) ENGINE=InnoDB;

CREATE TABLE visita (
    id_visita INT AUTO_INCREMENT,
    FK_LOJA_id_loja INT NOT NULL,
    FK_PROMOTOR_id_promotor INT NOT NULL,
    hr_inicio TIME NOT NULL,
    hr_fim TIME NOT NULL,
    dt_visita DATE NOT NULL,
    ds_observacao VARCHAR(255) NULL,
    PRIMARY KEY (id_visita),
    CONSTRAINT fk_visita_loja FOREIGN KEY (FK_LOJA_id_loja)
        REFERENCES loja(id_loja) ON DELETE CASCADE,
    CONSTRAINT fk_visita_promotor FOREIGN KEY (FK_PROMOTOR_id_promotor)
        REFERENCES promotor(id_promotor) ON DELETE CASCADE,
    CONSTRAINT chk_visita_horarios CHECK (hr_fim >= hr_inicio)
) ENGINE=InnoDB;

CREATE TABLE item_visita (
    fk_PRODUTO_id_produto INT NOT NULL,
    id_visita INT NOT NULL,
    qt_estoque_gondola DECIMAL(10,2) NOT NULL,
    dt_validade_encontrada DATE NULL,
    PRIMARY KEY (fk_PRODUTO_id_produto, id_visita),
    CONSTRAINT fk_item_visita_produto FOREIGN KEY (fk_PRODUTO_id_produto)
        REFERENCES produto(id_produto) ON DELETE RESTRICT,
    CONSTRAINT fk_item_visita_visita FOREIGN KEY (id_visita)
        REFERENCES visita(id_visita),
    CONSTRAINT chk_item_visita_estoque CHECK (qt_estoque_gondola >= 0)
) ENGINE=InnoDB;

CREATE TABLE vencimento_prod (
    id_vencimento INT AUTO_INCREMENT,
    id_loja INT NOT NULL,
    id_produto INT NOT NULL,
    cd_cnpj CHAR(14) NULL,
    numero_lote DECIMAL(10,0) NOT NULL,
    dt_validade DATE NOT NULL,
    quantidade_produto_vencido DECIMAL(10,2) NOT NULL,
    dt_vencimento DATE NOT NULL,
    descricao VARCHAR(150) NULL,
    status_vencimento VARCHAR(30) NOT NULL,
    PRIMARY KEY (id_vencimento),
    CONSTRAINT fk_vencimento_loja FOREIGN KEY (id_loja)
        REFERENCES loja(id_loja) ON DELETE CASCADE,
    CONSTRAINT fk_vencimento_produto FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto) ON DELETE CASCADE,
    CONSTRAINT chk_vencimento_quantidade CHECK (quantidade_produto_vencido > 0)
) ENGINE=InnoDB;

-- Tabela associativa do modelo (sem PK no modelo logico)
CREATE TABLE envia (
    id_fabricante INT NULL,
    id_promotor INT NULL,
    CONSTRAINT fk_envia_fabricante FOREIGN KEY (id_fabricante)
        REFERENCES fabricante(id_fabricante) ON DELETE RESTRICT,
    CONSTRAINT fk_envia_promotor FOREIGN KEY (id_promotor)
        REFERENCES promotor(id_promotor) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE telefone_fabricante (
    id_telefone INT NOT NULL AUTO_INCREMENT,
    id_fabricante INT NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_telefone, id_fabricante),
    CONSTRAINT fk_telefone_fabricante FOREIGN KEY (id_fabricante)
        REFERENCES fabricante(id_fabricante)
) ENGINE=InnoDB;

CREATE TABLE email_fabricante (
    id_email INT NOT NULL AUTO_INCREMENT,
    id_fabricante INT NOT NULL,
    email VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_email, id_fabricante),
    CONSTRAINT fk_email_fabricante FOREIGN KEY (id_fabricante)
        REFERENCES fabricante(id_fabricante)
) ENGINE=InnoDB;

CREATE TABLE telefone_promotor (
    id_telefone INT NOT NULL AUTO_INCREMENT,
    id_promotor INT NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_telefone),
    CONSTRAINT fk_telefone_promotor FOREIGN KEY (id_promotor)
        REFERENCES promotor(id_promotor)
) ENGINE=InnoDB;

CREATE TABLE telefone_loja (
    id_telefone INT NOT NULL AUTO_INCREMENT,
    id_loja INT NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_telefone),
    CONSTRAINT fk_telefone_loja FOREIGN KEY (id_loja)
        REFERENCES loja(id_loja)
) ENGINE=InnoDB;

CREATE TABLE telefone_contato (
    id_telefone INT NOT NULL AUTO_INCREMENT,
    id_contato INT NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_telefone),
    CONSTRAINT fk_telefone_contato FOREIGN KEY (id_contato)
        REFERENCES contato(id_contato)
) ENGINE=InnoDB;

CREATE TABLE email_contato (
    id_email INT NOT NULL AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL,
    id_contato INT NOT NULL,
    PRIMARY KEY (id_email),
    CONSTRAINT fk_email_contato FOREIGN KEY (id_contato)
        REFERENCES contato(id_contato)
) ENGINE=InnoDB;


-- =====================================================================
-- 2. MASSA DE DADOS (DML)
-- =====================================================================

INSERT INTO fabricante (cd_cnpj, nm_razao_social, cd_inscricao_estadual, nm_fantasia) VALUES
('11222333000199', 'Indústria Alimentícia Alvorada LTDA', '123456789', 'Alvorada Alimentos'),
('22333444000188', 'Doces e Biscoitos Saboroso S.A.', '987654321', 'Saboroso');

INSERT INTO endereco_fabricante (id_fabricante, ds_logradouro, nr_endereco, ds_complemento, nm_bairro, nm_cidade, sg_estado, nr_cep) VALUES
(1, 'Av. das Indústrias', '500', 'Galpão A', 'Distrito Industrial', 'São Paulo', 'SP', '03100000'),
(2, 'Rodovia Anhanguera', 'Km 18', 'Bloco B', 'Pirituba', 'São Paulo', 'SP', '05112000');

INSERT INTO telefone_fabricante (id_fabricante, telefone) VALUES (1, '1133334444'), (2, '1134445555');
INSERT INTO email_fabricante (id_fabricante, email) VALUES (1, 'comercial@alvorada.com'), (2, 'vendas@saboroso.com.br');

INSERT INTO contrato (id_fabricante, dt_inicio, status_contrato, meta_vendas, territorio_atuacao_, percentual_comissao, dt_fim, exclusividade) VALUES
(1, '2026-01-01', 'Ativo', 150000.00, 'Estado de São Paulo', 5.50, '2026-12-31', TRUE);

-- valor_comissao = valor_base * percentual_aplicado / 100 (33000 * 5% = 1650)
INSERT INTO comissao (id_contrato, valor_base, valor_comissao, status_pagamento, percentual_aplicado, dt_pagamento, dt_apuracao) VALUES
(1, 33000.00, 1650.00, 'Pago', 5.00, '2026-10-10', '2026-09-30');

INSERT INTO produto (id_fabricante, cd_ean, qt_peso_liquido, cd_ncm, qt_peso_bruto, ds_produto, tp_regime_tributario, tp_unidade_medida, tp_embalagem, nm_marca, vl_preco_tabela, in_ativo) VALUES
(1, '7891234567890', 0.140, '19053100', 0.150, 'Biscoito Recheado Chocolate 140g', 'Substituição Tributária', 'UN', 'Pacote', 'Alvorada', 3.50, TRUE),
(1, '7891234567891', 0.120, '19053100', 0.130, 'Biscoito Wafer Morango 120g', 'Substituição Tributária', 'UN', 'Pacote', 'Alvorada', 2.80, TRUE);

INSERT INTO lote (id_produto, dt_validade_, qt_produzida, dt_fabricacao, cd_numero_lote) VALUES
(1, '2026-11-15', 5000.00, '2026-08-01', 'LOT-2026-001'),
(2, '2026-12-30', 4000.00, '2026-09-01', 'LOT-2026-002'),
-- Lotes inconsistentes para a auditoria A02:
(1, '2026-05-01', 1000.00, '2026-10-01', 'LOT-ERRO-901'),
(2, '2026-08-10', 500.00, '2026-09-15', 'LOT-ERRO-902');

INSERT INTO super_mercado (cd_cnpj, nm_razao_social, ds_portal_url, dt_inicio_relacionamento, nm_representante_geral, ds_inscricao_estadual, nm_fantasia) VALUES
('44555666000188', 'Rede Estrela de Supermercados LTDA', 'https://portal.estrela.com.br', '2025-03-10', 'Carlos Eduardo', '987654321', 'Supermercados Estrela');

INSERT INTO endereco_super_mercado (id_rede, ds_logradouro, nr_endereco, ds_complemento, nm_bairro, nm_cidade, sg_estado, nr_cep) VALUES
(1, 'Rua das Flores', '1000', 'Corporate', 'Centro', 'São Paulo', 'SP', '01000000');

-- 6 Lojas cadastradas (Lojas 1, 2, 3 e 4 terão visitas. Lojas 5 e 6 NÃO terão visitas para acionar a A04)
INSERT INTO loja (id_rede, cd_cnpj, cd_loja_rede, nm_loja, in_ativa) VALUES
(1, '44555666000269', 'LJ-01', 'Estrela - Loja Centro', TRUE),
(1, '44555666000340', 'LJ-02', 'Estrela - Loja Jardins', TRUE),
(1, '44555666000411', 'LJ-03', 'Estrela - Loja Paulista', TRUE),
(1, '44555666000592', 'LJ-04', 'Estrela - Loja Paraíso', TRUE),
(1, '44555666000673', 'LJ-05', 'Estrela - Loja Copacabana (Fantasma 1)', TRUE),
(1, '44555666000754', 'LJ-06', 'Estrela - Loja Centro BH (Fantasma 2)', TRUE);

INSERT INTO endereco_loja (id_loja, ds_logradouro, nr_endereco, ds_complemento, nm_bairro, nm_cidade, sg_estado, nr_cep) VALUES
(1, 'Praça da Sé', '50', 'Térreo', 'Sé', 'São Paulo', 'SP', '01001000'),
(2, 'Av. Paulista', '1500', 'Subsolo 1', 'Bela Vista', 'São Paulo', 'SP', '01310200'),
(3, 'Rua da Consolação', '300', 'Loja 01', 'Consolação', 'São Paulo', 'SP', '01301000'),
(4, 'Av. Brigadeiro Luis Antônio', '2000', 'Loja 12', 'Paraíso', 'São Paulo', 'SP', '01317002'),
(5, 'Av. Sete de Setembro', '1200', 'Shopping Centro', 'Centro', 'Curitiba', 'PR', '80060070'),
(6, 'Rua da Bahia', '1400', 'Loja 05', 'Lourdes', 'Belo Horizonte', 'MG', '30160011');

INSERT INTO telefone_loja (id_loja, telefone) VALUES
(1, '1131001100'), (2, '1131002200'), (3, '1131003300'), (4, '1131004400'), (5, '2132001100'), (6, '3133001100');

INSERT INTO contato (id_rede, nm_contato, ds_cargo, ds_setor) VALUES
(1, 'Roberto Souza', 'Gerente de Compras', 'Compras');

INSERT INTO telefone_contato (id_contato, telefone) VALUES (1, '11988887777');
INSERT INTO email_contato (id_contato, email) VALUES (1, 'roberto@estrela.com.br');

INSERT INTO promotor (cd_cpf, nm_empresa_terceirizada, nm_promotor) VALUES
('12345678901', 'PromoServices Agência LTDA', 'João da Silva');

INSERT INTO telefone_promotor (id_promotor, telefone) VALUES (1, '11977776666');
INSERT INTO envia (id_fabricante, id_promotor) VALUES (1, 1);

-- Pedidos (Incluindo Pedido #2 sem itens para acionar a A01)
INSERT INTO pedido (id_loja, id_rede, id_fabricante, dt_pedido, ds_condicao_pagamento, vl_preco_total, dt_prevista_entrega, tp_status_atual) VALUES
(1, 1, 1, '2026-10-01', 'Faturado 30 dias', 3500.00, '2026-10-05', 'Entregue'),
(2, 1, 1, '2026-10-15', 'Boleto', 0.00, '2026-10-20', 'Registrado');

INSERT INTO item_pedido (id_item_pedido, id_produto, id_pedido, qt_solicitada, vl_preco_negociado) VALUES
(1, 1, 1, 1000.00, 3.80); -- Preço acima da tabela (3.50) para acionar A03

-- VISITAS: Cadastradas APENAS para as Lojas 1, 2, 3 e 4. As Lojas 5 e 6 ficam sem visitas de propósito.
INSERT INTO visita (FK_LOJA_id_loja, FK_PROMOTOR_id_promotor, hr_inicio, hr_fim, dt_visita, ds_observacao) VALUES
(1, 1, '08:00:00', '10:00:00', '2026-10-20', 'Ok'),
(2, 1, '09:00:00', '11:00:00', '2026-10-21', 'Ok'),
(3, 1, '08:00:00', '10:00:00', '2026-10-22', 'Ok'),
(4, 1, '09:00:00', '11:00:00', '2026-10-23', 'Ok');

INSERT INTO item_visita (fk_PRODUTO_id_produto, id_visita, qt_estoque_gondola, dt_validade_encontrada) VALUES
(1, 1, 45.00, '2026-11-15');

-- Vencimentos com status 'Notificado' para acionar a A05
-- numero_lote é DECIMAL no modelo: 2026001 representa o lote LOT-2026-001
INSERT INTO vencimento_prod (id_loja, id_produto, cd_cnpj, numero_lote, dt_validade, quantidade_produto_vencido, dt_vencimento, descricao, status_vencimento) VALUES
(1, 1, '44555666000269', 2026001, '2026-11-15', 12.00, '2026-09-12', 'Avariado na gôndola', 'Notificado');


-- =====================================================================
-- 3. CONSULTAS GERENCIAIS (G01 a G05)
-- =====================================================================

-- G01 — Alerta de produtos em gôndola com validade próxima (< 30 dias)
SELECT l.nm_loja, p.ds_produto, iv.qt_estoque_gondola, iv.dt_validade_encontrada,
       DATEDIFF(iv.dt_validade_encontrada, CURDATE()) AS dias_para_vencer
FROM item_visita iv
JOIN visita v ON iv.id_visita = v.id_visita
JOIN loja l ON v.FK_LOJA_id_loja = l.id_loja
JOIN produto p ON iv.fk_PRODUTO_id_produto = p.id_produto
WHERE iv.dt_validade_encontrada <= DATE_ADD(CURDATE(), INTERVAL 30 DAY);

-- G02 — Relatório de ocorrências de produtos vencidos por loja
SELECT l.nm_loja, p.ds_produto, vp.numero_lote, vp.quantidade_produto_vencido, vp.status_vencimento
FROM vencimento_prod vp
JOIN loja l ON vp.id_loja = l.id_loja
JOIN produto p ON vp.id_produto = p.id_produto;

-- G03 — Produtividade e rotina dos promotores
SELECT pr.nm_promotor, pr.nm_empresa_terceirizada AS nm_empresa, l.nm_loja, v.dt_visita,
       TIMEDIFF(v.hr_fim, v.hr_inicio) AS tempo_permanencia
FROM visita v
JOIN promotor pr ON v.FK_PROMOTOR_id_promotor = pr.id_promotor
JOIN loja l ON v.FK_LOJA_id_loja = l.id_loja;

-- G04 — Status dos pedidos comerciais
SELECT ped.id_pedido, sm.nm_fantasia AS rede, lj.nm_loja, ped.tp_status_atual, ped.vl_preco_total
FROM pedido ped
JOIN loja lj ON ped.id_loja = lj.id_loja
JOIN super_mercado sm ON ped.id_rede = sm.id_rede;

-- G05 — Apuração de comissões
SELECT f.nm_fantasia AS fabricante, com.valor_base, com.percentual_aplicado, com.valor_comissao, com.status_pagamento
FROM comissao com
JOIN contrato c ON com.id_contrato = c.id_contrato
JOIN fabricante f ON c.id_fabricante = f.id_fabricante;

-- =====================================================================
-- 4. CONSULTAS DE AUDITORIA (A01 a A05)
-- =====================================================================

-- A01 — Identificar pedidos órfãos (sem nenhum item vinculado)
SELECT p.id_pedido, p.dt_pedido, p.tp_status_atual
FROM pedido p
LEFT JOIN item_pedido ip ON p.id_pedido = ip.id_pedido
WHERE ip.id_pedido IS NULL;

-- A02 — Verificar lotes com data de validade inconsistente (anterior à fabricação)
SELECT id_lote, cd_numero_lote, dt_fabricacao, dt_validade_
FROM lote
WHERE dt_validade_ < dt_fabricacao;

-- A03 — Auditoria de Preços: Itens de pedido vendidos acima do preço oficial de tabela
SELECT ip.id_pedido, p.ds_produto, p.vl_preco_tabela, ip.vl_preco_negociado,
       (ip.vl_preco_negociado - p.vl_preco_tabela) AS diferenca_acima
FROM item_pedido ip
JOIN produto p ON ip.id_produto = p.id_produto
WHERE ip.vl_preco_negociado > p.vl_preco_tabela;

-- A04 — Auditoria de Lojas "Fantasmas" (Lojas ativas que nunca receberam visitas)
-- [Vai retornar corretamente as Lojas LJ-05 e LJ-06 que criamos sem visitas]
SELECT l.id_loja, l.cd_loja_rede, l.nm_loja, sm.nm_fantasia AS rede
FROM loja l
JOIN super_mercado sm ON l.id_rede = sm.id_rede
LEFT JOIN visita v ON l.id_loja = v.FK_LOJA_id_loja
WHERE l.in_ativa = TRUE AND v.id_visita IS NULL;

-- A05 — Auditoria de Ocorrências de Vencimento Pendentes de Descarte Físico
SELECT vp.id_vencimento, l.nm_loja, vp.dt_vencimento, vp.quantidade_produto_vencido, vp.status_vencimento
FROM vencimento_prod vp
JOIN loja l ON vp.id_loja = l.id_loja
WHERE vp.status_vencimento IN ('Identificado', 'Notificado');
