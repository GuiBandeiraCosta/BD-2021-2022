SELECT dia_semana, concelhor, SUM(unidades) AS total
FROM vendas
WHERE
    '30/05/2001' < CONTACT (CAST(dia_mes AS VARCHAR), '/', CAST(mes AS VARCHAR), '/', CAST(anos AS VARCHAR))
    AND
    CONTACT (CAST(dia_mes AS VARCHAR), '/', CAST(mes AS VARCHAR), '/', CAST(anos AS VARCHAR)) < '21/12/2023'
GROUP BY
    GROUPING SETS ((dia_semana), (concelho), ());


SELECT concelho. cat. dia_semana, SUM(unidades) AS total_vendidos
FROM vendas
WHERE
    distrito = 'lisboa'
GROUP BY
    GROUPING SETS ((concelho), (cat), (dia_semana), ());
