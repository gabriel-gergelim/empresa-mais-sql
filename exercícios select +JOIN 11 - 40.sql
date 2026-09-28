/* =========================================================
   BANCO DE DADOS II – MySQL 8.x
   SISTEMA EMPRESA+
   Criação profissional do banco + exercícios progressivos
   ========================================================= */


/* =========================================================
   PARTE 1 — CRIAÇÃO DO BANCO
   ========================================================= */

DROP DATABASE IF EXISTS empresa;

-- DROP DATABASE empresa;

CREATE DATABASE empresa
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE empresa;


-- select id_produto, nome as 'Nome Do Produto'  from produto;



/* =========================================================
   PARTE 2 — TABELA CLIENTE
   Requisitos:
   - id numérico, auto incremento, PK
   - nome obrigatório
   - email não duplicado
   - status ativo por padrão
   - data de cadastro automática
   - engine transacional
   ========================================================= */

CREATE TABLE cliente (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(150) NOT NULL,
  email VARCHAR(100) UNIQUE,
  ativo TINYINT NOT NULL DEFAULT 1,
  data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


/* =========================================================
   VALIDAÇÃO INICIAL
   ========================================================= */

SHOW TABLES;
DESCRIBE cliente;
SHOW INDEX FROM cliente;


/* =========================================================
   EXERCÍCIOS PROGRESSIVOS 1 
   Sistema: EMPRESA+
   Objetivo: Criar categoria, produto e relacionamento com integridade
   ========================================================= */

USE empresa;


/* =========================================================
   ETAPA 2 — ORGANIZAÇÃO DO CATÁLOGO
   (Criada antes por ser a tabela "pai" do relacionamento)
   ========================================================= */

CREATE TABLE categoria (
  id_categoria INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

/*
6) Justifique sua escolha de tipos de dados:
- id_categoria: INT AUTO_INCREMENT porque é uma chave surrogate simples,
  eficiente para indexação e suficiente para cenários empresariais comuns.
- nome: VARCHAR(80) porque o tamanho do texto é variável, o campo é obrigatório
  e 80 caracteres atende bem ao cadastro de categorias.
- UNIQUE(nome) evita duplicidade lógica no catálogo.
*/

/*
7) Por que nome deve ser UNIQUE?
- Para impedir categorias repetidas, como "Informática" cadastrada várias vezes.

8) Qual problema ocorreria se não fosse?
- Haveria duplicidade lógica, ambiguidade em relatórios e maior risco de erro operacional.

9) Qual impacto de não definir PRIMARY KEY?
- Dificulta referência por chave estrangeira, prejudica organização dos dados
  e pode impactar desempenho e manutenção.
*/


/* =========================================================
   ETAPA 1 — EXPANDINDO O SISTEMA (PRODUTO)
   ========================================================= */

CREATE TABLE produto (
  id_produto INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(80) NOT NULL,
  preco DECIMAL(10,2) NOT NULL,
  estoque INT NOT NULL DEFAULT 0,
  data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_categoria INT NOT NULL,
  CONSTRAINT chk_produto_preco_pos CHECK (preco > 0),
  CONSTRAINT fk_produto_categoria
    FOREIGN KEY (id_categoria)
    REFERENCES categoria(id_categoria)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
) ENGINE=InnoDB;

/*
1) Qual tipo de dado é mais adequado para preço?
- DECIMAL(10,2), pois fornece precisão exata para valores financeiros.

2) Por que não usar FLOAT?
- Porque FLOAT trabalha com ponto flutuante binário e pode gerar imprecisões.

3) Qual impacto de usar FLOAT em sistema financeiro?
- Pode causar erros de arredondamento, divergência em somatórios
  e inconsistência contábil.

4) O que acontece se não definir DEFAULT para estoque?
- Inserções sem valor explícito podem gerar erro (se NOT NULL)
  ou valor NULL, dificultando controle de estoque.

5) É obrigatório definir ENGINE? Por quê?
- Não é obrigatório para executar, mas é boa prática profissional.
  Declarar ENGINE=InnoDB garante previsibilidade de transações,
  chaves estrangeiras e comportamento do armazenamento.
*/


/* =========================================================
   ETAPA 3 — JUSTIFICATIVA DO RELACIONAMENTO
   ========================================================= */

/*
10) Justifique sua escolha (CASCADE / RESTRICT / SET NULL):
- ON DELETE RESTRICT impede excluir categoria que ainda possui produtos.
  Isso atende exatamente ao requisito do enunciado.
- CASCADE seria perigoso, pois excluir uma categoria apagaria todos os produtos.
- SET NULL permitiria produto sem categoria, o que não atende ao cenário proposto.

11) Quando usar ON DELETE CASCADE?
- Quando o registro filho só faz sentido se o pai existir.
  Ex.: itens de pedido dependem do pedido.

12) Quando usar ON DELETE RESTRICT?
- Quando o pai não pode ser excluído se ainda houver dependências.
  Ex.: categoria com produtos.

13) Qual impacto de permitir SET NULL?
- O relacionamento é perdido e o filho pode ficar “órfão lógico”,
  exigindo mais validações na aplicação.

14) Qual a diferença entre regra no banco e regra na aplicação?
- No banco: garantia forte, centralizada e obrigatória para qualquer acesso.
- Na aplicação: depende do código; pode falhar por bug, esquecimento ou integração externa.
*/


/* =========================================================
   EXERCÍCIO — CRIANDO A TABELA PEDIDO
   ========================================================= */

CREATE TABLE pedido (
  id_pedido INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  data_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  valor DECIMAL(10,2) NOT NULL,
  CONSTRAINT chk_pedido_valor_pos CHECK (valor > 0),
  CONSTRAINT fk_pedido_cliente
    FOREIGN KEY (id_cliente)
    REFERENCES cliente(id_cliente)
    ON DELETE CASCADE
    ON UPDATE RESTRICT
) ENGINE=InnoDB;




/* =========================================================
   EXERCÍCIO — CRIANDO A TABELA PEDIDO_ITEM
   ========================================================= */

CREATE TABLE pedido_item (
  id_item INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NOT NULL,
  id_produto INT NOT NULL,
  quantidade INT NOT NULL,
  preco_unitario DECIMAL(10,2) NOT NULL,
  CONSTRAINT chk_pedido_item_qtd_pos CHECK (quantidade > 0),
  CONSTRAINT chk_pedido_item_preco_pos CHECK (preco_unitario > 0),
  CONSTRAINT fk_item_pedido
    FOREIGN KEY (id_pedido)
    REFERENCES pedido(id_pedido)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  CONSTRAINT fk_item_produto
    FOREIGN KEY (id_produto)
    REFERENCES produto(id_produto)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
) ENGINE=InnoDB;


/* =========================================================
   ALTER TABLE — EXEMPLOS DIDÁTICOS
   ========================================================= */

ALTER TABLE cliente
ADD COLUMN cpf VARCHAR(14) UNIQUE;

ALTER TABLE cliente
MODIFY COLUMN nome VARCHAR(150) NOT NULL;

ALTER TABLE cliente
DROP COLUMN cpf;


/* =========================================================
   RENAME TABLE — EXEMPLOS DIDÁTICOS
   ========================================================= */

/*
1) Cenário: versionar a tabela produto antes de uma mudança maior.
*/

RENAME TABLE produto TO produto_v1;
SHOW TABLES;

RENAME TABLE produto_v1 TO produto;
SHOW TABLES;

/*
2) Cenário: renomear categoria temporariamente.
*/

RENAME TABLE categoria TO categoria_old;
SHOW TABLES;

RENAME TABLE categoria_old TO categoria;
SHOW TABLES;

/*
Observações:
- RENAME TABLE é atômico no MySQL.
- Mesmo assim, renomear tabelas impacta aplicações, consultas, views e scripts.
- Em produção, esse tipo de mudança exige planejamento.
*/


/* =========================================================
   EXERCÍCIO — Aplicando normalização
1.	Excluir a chave primaria da tabela “pedido_item”, 
e transformar os atributos “id_pedido e id_produto” em 
uma chave primaria composta.
   ========================================================= */

use empresa;
alter table pedido_item drop column id_item;
alter table pedido_item add primary key (id_pedido,id_produto);

describe pedido_item;

/* =========================================================
   EXERCÍCIOS PROGRESSIVOS 2 (SOLUÇÃO)
   ========================================================= */


/* =========================================================
   ETAPA 1 — TESTE DE INTEGRIDADE
   - Insira clientes
   - Insira pedidos válidos
   - Tente inserir pedido com cliente inexistente
   - Explique o erro
   ========================================================= */

/* ---------- Inserindo  clientes ---------- */
INSERT INTO cliente (nome, email, ativo)
            VALUES  ('Ana Souza', 'ana@email.com', 1),
                    ('Carla Mendes', 'carla@email.com', 1),
                    ('Ana Souza', 'ana@gmail.com', 1),
                    ('Bruno Lima', 'bruno@yahoo.com', 1),
                    ('Carla Dias', 'carla@gmail.com', 1),
                    ('Diego Silva', 'diego@outlook.com', 0),
                    ('Eva Santos', default,1),
                    ('Fabio Rocha', 'fabio@gmail.com', 1);

Select * from Cliente;
/* ---------- Inserindo categorias ---------- */
DESCRIBE categoria;

INSERT INTO categoria (nome)
	            VALUES('Informática'),
					  ('Livros'),
                      ('Acessórios');

select * from categoria order by id_categoria;

/* ---------- Inserindo produtos válidos ---------- */
INSERT INTO produto (nome, preco, estoque, id_categoria)
VALUES
  ('Notebook', 4500, 10, 1),
  ('Mouse Gamer', 150, 50, 1),
  ('Livro SQL', 90.00, 30, 2),
  ('Smartphone', 3200, 15, 1);

select * from produto;

/* ---------- Inserindo pedidos válidos ---------- */
describe pedido;
select * from cliente;

INSERT INTO pedido (id_cliente, valor)
			VALUES (1, 4500), (1, 150), (2, 3200), (3, 90), (3, 500);            
                   
                   
Select * from pedido;

/* ---------- Inserindo itens dos pedidos ---------- */

describe pedido_item;

INSERT INTO pedido_item (id_pedido, id_produto, quantidade, preco_unitario)
VALUES
  (1, 1, 1, 4500),   
  (2, 2, 1, 150),  
  (3, 4, 1, 3200),  
  (4, 3, 1, 90),
  (5, 3, 5, 100);   

select * from pedido_item;

/* =========================================================
LOAD DATA (Conceito Corporativo)
Importação em massa:
========================================================= */
use empresa;

select * from cliente;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cliente.csv'
into table cliente
character SET utf8mb4
fields terminated by ';'
lines terminated by '\r\n'
ignore 1 lines
(nome,email,ativo,data_cadastro);

select * from cliente;
select * from produto;
select * from pedido;
select * from pedido_item;






/* =========================================================
   ETAPA 2 — TESTE DE CASCADE
   - Delete um cliente com pedidos
   - Verifique se pedidos foram apagados
   - Explique comportamento
   ========================================================= */

/* ---------- Verificando antes da exclusão ---------- */
SELECT * FROM cliente;


SELECT * FROM pedido ORDER BY id_pedido;


/*
Vamos excluir o cliente de id_cliente = 2.
Esse cliente possui pedido(s).
Como a FK em pedido usa ON DELETE CASCADE,
os pedidos desse cliente também serão removidos.
E como pedido_item também usa ON DELETE CASCADE em relação a pedido,
os itens desses pedidos serão apagados automaticamente.
*/


-- DELETE FROM cliente
-- WHERE id_cliente = 2;

/* ---------- Verificando depois da exclusão ---------- */
SELECT * FROM cliente;



SELECT * FROM pedido ORDER BY id_pedido;

/*
Explicação do comportamento:
- Ao excluir o cliente, o banco remove automaticamente seus pedidos
  por causa do ON DELETE CASCADE em pedido.
- Em seguida, os itens ligados a esses pedidos também são removidos,
  por causa do ON DELETE CASCADE em pedido_item.
- Isso evita registros órfãos e mantém a consistência do modelo.
*/

select * from pedido;
select * from pedido_item;

show tables ;
/* =========================================================
   ETAPA 3 — EVOLUÇÃO REAL
   - Adicionar campo desconto
   - Criar CHECK
   - Testar inserção inválida
   ========================================================= */

ALTER TABLE pedido
ADD COLUMN desconto DECIMAL(5,2) NOT NULL DEFAULT 0.00;

ALTER TABLE pedido
ADD CONSTRAINT chk_pedido_desconto_faixa
CHECK (desconto >= 0 AND desconto <= 100);

/* ---------- Inserção válida ---------- */
-- INSERT INTO pedido (id_cliente, valor, desconto)
-- VALUES (3, 250.00, 10.00);

/* ---------- Inserção inválida: desconto acima de 100 ---------- */
/*
O comando abaixo deve falhar, pois viola a regra:
desconto >= 0 AND desconto <= 100
*/

/* -------------------- */

-- INSERT INTO pedido (id_cliente, valor, desconto)
-- VALUES (3, 300.00, 150.00);

/* -------------------- */


/*
Explicação:
- O MySQL rejeita o registro porque 150.00 está fora da faixa permitida.
- Isso garante que o desconto represente um percentual válido.
*/


/* =========================================================
   ETAPA MERCADO — JUSTIFICATIVAS
   ========================================================= */

/*
1) Justifique ON DELETE CASCADE em pedido_item:
- pedido_item depende totalmente de pedido.
- Se o pedido deixar de existir, seus itens não fazem mais sentido.
- O CASCADE automatiza a limpeza e evita lixo lógico no banco.

2) Explique por que RESTRICT é mais seguro em produto:
- Um produto pode já estar associado a itens de pedidos históricos.
- Excluir esse produto automaticamente poderia comprometer rastreabilidade,
  auditoria e histórico de vendas.
- RESTRICT força análise antes da exclusão, tornando a operação mais segura.
*/


/* =========================================================
   MODELO LÓGICO FINAL (ATÉ AQUI)
   ========================================================= */

/*
CLIENTE
-------
id_cliente (PK)
nome
email (UNIQUE)
status
data_cadastro

CATEGORIA
---------
id_categoria (PK)
nome (UNIQUE)

PRODUTO
-------
id_produto (PK)
nome
preco
estoque
data_cadastro
id_categoria (FK -> categoria.id_categoria)

PEDIDO
------
id_pedido (PK)
id_cliente (FK -> cliente.id_cliente)
data_pedido
valor
desconto

PEDIDO_ITEM
-----------
id_item (PK)
id_pedido (FK -> pedido.id_pedido)
id_produto (FK -> produto.id_produto)
quantidade
preco_unitario


RELACIONAMENTOS
---------------
categoria 1 ---- N produto
cliente   1 ---- N pedido
pedido    1 ---- N pedido_item
produto   1 ---- N pedido_item

REGRAS DE EXCLUSÃO
------------------
categoria -> produto      : ON DELETE RESTRICT
cliente   -> pedido       : ON DELETE CASCADE
pedido    -> pedido_item  : ON DELETE CASCADE
produto   -> pedido_item  : ON DELETE RESTRICT
*/


/* =========================================================
   CONSULTAS FINAIS DE VALIDAÇÃO
   ========================================================= */

SHOW TABLES;

DESCRIBE cliente;
DESCRIBE categoria;
DESCRIBE produto;
DESCRIBE pedido;
DESCRIBE pedido_item;

SHOW INDEX FROM cliente;
SHOW INDEX FROM categoria;
SHOW INDEX FROM produto;
SHOW INDEX FROM pedido;
SHOW INDEX FROM pedido_item;



/* =========================================================
							DML
   ========================================================= */

select * from cliente;
describe cliente;

/* =========================================================
UPDATE PROFISSIONAL
   ========================================================= */

select email from cliente 
where id_cliente = 1; 


update cliente 
set email = 'ana.souza@gmail.com'
where id_cliente = 1; 

select email from cliente 
where id_cliente = 1; 



SELECT * FROM pedido WHERE id_cliente = 4;


delete from cliente 
where id_cliente = 4; 


SELECT * FROM pedido WHERE id_cliente = 4;

/* =========================================================
COMMIT — Confirmando Alterações
   ========================================================= */

select * from cliente where id_cliente = 11; 

start transaction;

update cliente
set ativo = 1 
where id_cliente = 11; 

commit;

select * from cliente where id_cliente = 11; 

/* =========================================================
Exercício Prático 4 – Cadastro de Novas Categorias
========================================================= */

START TRANSACTION;

INSERT INTO categoria (nome)
VALUES
    ('Periféricos'),
    ('Smartphones'),
    ('Componentes'),
    ('Games'),
    ('Impressão');
COMMIT;

SELECT * FROM categoria order by id_categoria;





/* =========================================================
Exercício Prático 5 – Inserção em Massa com Transação
========================================================= */

START TRANSACTION;

INSERT INTO cliente (nome, email, ativo)
VALUES
    ('Marcos Oliveira','marcos@email.com',1),
    ('Juliana Costa','juliana@email.com',1),
    ('Ricardo Martins','ricardo@gmail.com',1),
    ('Patrícia Alves','patricia@yahoo.com',1),
    ('Fernando Souza','fernando@outlook.com',1),
    ('Camila Rocha','camila@gmail.com',1),
    ('Lucas Ferreira','lucas@email.com',1),
    ('Renata Lima','renata@yahoo.com',1),
    ('Gustavo Santos','gustavo@gmail.com',0),
    ('Vanessa Mendes','vanessa@email.com',1),
    ('Tiago Ribeiro','tiago@outlook.com',1),
    ('Amanda Carvalho','amanda@gmail.com',1),
    ('Bruno Fernandes','bruno@email.com',1),
    ('Daniela Gomes','daniela@yahoo.com',0),
    ('Eduardo Pereira','eduardo@gmail.com',1),
    ('Flávia Nunes',NULL,1),
    ('Henrique Barbosa','henrique@email.com',1),
    ('João Pedro Silva','joaopedro@yahoo.com',1),
    ('Karen Rodrigues','karen@outlook.com',1);

COMMIT;

/* Caso ocorra algum erro antes do COMMIT,
   utilize:
   ROLLBACK;
*/

SELECT * FROM cliente;



/* =========================================================
Exercício Prático 6 – Cadastro de Produtos
========================================================= */

START TRANSACTION;

INSERT INTO produto
(nome, preco, estoque, id_categoria)
VALUES
('Teclado Mecânico RGB',299.90,25,
    (SELECT id_categoria FROM categoria WHERE nome='Periféricos')),

('Mouse Gamer Pro',149.90,40,
    (SELECT id_categoria FROM categoria WHERE nome='Periféricos')),

('Webcam Full HD',249.90,18,
    (SELECT id_categoria FROM categoria WHERE nome='Periféricos')),

('Galaxy S25',4899.00,12,
    (SELECT id_categoria FROM categoria WHERE nome='Smartphones')),

('iPhone 17',7999.00,8,
    (SELECT id_categoria FROM categoria WHERE nome='Smartphones')),

('Memória RAM 16GB',359.90,30,
    (SELECT id_categoria FROM categoria WHERE nome='Componentes')),

('SSD NVMe 1TB',499.90,22,
    (SELECT id_categoria FROM categoria WHERE nome='Componentes')),

('Fonte 650W',389.90,15,
    (SELECT id_categoria FROM categoria WHERE nome='Componentes')),

('Controle Xbox Series',429.90,20,
    (SELECT id_categoria FROM categoria WHERE nome='Games')),

('Headset Gamer',319.90,28,
    (SELECT id_categoria FROM categoria WHERE nome='Games')),

('Impressora Multifuncional',899.90,10,
    (SELECT id_categoria FROM categoria WHERE nome='Impressão')),

('Toner Compatível',129.90,50,
    (SELECT id_categoria FROM categoria WHERE nome='Impressão')),

('Papel Fotográfico A4',39.90,80,
    (SELECT id_categoria FROM categoria WHERE nome='Impressão')),

('Livro SQL Avançado',119.90,35,
    (SELECT id_categoria FROM categoria WHERE nome='Livros')),

('Livro Modelagem de Dados',89.90,20,
    (SELECT id_categoria FROM categoria WHERE nome='Livros'));

COMMIT;

SELECT
    id_produto,
    nome,
    preco,
    estoque,
    id_categoria
FROM produto;




DELIMITER $$
CREATE PROCEDURE cadastrar_cliente( IN p_nome VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER
    FOR SQLEXCEPTION
		BEGIN
			ROLLBACK;
			SELECT 'Erro encontrado. Operação cancelada.' AS mensagem;
		END;
    START TRANSACTION;
    INSERT INTO cliente(nome)
    VALUES(p_nome);
    COMMIT;
    SELECT 'Cadastro realizado com sucesso.' AS mensagem;
END $$
DELIMITER ;



/* =========================================================
   Solução – Exercício Prático 7
   Atualização de Preços dos Produtos
========================================================= */

USE empresa;

/* Verificando os produtos que serão atualizados */
SELECT id_produto, nome, preco
FROM produto;

/*
Considere que os produtos possuem os seguintes identificadores:

Notebook      -> id_produto = 1
Mouse Gamer   -> id_produto = 2
Livro SQL     -> id_produto = 3
Smartphone    -> id_produto = 4
*/

START TRANSACTION;

/* Atualizando os preços */
UPDATE produto
SET preco = 4650.00
WHERE id_produto = 1;

UPDATE produto
SET preco = 169.90
WHERE id_produto = 2;

UPDATE produto
SET preco = 99.90
WHERE id_produto = 3;

UPDATE produto
SET preco = 3399.00
WHERE id_produto = 4;

/* Conferindo o resultado */
SELECT id_produto, nome, preco
FROM produto
WHERE id_produto IN (1,2,3,4);
/* Se todas as alterações estiverem corretas */
COMMIT;
/*
Caso seja identificado algum erro antes do COMMIT,
execute:
ROLLBACK;
*/


USE empresa;

/* =========================================================
   Solução – Exercício Prático 8
   Reposição de Estoque
========================================================= */

/* Consultando os produtos */
SELECT id_produto, nome, estoque
FROM produto;

/*
Notebook      -> id_produto = 1
Mouse Gamer   -> id_produto = 2
Livro SQL     -> id_produto = 3
Smartphone    -> id_produto = 4
*/

START TRANSACTION;

/* Atualizando o estoque */

UPDATE produto
SET estoque = 18
WHERE id_produto = 1;

UPDATE produto
SET estoque = 65
WHERE id_produto = 2;

UPDATE produto
SET estoque = 42
WHERE id_produto = 3;

UPDATE produto
SET estoque = 20
WHERE id_produto = 4;

/* Conferindo os novos estoques */

SELECT
    id_produto,
    nome,
    estoque
FROM produto
WHERE id_produto IN (1,2,3,4);

/* Confirmando a operação */

COMMIT;

/*
Caso algum valor esteja incorreto,
execute:
ROLLBACK;
*/


USE empresa;

/* =========================================================
   SOLUÇÃO – EXERCÍCIO PRÁTICO 9
   Registro Completo de um Pedido
   ========================================================= */

/* Verificando os clientes chamados Ana Souza */
SELECT id_cliente, nome, email
FROM cliente
WHERE nome = 'Ana Souza';

/* Verificando os produtos da venda */
SELECT id_produto, nome, preco, estoque
FROM produto
WHERE id_produto IN (1, 2, 3);

/*
Considere:

Ana Souza   -> id_cliente = 1
Notebook    -> id_produto = 1
Mouse Gamer -> id_produto = 2
Livro SQL   -> id_produto = 3
*/

START TRANSACTION;

/* Calculando o valor total do pedido com os preços atuais */
SET @valor_total = (
    SELECT
          (SELECT preco FROM produto WHERE id_produto = 1) * 1
        + (SELECT preco FROM produto WHERE id_produto = 2) * 2
        + (SELECT preco FROM produto WHERE id_produto = 3) * 1
);

/* Cadastrando o pedido */
INSERT INTO pedido (id_cliente, valor)
VALUES (1, @valor_total);

/* Recuperando o código gerado para o novo pedido */
SET @id_novo_pedido = LAST_INSERT_ID();

/* Inserindo todos os itens com um único INSERT */
INSERT INTO pedido_item
    (id_pedido, id_produto, quantidade, preco_unitario)
VALUES
    (
        @id_novo_pedido,
        1,
        1,
        (SELECT preco FROM produto WHERE id_produto = 1)
    ),
    (
        @id_novo_pedido,
        2,
        2,
        (SELECT preco FROM produto WHERE id_produto = 2)
    ),
    (
        @id_novo_pedido,
        3,
        1,
        (SELECT preco FROM produto WHERE id_produto = 3)
    );

/* Atualizando o estoque pela chave primária */

UPDATE produto
SET estoque = estoque - 1
WHERE id_produto = 1
  AND estoque >= 1;

UPDATE produto
SET estoque = estoque - 2
WHERE id_produto = 2
  AND estoque >= 2;

UPDATE produto
SET estoque = estoque - 1
WHERE id_produto = 3
  AND estoque >= 1;

/* Conferindo o pedido cadastrado */
SELECT
    p.id_pedido,
    c.nome AS cliente,
    p.data_pedido,
    p.valor
FROM pedido p
INNER JOIN cliente c
    ON c.id_cliente = p.id_cliente
WHERE p.id_pedido = @id_novo_pedido;

/* Conferindo os itens */
SELECT
    pi.id_pedido,
    pr.nome AS produto,
    pi.quantidade,
    pi.preco_unitario,
    pi.quantidade * pi.preco_unitario AS subtotal
FROM pedido_item pi
INNER JOIN produto pr
    ON pr.id_produto = pi.id_produto
WHERE pi.id_pedido = @id_novo_pedido;

/* Conferindo os estoques */
SELECT id_produto, nome, estoque
FROM produto
WHERE id_produto IN (1, 2, 3);

/* Se todos os dados estiverem corretos */
COMMIT;

/*
Caso seja identificado algum problema antes do COMMIT:

ROLLBACK;
*/


/* =========================================================
   SOLUÇÃO – EXERCÍCIO PRÁTICO 10
   Cancelamento de um Pedido
   ========================================================= */
   
USE empresa;
/* Pedido que será cancelado */
SET @pedido_cancelado = 6;

/* Verificando se o pedido existe */
SELECT
    id_pedido,
    id_cliente,
    data_pedido,
    valor
FROM pedido
WHERE id_pedido = @pedido_cancelado;

/* Verificando os itens do pedido */
SELECT
    pi.id_pedido,
    pi.id_produto,
    p.nome AS produto,
    pi.quantidade,
    pi.preco_unitario
FROM pedido_item pi
INNER JOIN produto p
    ON p.id_produto = pi.id_produto
WHERE pi.id_pedido = @pedido_cancelado;

/*
Considere que o pedido nº 6 possui:

Notebook    -> id_produto = 1 -> quantidade = 1
Mouse Gamer -> id_produto = 2 -> quantidade = 2
Livro SQL   -> id_produto = 3 -> quantidade = 1
*/

START TRANSACTION;

/* Devolvendo os produtos ao estoque */

UPDATE produto
SET estoque = estoque + 1
WHERE id_produto = 1;

UPDATE produto
SET estoque = estoque + 2
WHERE id_produto = 2;

UPDATE produto
SET estoque = estoque + 1
WHERE id_produto = 3;

/* Excluindo os itens do pedido */
DELETE FROM pedido_item
WHERE id_pedido = @pedido_cancelado;

/* Excluindo o pedido */
DELETE FROM pedido
WHERE id_pedido = @pedido_cancelado;

/* Verificando se o pedido foi excluído */
SELECT *
FROM pedido
WHERE id_pedido = @pedido_cancelado;

/* Verificando se os itens foram excluídos */
SELECT *
FROM pedido_item
WHERE id_pedido = @pedido_cancelado;

/* Conferindo os estoques após a devolução */
SELECT id_produto, nome, estoque
FROM produto
WHERE id_produto IN (1, 2, 3);

/* Se todas as alterações estiverem corretas */
COMMIT;

/*
Caso seja identificado algum problema antes do COMMIT,
execute:

ROLLBACK;
*/


select * from cliente;
select * from produto;
select * from pedido;
select * from pedido_item;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --
/* =========================================================
   ETAPA 2 — CARGA DE DADOS
   SISTEMA EMPRESA+ — MySQL 8.x

   Adiciona:
   - 60 clientes
   - 10 categorias
   - 70 produtos
   - 140 pedidos
   - cerca de 370 itens de pedido

   Execute somente uma vez, após o script principal.
   ========================================================= */

USE empresa;

START TRANSACTION;

/* 1. CLIENTES COMPLEMENTARES */
INSERT INTO cliente (nome, email, ativo, data_cadastro)
VALUES
    ('Aline Monteiro', 'aline.monteiro@gmail.com', 1, '2024-01-12 09:15:00'),
    ('André Ribeiro', 'andre.ribeiro@outlook.com', 1, '2024-01-25 14:20:00'),
    ('Beatriz Moreira', 'beatriz.moreira@yahoo.com', 1, '2024-02-03 10:10:00'),
    ('Caio Albuquerque', 'caio.albuquerque@email.com', 0, '2024-02-14 16:45:00'),
    ('Cecília Duarte', 'cecilia.duarte@gmail.com', 1, '2024-03-01 08:30:00'),
    ('Cláudio Peixoto', NULL, 1, '2024-03-18 11:05:00'),
    ('Débora Freitas', 'debora.freitas@outlook.com', 1, '2024-04-02 13:40:00'),
    ('Elisa Cardoso', 'elisa.cardoso@gmail.com', 0, '2024-04-19 17:20:00'),
    ('Felipe Azevedo', 'felipe.azevedo@yahoo.com', 1, '2024-05-06 09:50:00'),
    ('Gabriela Tavares', 'gabriela.tavares@gmail.com', 1, '2024-05-21 15:35:00'),
    ('Heitor Moura', 'heitor.moura@email.com', 1, '2024-06-04 12:15:00'),
    ('Isabela Castro', NULL, 0, '2024-06-23 18:05:00'),
    ('Júlio César Ramos', 'julio.ramos@outlook.com', 1, '2024-07-08 10:25:00'),
    ('Larissa Figueiredo', 'larissa.figueiredo@gmail.com', 1, '2024-07-26 14:55:00'),
    ('Leandro Pires', 'leandro.pires@yahoo.com', 1, '2024-08-09 09:10:00'),
    ('Lívia Rezende', 'livia.rezende@gmail.com', 1, '2024-08-28 16:30:00'),
    ('Marcelo Nascimento', 'marcelo.nascimento@email.com', 0, '2024-09-12 11:45:00'),
    ('Márcia Teixeira', NULL, 1, '2024-09-29 13:25:00'),
    ('Matheus Correia', 'matheus.correia@gmail.com', 1, '2024-10-07 08:40:00'),
    ('Mônica Barros', 'monica.barros@outlook.com', 1, '2024-10-24 17:10:00'),
    ('Natália Campos', 'natalia.campos@yahoo.com', 1, '2024-11-03 10:35:00'),
    ('Otávio Lopes', 'otavio.lopes@gmail.com', 0, '2024-11-18 15:50:00'),
    ('Paula Magalhães', 'paula.magalhaes@email.com', 1, '2024-12-02 09:05:00'),
    ('Pedro Henrique Moraes', 'pedro.moraes@gmail.com', 1, '2024-12-19 14:15:00'),
    ('Priscila Andrade', NULL, 1, '2025-01-07 11:30:00'),
    ('Rafael Vieira', 'rafael.vieira@outlook.com', 1, '2025-01-22 16:20:00'),
    ('Raquel Martins', 'raquel.martins@gmail.com', 0, '2025-02-05 08:55:00'),
    ('Rodrigo Cunha', 'rodrigo.cunha@yahoo.com', 1, '2025-02-18 13:10:00'),
    ('Sabrina Melo', 'sabrina.melo@gmail.com', 1, '2025-03-04 10:45:00'),
    ('Samuel Neves', 'samuel.neves@email.com', 1, '2025-03-21 17:35:00'),
    ('Sérgio Batista', NULL, 0, '2025-04-08 09:25:00'),
    ('Simone Xavier', 'simone.xavier@gmail.com', 1, '2025-04-26 14:40:00'),
    ('Talita Borges', 'talita.borges@outlook.com', 1, '2025-05-11 11:15:00'),
    ('Tatiane Reis', 'tatiane.reis@yahoo.com', 1, '2025-05-29 18:00:00'),
    ('Valéria Guimarães', 'valeria.guimaraes@gmail.com', 1, '2025-06-13 08:20:00'),
    ('Vinícius Dantas', 'vinicius.dantas@email.com', 0, '2025-06-27 15:05:00'),
    ('Vitória Leal', NULL, 1, '2025-07-09 12:50:00'),
    ('Wagner Matos', 'wagner.matos@outlook.com', 1, '2025-07-24 09:35:00'),
    ('Yasmin Coelho', 'yasmin.coelho@gmail.com', 1, '2025-08-06 16:10:00'),
    ('Alex Sandro Nogueira', 'alex.nogueira@yahoo.com', 1, '2025-08-22 10:05:00'),
    ('Bianca Rios', 'bianca.rios@gmail.com', 0, '2025-09-03 13:45:00'),
    ('Cristiano Lacerda', 'cristiano.lacerda@email.com', 1, '2025-09-19 17:25:00'),
    ('Daiane Sales', NULL, 1, '2025-10-02 08:15:00'),
    ('Elias Pontes', 'elias.pontes@outlook.com', 1, '2025-10-17 14:30:00'),
    ('Fernanda Prado', 'fernanda.prado@gmail.com', 1, '2025-11-01 11:40:00'),
    ('Guilherme Viana', 'guilherme.viana@yahoo.com', 0, '2025-11-16 16:55:00'),
    ('Heloísa Braga', 'heloisa.braga@gmail.com', 1, '2025-12-04 09:45:00'),
    ('Igor Domingues', 'igor.domingues@email.com', 1, '2025-12-20 13:35:00'),
    ('Janaina Macedo', 'janaina.macedo@outlook.com', 1, '2026-01-09 10:20:00'),
    ('Kleber Fonseca', NULL, 0, '2026-01-26 15:15:00'),
    ('Luciana Paes', 'luciana.paes@gmail.com', 1, '2026-02-11 08:50:00'),
    ('Murilo Assis', 'murilo.assis@yahoo.com', 1, '2026-02-25 17:05:00'),
    ('Noemi Vasconcelos', 'noemi.vasconcelos@gmail.com', 1, '2026-03-08 12:25:00'),
    ('Orlando Queiroz', 'orlando.queiroz@email.com', 1, '2026-03-23 09:30:00'),
    ('Regina Amaral', 'regina.amaral@outlook.com', 0, '2026-04-06 14:10:00'),
    ('Roberta Paiva', 'roberta.paiva@gmail.com', 1, '2026-04-19 11:55:00'),
    ('Sandro Brito', 'sandro.brito@yahoo.com', 1, '2026-05-03 16:40:00'),
    ('Tereza Moraes', NULL, 1, '2026-05-18 08:05:00'),
    ('Ulisses Farias', 'ulisses.farias@gmail.com', 1, '2026-06-01 13:20:00'),
    ('Zuleica Torres', 'zuleica.torres@outlook.com', 0, '2026-06-16 17:45:00');

/* 2. NOVAS CATEGORIAS */
INSERT INTO categoria (nome)
VALUES
    ('Monitores'),
    ('Redes'),
    ('Armazenamento'),
    ('Áudio'),
    ('Escritório'),
    ('Casa Inteligente'),
    ('Fotografia'),
    ('Energia'),
    ('Segurança'),
    ('Software');

/* 3. NOVOS PRODUTOS */
INSERT INTO produto (nome, preco, estoque, id_categoria)
VALUES
    ('Monitor LED 19 Polegadas', 549.90, 18, (SELECT id_categoria FROM categoria WHERE nome = 'Monitores')),
    ('Monitor IPS 24 Full HD', 899.90, 25, (SELECT id_categoria FROM categoria WHERE nome = 'Monitores')),
    ('Monitor Gamer 27 165Hz', 1899.90, 12, (SELECT id_categoria FROM categoria WHERE nome = 'Monitores')),
    ('Monitor Ultrawide 29', 2199.00, 9, (SELECT id_categoria FROM categoria WHERE nome = 'Monitores')),
    ('Monitor 4K 32 Polegadas', 3299.90, 6, (SELECT id_categoria FROM categoria WHERE nome = 'Monitores')),
    ('Suporte Articulado para Monitor', 189.90, 35, (SELECT id_categoria FROM categoria WHERE nome = 'Monitores')),
    ('Cabo DisplayPort 2 Metros', 79.90, 60, (SELECT id_categoria FROM categoria WHERE nome = 'Monitores')),
    ('Roteador Wi-Fi 6', 599.90, 22, (SELECT id_categoria FROM categoria WHERE nome = 'Redes')),
    ('Switch Gigabit 8 Portas', 349.90, 16, (SELECT id_categoria FROM categoria WHERE nome = 'Redes')),
    ('Access Point Corporativo', 799.90, 11, (SELECT id_categoria FROM categoria WHERE nome = 'Redes')),
    ('Repetidor Wi-Fi Dual Band', 219.90, 30, (SELECT id_categoria FROM categoria WHERE nome = 'Redes')),
    ('Placa de Rede PCIe', 139.90, 28, (SELECT id_categoria FROM categoria WHERE nome = 'Redes')),
    ('Cabo de Rede CAT6 10m', 69.90, 75, (SELECT id_categoria FROM categoria WHERE nome = 'Redes')),
    ('Conector RJ45 Pacote 100', 89.90, 40, (SELECT id_categoria FROM categoria WHERE nome = 'Redes')),
    ('HD Externo 1TB', 429.90, 24, (SELECT id_categoria FROM categoria WHERE nome = 'Armazenamento')),
    ('HD Externo 2TB', 629.90, 18, (SELECT id_categoria FROM categoria WHERE nome = 'Armazenamento')),
    ('SSD SATA 480GB', 249.90, 40, (SELECT id_categoria FROM categoria WHERE nome = 'Armazenamento')),
    ('SSD NVMe 2TB', 899.90, 14, (SELECT id_categoria FROM categoria WHERE nome = 'Armazenamento')),
    ('Pendrive 64GB', 49.90, 90, (SELECT id_categoria FROM categoria WHERE nome = 'Armazenamento')),
    ('Cartão MicroSD 128GB', 99.90, 55, (SELECT id_categoria FROM categoria WHERE nome = 'Armazenamento')),
    ('Case USB para HD 2.5', 79.90, 33, (SELECT id_categoria FROM categoria WHERE nome = 'Armazenamento')),
    ('Caixa de Som Bluetooth', 279.90, 26, (SELECT id_categoria FROM categoria WHERE nome = 'Áudio')),
    ('Fone Bluetooth Esportivo', 189.90, 31, (SELECT id_categoria FROM categoria WHERE nome = 'Áudio')),
    ('Microfone Condensador USB', 459.90, 17, (SELECT id_categoria FROM categoria WHERE nome = 'Áudio')),
    ('Soundbar 2.1 Canais', 899.90, 10, (SELECT id_categoria FROM categoria WHERE nome = 'Áudio')),
    ('Interface de Áudio USB', 749.90, 8, (SELECT id_categoria FROM categoria WHERE nome = 'Áudio')),
    ('Cabo P2 Estéreo 1.5m', 29.90, 100, (SELECT id_categoria FROM categoria WHERE nome = 'Áudio')),
    ('Suporte Articulado para Microfone', 159.90, 21, (SELECT id_categoria FROM categoria WHERE nome = 'Áudio')),
    ('Cadeira Ergonômica Executiva', 1299.90, 7, (SELECT id_categoria FROM categoria WHERE nome = 'Escritório')),
    ('Mesa para Computador 120cm', 699.90, 13, (SELECT id_categoria FROM categoria WHERE nome = 'Escritório')),
    ('Apoio para Pés Ajustável', 119.90, 29, (SELECT id_categoria FROM categoria WHERE nome = 'Escritório')),
    ('Luminária de Mesa LED', 139.90, 36, (SELECT id_categoria FROM categoria WHERE nome = 'Escritório')),
    ('Fragmentadora de Papel', 549.90, 9, (SELECT id_categoria FROM categoria WHERE nome = 'Escritório')),
    ('Calculadora Financeira', 249.90, 20, (SELECT id_categoria FROM categoria WHERE nome = 'Escritório')),
    ('Organizador de Cabos', 39.90, 85, (SELECT id_categoria FROM categoria WHERE nome = 'Escritório')),
    ('Lâmpada Inteligente RGB', 89.90, 48, (SELECT id_categoria FROM categoria WHERE nome = 'Casa Inteligente')),
    ('Tomada Inteligente Wi-Fi', 109.90, 42, (SELECT id_categoria FROM categoria WHERE nome = 'Casa Inteligente')),
    ('Assistente Virtual com Tela', 899.90, 15, (SELECT id_categoria FROM categoria WHERE nome = 'Casa Inteligente')),
    ('Fechadura Digital Biométrica', 1499.90, 8, (SELECT id_categoria FROM categoria WHERE nome = 'Casa Inteligente')),
    ('Sensor de Presença Wi-Fi', 129.90, 37, (SELECT id_categoria FROM categoria WHERE nome = 'Casa Inteligente')),
    ('Controle Universal Inteligente', 169.90, 25, (SELECT id_categoria FROM categoria WHERE nome = 'Casa Inteligente')),
    ('Campainha Inteligente com Câmera', 699.90, 12, (SELECT id_categoria FROM categoria WHERE nome = 'Casa Inteligente')),
    ('Câmera Mirrorless 24MP', 5899.90, 5, (SELECT id_categoria FROM categoria WHERE nome = 'Fotografia')),
    ('Lente 50mm f1.8', 1399.90, 7, (SELECT id_categoria FROM categoria WHERE nome = 'Fotografia')),
    ('Tripé Profissional 1.7m', 399.90, 14, (SELECT id_categoria FROM categoria WHERE nome = 'Fotografia')),
    ('Ring Light 18 Polegadas', 299.90, 19, (SELECT id_categoria FROM categoria WHERE nome = 'Fotografia')),
    ('Mochila para Câmera', 249.90, 23, (SELECT id_categoria FROM categoria WHERE nome = 'Fotografia')),
    ('Cartão SD 256GB', 219.90, 28, (SELECT id_categoria FROM categoria WHERE nome = 'Fotografia')),
    ('Kit Limpeza para Lentes', 59.90, 50, (SELECT id_categoria FROM categoria WHERE nome = 'Fotografia')),
    ('Nobreak 1200VA', 899.90, 16, (SELECT id_categoria FROM categoria WHERE nome = 'Energia')),
    ('Filtro de Linha 8 Tomadas', 119.90, 44, (SELECT id_categoria FROM categoria WHERE nome = 'Energia')),
    ('Estabilizador 1000VA', 429.90, 12, (SELECT id_categoria FROM categoria WHERE nome = 'Energia')),
    ('Carregador USB-C 65W', 199.90, 35, (SELECT id_categoria FROM categoria WHERE nome = 'Energia')),
    ('Power Bank 20000mAh', 249.90, 27, (SELECT id_categoria FROM categoria WHERE nome = 'Energia')),
    ('Pilha Recarregável AA Kit 4', 79.90, 65, (SELECT id_categoria FROM categoria WHERE nome = 'Energia')),
    ('Carregador de Pilhas Inteligente', 149.90, 22, (SELECT id_categoria FROM categoria WHERE nome = 'Energia')),
    ('Câmera IP Full HD', 349.90, 30, (SELECT id_categoria FROM categoria WHERE nome = 'Segurança')),
    ('Kit CFTV 4 Câmeras', 1899.90, 9, (SELECT id_categoria FROM categoria WHERE nome = 'Segurança')),
    ('Sensor de Abertura Sem Fio', 89.90, 45, (SELECT id_categoria FROM categoria WHERE nome = 'Segurança')),
    ('Alarme Residencial Wi-Fi', 699.90, 13, (SELECT id_categoria FROM categoria WHERE nome = 'Segurança')),
    ('Cofre Digital Compacto', 499.90, 11, (SELECT id_categoria FROM categoria WHERE nome = 'Segurança')),
    ('Leitor Biométrico USB', 299.90, 18, (SELECT id_categoria FROM categoria WHERE nome = 'Segurança')),
    ('Sirene Externa 120dB', 139.90, 24, (SELECT id_categoria FROM categoria WHERE nome = 'Segurança')),
    ('Licença Antivírus 1 Ano', 99.90, 80, (SELECT id_categoria FROM categoria WHERE nome = 'Software')),
    ('Licença Office Pessoal 1 Ano', 349.90, 45, (SELECT id_categoria FROM categoria WHERE nome = 'Software')),
    ('Sistema Operacional Profissional', 1099.90, 20, (SELECT id_categoria FROM categoria WHERE nome = 'Software')),
    ('Software de Backup Empresarial', 799.90, 14, (SELECT id_categoria FROM categoria WHERE nome = 'Software')),
    ('Editor de Vídeo Licença Anual', 599.90, 17, (SELECT id_categoria FROM categoria WHERE nome = 'Software')),
    ('Gerenciador de Senhas Premium', 149.90, 52, (SELECT id_categoria FROM categoria WHERE nome = 'Software')),
    ('Curso Online de SQL Completo', 199.90, 100, (SELECT id_categoria FROM categoria WHERE nome = 'Software'));

COMMIT;


/* 4. GERAÇÃO CONTROLADA DE PEDIDOS E ITENS */

DROP PROCEDURE IF EXISTS gerar_carga_pedidos;

DELIMITER $$

CREATE PROCEDURE gerar_carga_pedidos()
BEGIN
    DECLARE v_contador INT DEFAULT 1;
    DECLARE v_total_clientes INT;
    DECLARE v_total_produtos INT;
    DECLARE v_id_cliente INT;
    DECLARE v_id_produto1 INT;
    DECLARE v_id_produto2 INT;
    DECLARE v_id_produto3 INT;
    DECLARE v_qtd1 INT;
    DECLARE v_qtd2 INT;
    DECLARE v_qtd3 INT;
    DECLARE v_preco1 DECIMAL(10,2);
    DECLARE v_preco2 DECIMAL(10,2);
    DECLARE v_preco3 DECIMAL(10,2);
    DECLARE v_valor_total DECIMAL(10,2);
    DECLARE v_desconto DECIMAL(5,2);
    DECLARE v_id_pedido INT;
    DECLARE v_data_pedido DATETIME;
    DECLARE v_offset_cliente INT;
    DECLARE v_offset_produto1 INT;
    DECLARE v_offset_produto2 INT;
    DECLARE v_offset_produto3 INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT COUNT(*)
      INTO v_total_clientes
      FROM cliente
     WHERE ativo = 1;

    SELECT COUNT(*)
      INTO v_total_produtos
      FROM produto;

    START TRANSACTION;

    WHILE v_contador <= 140 DO

        SET v_offset_cliente =
            (v_contador * 7) MOD v_total_clientes;

        SET v_offset_produto1 =
            (v_contador * 3) MOD v_total_produtos;

        SET v_offset_produto2 =
            ((v_contador * 3) + 1) MOD v_total_produtos;

        SET v_offset_produto3 =
            ((v_contador * 3) + 2) MOD v_total_produtos;

        SELECT id_cliente
          INTO v_id_cliente
          FROM cliente
         WHERE ativo = 1
         ORDER BY id_cliente
         LIMIT 1 OFFSET v_offset_cliente;

        SELECT id_produto, preco
          INTO v_id_produto1, v_preco1
          FROM produto
         ORDER BY id_produto
         LIMIT 1 OFFSET v_offset_produto1;

        SELECT id_produto, preco
          INTO v_id_produto2, v_preco2
          FROM produto
         ORDER BY id_produto
         LIMIT 1 OFFSET v_offset_produto2;

        SELECT id_produto, preco
          INTO v_id_produto3, v_preco3
          FROM produto
         ORDER BY id_produto
         LIMIT 1 OFFSET v_offset_produto3;

        SET v_qtd1 = 1 + (v_contador MOD 3);
        SET v_qtd2 = 1 + ((v_contador + 1) MOD 2);
        SET v_qtd3 = 1 + ((v_contador + 2) MOD 4);

        SET v_desconto =
            CASE
                WHEN v_contador MOD 10 = 0 THEN 20.00
                WHEN v_contador MOD 7 = 0 THEN 15.00
                WHEN v_contador MOD 5 = 0 THEN 10.00
                WHEN v_contador MOD 3 = 0 THEN 5.00
                ELSE 0.00
            END;

        SET v_data_pedido =
            DATE_ADD(
                '2025-01-05 08:00:00',
                INTERVAL ((v_contador * 3) MOD 540) DAY
            );

        IF v_contador MOD 3 = 0 THEN
            SET v_valor_total =
                (v_preco1 * v_qtd1) +
                (v_preco2 * v_qtd2);
        ELSE
            SET v_valor_total =
                (v_preco1 * v_qtd1) +
                (v_preco2 * v_qtd2) +
                (v_preco3 * v_qtd3);
        END IF;

        INSERT INTO pedido
            (id_cliente, data_pedido, valor, desconto)
        VALUES
            (v_id_cliente, v_data_pedido, v_valor_total, v_desconto);

        SET v_id_pedido = LAST_INSERT_ID();

        INSERT INTO pedido_item
            (id_pedido, id_produto, quantidade, preco_unitario)
        VALUES
            (v_id_pedido, v_id_produto1, v_qtd1, v_preco1),
            (v_id_pedido, v_id_produto2, v_qtd2, v_preco2);

        IF v_contador MOD 3 <> 0 THEN
            INSERT INTO pedido_item
                (id_pedido, id_produto, quantidade, preco_unitario)
            VALUES
                (v_id_pedido, v_id_produto3, v_qtd3, v_preco3);
        END IF;

        SET v_contador = v_contador + 1;
    END WHILE;

    COMMIT;
END $$

DELIMITER ;

CALL gerar_carga_pedidos();

DROP PROCEDURE gerar_carga_pedidos;


/* 5. VALIDAÇÃO DA CARGA */

SELECT COUNT(*) AS total_clientes FROM cliente;
SELECT COUNT(*) AS total_categorias FROM categoria;
SELECT COUNT(*) AS total_produtos FROM produto;
SELECT COUNT(*) AS total_pedidos FROM pedido;
SELECT COUNT(*) AS total_itens_pedido FROM pedido_item;

SELECT ativo, COUNT(*) AS quantidade
FROM cliente
GROUP BY ativo;

SELECT
    CASE
        WHEN email IS NULL THEN 'Sem e-mail'
        WHEN email LIKE '%@gmail.com' THEN 'Gmail'
        WHEN email LIKE '%@outlook.com' THEN 'Outlook'
        WHEN email LIKE '%@yahoo.com' THEN 'Yahoo'
        ELSE 'Outros'
    END AS dominio,
    COUNT(*) AS quantidade
FROM cliente
GROUP BY dominio
ORDER BY quantidade DESC;

SELECT
    MIN(data_pedido) AS primeiro_pedido,
    MAX(data_pedido) AS ultimo_pedido,
    MIN(valor) AS menor_valor,
    MAX(valor) AS maior_valor,
    AVG(valor) AS valor_medio
FROM pedido;

describe produto;



select * from cliente;
select * from produto;
select * from categoria order by id_categoria;
select * from pedido;
SELECT * FROM pedido_item;


-- exercício 11
select id_categoria, nome from categoria order by id_categoria;
select * from cliente limit 10;
select * from produto limit 10;
select * from pedido limit 10;

-- execrcíco 12
select nome from cliente limit 15;
select nome, email from cliente limit 15;
select nome, preco, estoque from produto limit 15;
select data_pedido, valor from pedido  limit 15;

-- exercício 13
select  id_cliente, nome, email, ativo from cliente where id_cliente between 1 and 20 and ativo = 1;
select  id_cliente, nome, email, ativo from cliente where id_cliente between 1 and 40 and ativo = 0 ;
select  id_cliente, nome, email, data_cadastro from cliente where data_cadastro between "2025-01-01 00:00:00" and "2025-06-30 23:59:59" ;
select  id_cliente, nome, email, data_cadastro from cliente where data_cadastro between "2026-01-01 00:00:00" and "2026-06-30 23:59:59" ;

-- exercício 14
select id_produto, nome, preco, estoque from produto where preco > 2000;
select id_produto, nome, preco, estoque from produto where preco < 80;
select id_produto, nome, preco, estoque from produto where estoque > 60;
select id_produto, nome, preco, estoque from produto where estoque <= 10 ;

-- exercício 15
select id_produto, nome, preco, estoque from produto where preco > 500 and estoque < 20 limit 26;
select id_cliente, nome, email, ativo, data_cadastro from cliente where ativo = 1 and data_cadastro like "2025%" limit 26;
select id_pedido, id_cliente, valor, desconto from pedido where valor > 3000 and desconto = 10 limit 26;
select id_produto, nome, preco, estoque from produto where estoque > 30 and preco < 300 limit 26;

-- exercício 16
select id_cliente, nome, email, ativo from cliente where ativo = 0 or email is null;
select id_produto, nome, preco, estoque from produto where preco < 50 or preco > 3000;
select id_pedido, id_cliente, valor, desconto from pedido where desconto = 15 or desconto = 20;
select id_produto, nome, preco, estoque from produto where estoque < 10 or estoque > 80;

-- exercício 17
select id_cliente, nome, email from cliente where nome like "a%";
select id_cliente, nome, email from cliente where nome like "m%";
select id_produto, nome, preco, estoque from produto where nome like "%usb%";
select id_produto, nome, preco, estoque from produto where nome like "monitor%";
select id_cliente, nome, email from cliente where email like "r%";

-- exercício 18
select id_cliente, nome, email, ativo from cliente where email is null;
select id_cliente, nome, email, ativo from cliente where email is null and ativo > 0;
select id_cliente, nome, email, ativo from cliente where email is null and ativo < 1;
select count(*) as cliente_sem_email from cliente where email is null;
select count(*) as cliente_com_email from cliente where email is not null;

-- exercício 19
select id_produto, nome, preco, estoque from produto where preco between 400 and 600;
select id_produto, nome, preco, estoque from produto where estoque between 10 and 20;
select id_pedido, id_cliente, valor, desconto from pedido where valor between 2000 and 3000;
select id_cliente, nome, email, data_cadastro from cliente where data_cadastro between '2025-07-01' and '2025-12-31'; 

-- exercício 20
select id_produto, nome, preco, estoque, id_categoria 
from produto 
where id_categoria IN (2, 4, 6);

select id_produto, nome, preco, estoque, id_categoria
 from produto
 where id_categoria IN (9, 10, 11);
 
select id_pedido, id_cliente, valor, desconto
 from pedido
 where desconto IN (5, 15, 20);
 
select id_cliente, nome, email, ativo
 from cliente
 where id_cliente IN (5, 10, 15, 20, 25);
 
 -- exercício 21
 select distinct desconto from pedido order by desconto ASC; -- remove linhas duplicadas e retorna apenas valores únicos em uma consulta
 
 select distinct ativo from cliente order by ativo ASC;

 select distinct date_format(data_pedido, '%Y') as ano from pedido order by ano ASC;-- comando que, distingue todos os valores da coluna, apresentando apenas valroes sem duplicata. Em seguida, formata a data (data_pedido) para ter apenas o ano. Posteriormente, apelida a coluna para ano.
 
 select distinct id_categoria from produto order by id_categoria ASC;
 
 -- exercício 22
 select id_cliente, nome, email from cliente order by nome ASC limit 20; -- ordena os resultados apresentandos, através do nome, em ordem alfabética. Limita os resultados em 20. O ASC nn é necessário, order by já ordena alfabeticamente de forma automática
 
 select id_produto, nome, preco, estoque from produto order by preco DESC limit 15; -- apresenta em ordem decrescente e apresenta apenas 15 resultados
 
 select id_pedido, id_cliente, data_pedido, valor from pedido order by data_pedido DESC limit 20; -- desc também funciona para citar em ordem decrescente a maior data para a menor
 
 select id_produto, nome, preco, estoque, id_categoria from produto order by id_categoria, nome limit 20; -- duas colunas para ordenação
 
 -- exercício 23
select id_cliente, nome, email, data_cadastro from cliente order by data_cadastro ASC limit 5;
    
select id_produto, nome, preco, estoque from produto order by preco desc limit 10 ;
    
select id_produto, nome, preco, estoque from produto order by estoque ASC limit 5;

select id_pedido, id_cliente, valor, desconto from pedido order by valor DESC limit 10;
    
-- exercício 24
-- obs: cada página contem 10 registros
select id_produto, nome, preco, estoque from produto order by id_produto ASC limit 10 offset 0; -- não pula nenhuma linha ao apresentar, apresenta primeira pg
    
select id_produto, nome, preco, estoque from produto order by id_produto ASC limit 10 offset 10; -- pula 10 registros, que compõe a página 1

select id_produto, nome, preco, estoque from produto order by id_produto ASC limit 10 offset 20; -- pula 20 registros, apresentando a terceira página
    
select id_produto, nome, preco, estoque from produto order by id_produto ASC limit 10 offset 40; -- pula 40 registros, apresentando página 5

-- exercício 25
select id_cliente, nome, email, ativo from cliente where ativo = 1 and nome like 'M%' order by nome ASC LIMIT 15; -- clientes que começam com m, apresentando um total de 15
    
select id_produto, nome, preco, estoque from produto where preco >= 200 and preco <= 800 AND estoque > 30;
    
select id_pedido, id_cliente, valor, desconto from pedido where valor > 1000 and (desconto = 10 OR desconto = 20) order by valor DESC limit 20;

select id_cliente, nome, email, data_cadastro from cliente where data_cadastro like '2025%' and email like '%@gmail.com' order by nome ASC; -- ordem crescente
    
-- exercício 26
select id_produto, nome, preco, estoque from produto order by preco DESC limit 10;
 
select id_produto, nome, preco, estoque from produto order by estoque ASC limit 10;

select id_cliente, nome, email, data_cadastro from cliente order by data_cadastro DESC limit 15;

select id_pedido, id_cliente, data_pedido, valor, desconto from pedido order by valor DESC limit 20;

select id_produto, nome, preco, estoque from produto where estoque > 0 order by preco ASC limit 10;
    
-- exercício 27
select id_cliente, nome, email, ativo  from cliente where email is null order by nome limit 25;

select id_produto, nome, preco, estoque from produto where estoque <= 10 order by estoque ASC limit 25;

select id_pedido, id_cliente, valor, desconto from pedido where desconto = 0 order by valor DESC limit 20;
    
select id_produto, nome, preco, estoque from produto where preco > 3000 order by preco DESC limit 25;

select id_cliente, nome, email, ativo, data_cadastro from cliente where ativo = 0 order by data_cadastro DESC limit 15;

-- exercício 28 
select id_cliente, nome, email from cliente where email like '%@gmail.com' order by nome ASC limit 20;

select id_cliente, nome, email from cliente where email like '%@outlook.com' order by nome ASC limit 20;

select id_cliente, nome, email from cliente where nome like 'S%' order by nome limit 25;

select id_cliente, nome, email, data_cadastro from cliente where data_cadastro like '2026%' order by data_cadastro DESC limit 20;

select id_cliente, nome, email, ativo from cliente where ativo = 1 and (nome like 'A%' OR nome like 'B%') order by nome ASC limit 25;
    
-- exercício 29
select id_produto, nome, preco, estoque from produto order by preco ASC limit 20;

select id_produto, nome, preco, estoque from produto order by estoque DESC limit 20;

select id_pedido, id_cliente, data_pedido, valor, desconto from pedido order by valor DESC limit 20;

select id_cliente, nome, email, ativo from cliente order by nome ASC limit 20;

select id_pedido, id_cliente, data_pedido, valor, desconto from pedido order by data_pedido DESC limit 15;
 
 -- exercício 30
 select p.id_pedido, p.data_pedido, p.valor, c.nome as cliente from pedido p inner join cliente c on p.id_cliente = c.id_cliente;
 
 select p.id_pedido, p.data_pedido, p.valor, c.nome as cliente from pedido p inner join cliente c on p.id_cliente = c.id_cliente where p.valor > 1000;
 
-- exercício 31
select c.id_cliente, c.nome as cliente, p.id_pedido, p.data_pedido, p.valor from cliente c left join pedido p on c.id_cliente = p.id_cliente;

select c.id_cliente, c.nome as cliente, c.email from cliente c left join pedido p on c.id_cliente = p.id_cliente where p.id_pedido is null;

-- exercício 32
select c.id_cliente, c.nome as cliente, p.id_pedido, p.valor from pedido p right join cliente c on c.id_cliente = p.id_cliente;

select c.id_cliente, c.nome as cliente, c.email, p.id_pedido, p.data_pedido, p.valor from cliente c right join pedido p on c.id_cliente = p.id_cliente where ativo = 1;

-- exercício 33
select p.id_pedido, pi.id_produto, pi.quantidade, pi.preco_unitario from pedido p inner join pedido_item pi on p.id_pedido = pi.id_pedido;

select p.id_pedido, pi.id_produto, pi.quantidade, pi.preco_unitario from pedido p inner join pedido_item pi on p.id_pedido = pi.id_pedido where pi.quantidade > 1;

-- exercício 34
select p.id_pedido, prod.nome as produto, pi.quantidade, pi.preco_unitario from pedido p inner join pedido_item pi on p.id_pedido = pi.id_pedido inner join produto prod on pi.id_produto = prod.id_produto;

select p.id_pedido, prod.nome as produto, pi.quantidade, pi.preco_unitario from pedido p inner join pedido_item pi on p.id_pedido = pi.id_pedido inner join produto prod on pi.id_produto = prod.id_produto where pi.preco_unitario > 1000;

-- exercício 35 
select c.nome as cliente, p.id_pedido, pi.id_produto, pi.quantidade from cliente c inner join pedido p on c.id_cliente = p.id_cliente inner join pedido_item pi on p.id_pedido = pi.id_pedido;

select c.nome as cliente, p.id_pedido, p.data_pedido, pi.id_produto, pi.quantidade from cliente c inner join pedido p on c.id_cliente = p.id_cliente inner join pedido_item pi on p.id_pedido = pi.id_pedido where c.ativo = 1 and p.data_pedido between '2026-01-01' and '2026-12-31';

-- exercício 36
select c.nome as cliente, p.data_pedido, prod.nome as produto, pi.quantidade, pi.preco_unitario 
from cliente c inner join pedido p on c.id_cliente = p.id_cliente inner join pedido_item pi on p.id_pedido = pi.id_pedido inner join produto prod on pi.id_produto = prod.id_produto;

select c.nome as cliente, p.data_pedido, prod.nome as produto, pi.quantidade, pi.preco_unitario 
from cliente c inner join pedido p on c.id_cliente = p.id_cliente inner join pedido_item pi on p.id_pedido = pi.id_pedido inner join produto prod on pi.id_produto = prod.id_produto 
where pi.quantidade > 1 and pi.preco_unitario > 500;

-- exercício 37
select prod.nome as produto, prod.preco, prod.estoque, cat.nome 
from produto prod inner join categoria cat on prod.id_categoria = cat.id_categoria;

select prod.nome as produto, prod.preco, prod.estoque, cat.nome 
from produto prod inner join categoria cat on prod.id_categoria = cat.id_categoria 
where cat.nome in ("software","segurança","energia");

-- exercício 38
select c.nome as cliente, p.data_pedido, prod.nome as produto, cat.nome as categoria, pi.quantidade, pi.preco_unitario from cliente c inner join pedido p on c.id_cliente = p.id_cliente inner join pedido_item pi on p.id_pedido = pi.id_pedido inner join produto prod on pi.id_produto = prod.id_produto inner join categoria cat on prod.id_categoria = cat.id_categoria order by cat.nome;

select c.nome as cliente, p.data_pedido, prod.nome as produto, cat.nome as categoria, pi.quantidade, pi.preco_unitario from cliente c inner join pedido p on c.id_cliente = p.id_cliente inner join pedido_item pi on p.id_pedido = pi.id_pedido inner join produto prod on pi.id_produto = prod.id_produto inner join categoria cat on prod.id_categoria = cat.id_categoria where cat.nome in ("monitores","software","fotografia");

-- exercício 39
select c.id_cliente, c.nome, c.email 
from cliente c left join pedido p on c.id_cliente = p.id_cliente 
where p.id_pedido is null;

select cat.id_categoria, cat.nome 
from categoria cat left join produto prod on cat.id_categoria = prod.id_categoria 
where prod.id_produto is null;

-- exercício 40
select c.nome as cliente, p.id_pedido, p.data_pedido, prod.nome as produto, cat.nome as categoria, pi.quantidade, pi.preco_unitario 
from cliente c inner join pedido p on c.id_cliente = p.id_cliente inner join pedido_item pi on p.id_pedido = pi.id_pedido inner join produto prod on pi.id_produto = prod.id_produto inner join categoria cat on prod.id_categoria = cat.id_categoria
order by p.data_pedido DESC limit 50;

select c.id_cliente, c.nome as cliente, p.id_pedido 
from cliente c left join pedido p on c.id_cliente = p.id_cliente union select c.id_cliente, c.nome as cliente, p.id_pedido
from pedido p right join cliente c on c.id_cliente = p.id_cliente;
