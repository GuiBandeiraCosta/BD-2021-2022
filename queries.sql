/* a) Qual o name do retalhista (ou retalhistas) responsáveis pela reposição do maior número de
categorias? */

SELECT nome FROM retalhista NATURAL JOIN responsavel_por
GROUP BY tin
HAVING COUNT(*) >= ALL
(SELECT COUNT(*)
 FROM responsavel_por
 GROUP BY tin);

/* b) Qual o name do ou dos retalhistas que são responsáveis por todas as categorias simples? */

SELECT DISTINCT r.nome
FROM retalhista AS r
WHERE NOT EXISTS (
    SELECT c.nome
    FROM categoria_simples AS c
    EXCEPT
    SELECT nome_cat
    FROM (categoria_simples c1 INNER JOIN responsavel_por on responsavel_por.nome_cat = c1.nome) AS join1
    WHERE r.tin = join1.tin);

/* c) Quais foram os produtos que nunca foram repostos? */
SELECT ean FROM produto WHERE ean NOT IN (SELECT ean FROM evento_reposicao);

/* d) Quais os produtos (ean) que foram repostos sempre pelo mesmo retalhista? */
SELECT ean FROM evento_reposicao GROUP BY ean HAVING COUNT(DISTINCT tin) = 1;