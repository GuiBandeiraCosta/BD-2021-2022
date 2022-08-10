DROP TABLE IF EXISTS vendas;

CREATE TABLE vendas(
    ean CHAR(16) NOT NULL,
    cat VARCHAR(80) NOT NULL,
    dia_mes SMALLINT CHECK (dia_mes < 32 and dia_mes > 0),
    trimestre SMALLINT CHECK (trimestre < 5 and trimestre > 0),
    dia_semana SMALLINT CHECK (dia_semana < 8 and dia_semana > 0),
    mes SMALLINT CHECK (mes < 13 and mes > 0),
    ano int,
    distrito VARCHAR(40) NOT NULL,
    concelho VARCHAR(40) NOT NULL,
    unidades INTEGER NOT NULL,
    PRIMARY KEY (ean,cat)
);

INSERT INTO vendas(
SELECT p.ean, c.nome, d.dia, d.tr, d.semana, d.mes, d.ano, pr.distrito, pr.concelho, e.unidades
FROM produto AS p, categoria AS c, 
	SELECT(
	EXTRACT (DAY FROM instante) AS DAY FROM evento_reposicao AS dia,
	EXTRACT (QUARTER FROM instante) AS QUARTER FROM evento_reposicao AS tr,
	EXTRACT (ISODOW FROM instante) AS ISODOW FROM evento_reposicao AS semana,
	EXTRACT (MONTH FROM instante) AS MONTH FROM evento_reposicao AS mes,
	EXTRACT (YEAR FROM instante) AS YEAR FROM evento_reposicao AS ano
	FROM evento_reposicao AS d),
	ponto_de_retalho AS pr, evento_reposicao AS e;
)
	
