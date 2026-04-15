CREATE DATABASE IF NOT EXISTS teste_citel
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE teste_citel;

DROP TABLE IF EXISTS pedidos_itens;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS produtos;
DROP TABLE IF EXISTS clientes;

CREATE TABLE clientes (
  codigo INT NOT NULL,
  nome VARCHAR(120) NOT NULL,
  cidade VARCHAR(80) NOT NULL,
  uf CHAR(2) NOT NULL,
  CONSTRAINT pk_clientes PRIMARY KEY (codigo)
) ENGINE=InnoDB;

CREATE INDEX idx_clientes_nome ON clientes (nome);
CREATE INDEX idx_clientes_cidade_uf ON clientes (cidade, uf);

CREATE TABLE produtos (
  codigo INT NOT NULL AUTO_INCREMENT,
  descricao VARCHAR(150) NOT NULL,
  preco_venda DECIMAL(15, 2) NOT NULL,
  CONSTRAINT pk_produtos PRIMARY KEY (codigo)
) ENGINE=InnoDB;

CREATE INDEX idx_produtos_descricao ON produtos (descricao);

CREATE TABLE pedidos (
  numero_pedido INT NOT NULL AUTO_INCREMENT,
  data_emissao DATETIME NOT NULL,
  codigo_cliente INT NOT NULL,
  valor_total DECIMAL(15, 2) NOT NULL,
  CONSTRAINT pk_pedidos PRIMARY KEY (numero_pedido),
  CONSTRAINT fk_pedidos_cliente FOREIGN KEY (codigo_cliente)
    REFERENCES clientes (codigo)
) ENGINE=InnoDB;

CREATE INDEX idx_pedidos_data_emissao ON pedidos (data_emissao);
CREATE INDEX idx_pedidos_cliente ON pedidos (codigo_cliente);

CREATE TABLE pedidos_itens (
  id BIGINT NOT NULL AUTO_INCREMENT,
  numero_pedido INT NOT NULL,
  codigo_produto INT NOT NULL,
  quantidade DECIMAL(15, 3) NOT NULL,
  valor_unitario DECIMAL(15, 2) NOT NULL,
  valor_total DECIMAL(15, 2) NOT NULL,
  CONSTRAINT pk_pedidos_itens PRIMARY KEY (id),
  CONSTRAINT fk_pedidos_itens_pedido FOREIGN KEY (numero_pedido)
    REFERENCES pedidos (numero_pedido)
    ON DELETE CASCADE,
  CONSTRAINT fk_pedidos_itens_produto FOREIGN KEY (codigo_produto)
    REFERENCES produtos (codigo)
) ENGINE=InnoDB;

CREATE INDEX idx_pedidos_itens_numero_pedido_id ON pedidos_itens (numero_pedido, id);
CREATE INDEX idx_pedidos_itens_codigo_produto ON pedidos_itens (codigo_produto);

INSERT INTO clientes (codigo, nome, cidade, uf) VALUES
(1, 'Mercado Sol Nascente', 'Ribeirao Preto', 'SP'),
(2, 'Padaria Boa Massa', 'Sao Paulo', 'SP'),
(3, 'Distribuidora Horizonte', 'Campinas', 'SP'),
(4, 'Comercial Via Norte', 'Sao Jose dos Campos', 'SP'),
(5, 'Atacado Minas Forte', 'Belo Horizonte', 'MG'),
(6, 'Supermercado Central', 'Uberlandia', 'MG'),
(7, 'Loja do Bairro', 'Curitiba', 'PR'),
(8, 'Rede Litoral Sul', 'Florianopolis', 'SC'),
(9, 'Casa Verde Comercio', 'Porto Alegre', 'RS'),
(10, 'Bom Preco Varejo', 'Londrina', 'PR'),
(11, 'Mercearia Bom Dia', 'Goiania', 'GO'),
(12, 'Emporio Imperial', 'Brasilia', 'DF'),
(13, 'Mercadinho da Praca', 'Aracaju', 'SE'),
(14, 'Comercial Nordeste', 'Fortaleza', 'CE'),
(15, 'Atacado Capital', 'Salvador', 'BA'),
(16, 'Rede Vale Azul', 'Vitoria', 'ES'),
(17, 'Mercantil Pioneiro', 'Campo Grande', 'MS'),
(18, 'Super Barra', 'Rio de Janeiro', 'RJ'),
(19, 'Comercio Nova Era', 'Niteroi', 'RJ'),
(20, 'Distribuidora Prime', 'Recife', 'PE');

INSERT INTO produtos (codigo, descricao, preco_venda) VALUES
(1001, 'Arroz Tipo 1 5kg', 25.90),
(1002, 'Feijao Carioca 1kg', 8.40),
(1003, 'Acucar Refinado 1kg', 4.20),
(1004, 'Cafe Torrado 500g', 14.50),
(1005, 'Oleo de Soja 900ml', 6.90),
(1006, 'Macarrao Espaguete 500g', 5.30),
(1007, 'Molho de Tomate 340g', 3.60),
(1008, 'Farinha de Trigo 1kg', 4.80),
(1009, 'Leite Integral 1L', 4.90),
(1010, 'Manteiga 200g', 10.40),
(1011, 'Queijo Mussarela 1kg', 39.90),
(1012, 'Presunto Cozido 1kg', 27.50),
(1013, 'Sabao em Po 1kg', 13.20),
(1014, 'Detergente 500ml', 2.90),
(1015, 'Papel Higienico 12un', 18.70),
(1016, 'Desinfetante 2L', 9.80),
(1017, 'Agua Sanitaria 2L', 7.20),
(1018, 'Biscoito Recheado 120g', 2.60),
(1019, 'Refrigerante Cola 2L', 8.90),
(1020, 'Suco Integral Uva 1L', 11.30);
