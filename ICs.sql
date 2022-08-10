DROP trigger IF EXISTS verifica_numero_repostas ON evento_reposicao;

CREATE OR replace FUNCTION verifica_numero_repostas_trigger_proc () RETURNS trigger AS $$
BEGIN

    IF new.unidades > (SELECT unidades FROM planograma WHERE planograma.ean = new.ean) THEN
        RAISE EXCEPTION 'O número de unidades repostas num Evento de Reposição não pode exceder o número de unidades especIFicado no Planograma';

    END IF;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION verifica_categoria() RETURNS TRIGGER AS
$$

DECLARE 
	cat_prateleira VARCHAR(80);
	cat_produto VARCHAR(80);
	cat VARCHAR(80);
	flag INTEGER := 0;
	
BEGIN
	SELECT nome
	INTO cat_prateleira
	FROM prateleira
	WHERE nro = NEW.nro AND num_serie = NEW.num_serie AND fabricante = NEW.fabricante;
	
	SELECT nome INTO cat_produto
	FROM tem_categoria
	WHERE ean = NEW.ean;
	
	SET cat = cat_produto;
	
	WHILE cat IS NOT NULL THEN
		IF cat == cat_prateleira THEN
			SET flag = flag + 1;
		END IF;
		SELECT super_categoria INTO cat
		FROM tem_outra
		WHERE categoria = cat;
		
	END LOOP;
	
	IF flag == 0 THEN
		RAISE EXCEPTION 'Um Produto só pode ser reposto numa Prateleira que apresente (pelo menos) uma das Categorias desse produto';

	END IF;
END;
$$ LANGUAGE plpgsql;
	
		
