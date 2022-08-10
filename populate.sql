DROP TABLE IF EXISTS evento_reposicao ;
DROP TABLE IF EXISTS responsavel_por ;
DROP TABLE IF EXISTS retalhista ;
DROP TABLE IF EXISTS planograma ;
DROP TABLE IF EXISTS prateleira ;
DROP TABLE IF EXISTS instalada_em ;
DROP TABLE IF EXISTS ponto_de_retalho ;
DROP TABLE IF EXISTS IVM ;
DROP TABLE IF EXISTS tem_categoria ;
DROP TABLE IF EXISTS produto ;
DROP TABLE IF EXISTS tem_outra ;
DROP TABLE IF EXISTS super_categoria ;
DROP TABLE IF EXISTS categoria_simples ;
DROP TABLE IF EXISTS categoria ;

CREATE TABLE categoria (
    nome VARCHAR(80) NOT NULL,
    PRIMARY KEY (nome)
);

CREATE TABLE categoria_simples (
    nome VARCHAR(80) NOT NULL,
    PRIMARY KEY (nome),
    FOREIGN KEY (nome) 
        REFERENCES categoria(nome) 
);

CREATE TABLE super_categoria (
    nome VARCHAR(80) NOT NULL,
    PRIMARY KEY (nome),
    FOREIGN KEY (nome) 
        REFERENCES categoria(nome) 
);

CREATE TABLE tem_outra (
    super_categoria VARCHAR(80) NOT NULL,
    categoria VARCHAR(80) NOT NULL,
    PRIMARY KEY (categoria),
    FOREIGN KEY (super_categoria) 
        REFERENCES super_categoria(nome) ,
    FOREIGN KEY (categoria) 
        REFERENCES categoria(nome),
    CHECK (super_categoria != categoria)
);

CREATE TABLE produto (
    ean CHAR(16) NOT NULL,
    cat VARCHAR(80) NOT NULL,
    descr VARCHAR(100),
    PRIMARY KEY (ean),
    FOREIGN KEY (cat) 
        REFERENCES categoria(nome)
);

CREATE TABLE tem_categoria (
    ean CHAR(16) NOT NULL,
    nome VARCHAR(80) NOT NULL,
    FOREIGN KEY (ean)
        REFERENCES produto(ean),
    FOREIGN KEY (nome) 
        REFERENCES categoria(nome)
);

CREATE TABLE IVM (
    num_serie INTEGER NOT NULL,
    fabricante VARCHAR(80) NOT NULL,
    PRIMARY KEY (num_serie, fabricante)
);

CREATE TABLE ponto_de_retalho (
    nome VARCHAR(80) NOT NULL,
    distrito VARCHAR(40) NOT NULL,
    concelho VARCHAR(40) NOT NULL,
    PRIMARY KEY (nome)
);

CREATE TABLE instalada_em (
    num_serie INTEGER NOT NULL,
    fabricante VARCHAR(80) NOT NULL,
    local_ VARCHAR(80) NOT NULL,
    PRIMARY KEY (num_serie, fabricante),
    FOREIGN KEY (num_serie, fabricante)
        REFERENCES IVM(num_serie, fabricante) ,
    FOREIGN KEY (local_) 
        REFERENCES ponto_de_retalho(nome) 
);

CREATE TABLE prateleira (
    nro INTEGER NOT NULL,
    num_serie INTEGER NOT NULL,
    fabricante VARCHAR(80) NOT NULL,
    altura DECIMAL,
    nome VARCHAR(80) NOT NULL,
    PRIMARY KEY (nro, num_serie, fabricante),
    FOREIGN KEY (num_serie, fabricante)
        REFERENCES IVM(num_serie, fabricante) ,
    FOREIGN KEY (nome) 
        REFERENCES categoria(nome) 
);

CREATE TABLE planograma (
    ean char(16) NOT NULL,
    nro INTEGER NOT NULL,
    num_serie INTEGER NOT NULL,
    fabricante VARCHAR(80) NOT NULL,
    faces INTEGER NOT NULL,
    unidades INTEGER NOT NULL,
    loc VARCHAR(80) NOT NULL,
    PRIMARY KEY (ean,nro, num_serie, fabricante),
    FOREIGN KEY (nro, num_serie, fabricante)
        REFERENCES prateleira(nro, num_serie, fabricante) ,
    FOREIGN KEY (ean) 
        REFERENCES produto(ean) 
);

CREATE TABLE retalhista (
    tin INTEGER NOT NULL,
    nome VARCHAR(80) NOT NULL,
    PRIMARY KEY (tin),
    CONSTRAINT RI_RE7
        UNIQUE(nome)
);

CREATE TABLE responsavel_por (
    nome_cat VARCHAR(80) NOT NULL,
    tin INTEGER NOT NULL,
    num_serie INTEGER NOT NULL,
    fabricante VARCHAR(80) NOT NULL,
    PRIMARY KEY (num_serie, fabricante),
    FOREIGN KEY (num_serie, fabricante)
        REFERENCES IVM(num_serie, fabricante) ,
    FOREIGN KEY (tin)
        REFERENCES retalhista(tin) ,
    FOREIGN KEY (nome_cat) 
        REFERENCES categoria(nome) 
);

CREATE TABLE evento_reposicao (
    ean char(16) NOT NULL,
    nro INTEGER NOT NULL,
    num_serie INTEGER NOT NULL,
    fabricante VARCHAR(80) NOT NULL,
    instante timestamp NOT NULL, 
    unidades INTEGER NOT NULL,
    tin INTEGER NOT NULL,
    PRIMARY KEY (ean, nro, num_serie, fabricante, instante),
    FOREIGN KEY (ean, nro, num_serie, fabricante)
        REFERENCES planograma(ean, nro, num_serie, fabricante) ,
    FOREIGN KEY (tin) 
        REFERENCES retalhista(tin) 
);





--SQL QUERY 1 e 2

INSERT INTO retalhista (tin, nome)
VALUES
(1, 'Gui'), --Mais Categorias / Responsavel por todas Simples
(2, 'Maria'), 
(3, 'Ricky'), 
(4, 'Jorge');


INSERT INTO categoria (nome)
VALUES
('Frutos Secos'),
('Talheres'),
('Facas'),
('Gomas'),
('Doces');

INSERT INTO categoria_simples (nome)
VALUES
('Frutos Secos'),
('Talheres'),
('Facas'),
('Gomas');

INSERT INTO super_categoria (nome)
VALUES
('Doces');

INSERT INTO IVM (num_serie, fabricante)
VALUES
(200, 'Light'),
(201, 'Yagami'),
(202, 'Naruto'),
(203, 'Uzumaki'),
(204,'Meruem'),
(205,'Gon'),
(206,'Killua');

INSERT INTO responsavel_por(nome_cat,tin,num_serie,fabricante)
VALUES
('Frutos Secos',1,200,'Light'),
('Talheres',1,201,'Yagami'),
('Facas',1,202,'Naruto'),
('Gomas',1,203,'Uzumaki'), 
('Doces',1,204,'Meruem'),
('Gomas',2,205,'Gon'), 
('Doces',2,206,'Killua');


--SQL QUERY 3 e 4

INSERT INTO produto(ean,cat,descr)
VALUES
(301,'Frutos Secos','Amendoim'), -- Reposto sempre pelo mesmo retalhista
(302,'Talheres','Garfo'), -- Reposto sempre pelo mesmo retalhista
(303,'Talheres','Faca'), -- Reposto sempre pelo mesmo retalhista
(304,'Gomas','Tijolos'); -- Nao é reposto


INSERT INTO prateleira(nro,num_serie,fabricante,altura,nome)
VALUES
(1000,200,'Light',3,'Frutos Secos'),
(1001,201,'Yagami',3,'Talheres'),
(1002,201,'Yagami',3,'Talheres'),
(1003,201,'Yagami',3,'Gomas');


INSERT INTO planograma(ean, nro, num_serie, fabricante, faces, unidades, loc)
VALUES
(301,1000,200,'Light',1,300,'China'),
(302,1001,201,'Yagami',1,300,'Swamp'),
(303,1002,201,'Yagami',1,300,'Leaf Village'),
(304,1003,201,'Yagami',1,300,'Shinobi World');



INSERT INTO evento_reposicao(ean, nro, num_serie, fabricante, instante, unidades, tin)
VALUES
(301,1000,200,'Light','2010-01-06 23:20:00',20,1),
(302,1001,201,'Yagami','2022-04-07 10:00:00',20,1),
(303,1002,201,'Yagami','2022-09-08 11:01:00',20,1);

--Extras
INSERT INTO tem_categoria(ean,nome)
VALUES
(301,'Frutos Secos'),
(302,'Talheres'),
(303,'Talheres'),
(304,'Gomas');

INSERT INTO tem_outra(super_categoria,categoria)
VALUES
('Doces','Gomas');

INSERT INTO ponto_de_retalho(nome,distrito,concelho)
VALUES
('IVM1','Lisboa','Lisboa'),
('IVM2','Ricky','Xu'),
('IVM3','Porto','Espanha'),
('IVM4','Coimbra','Holanda'),
('IVM5','Dark','Continent');

INSERT INTO instalada_em(num_serie,fabricante,local_)
VALUES
(200, 'Light','IVM1'),
(201, 'Yagami','IVM2'),
(202, 'Naruto','IVM3'),
(203, 'Uzumaki','IVM4'),
(204,'Meruem','IVM5');