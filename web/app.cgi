#!/usr/bin/python3
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request
import psycopg2
import psycopg2.extras

## SGBD configs
DB_HOST = "db.tecnico.ulisboa.pt"
DB_USER = "ist195586"
DB_DATABASE = DB_USER
DB_PASSWORD = "ola"
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (
    DB_HOST,
    DB_DATABASE,
    DB_USER,
    DB_PASSWORD,
)

app = Flask(__name__)
        
@app.route("/")
def change_categoria():
    try:
        return render_template("menu.html", params=request.args)
    except Exception as e:
        return str(e)

@app.route("/add")
def list_Categorias():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM categoria;"
        cursor.execute(query)
        return render_template("ListCategoria.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route("/sub_categoria")
def List_SuperCategoria():
    try:
        return render_template("Add_SubCategoria.html",params=request.args)
    except Exception as e:
        return str(e)  # Renders a page with the error.
  


@app.route("/add/sub_categoria", methods=["POST"])
def add_subcategoria():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        categoria = request.form["super_Categoria"]
        sub_categoria = request.form["sub_Categoria"]
        if(len(sub_categoria) == 0):
            return "ERRO: Nome pff"
        else: 
            query = "INSERT INTO categoria(nome) VALUES" + " ('" + sub_categoria + "'); "
            query += "DELETE FROM categoria_simples WHERE nome = " + "'" + categoria + "';\n"
            query += "INSERT INTO super_categoria(nome) VALUES" + " ('" + categoria + "') ON CONFLICT(nome) DO NOTHING;"
            query += "INSERT INTO categoria_simples(nome) VALUES" + " ('" + sub_categoria + "'); "
            query += "INSERT INTO tem_outra(super_categoria,categoria) VALUES" + " ('" + categoria + "','" + sub_categoria + "');"
        cursor.execute(query)
        return query
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()



@app.route("/add/categoria", methods=["POST"])
def add_categoria():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        categoria = request.form["Categoria"]
        if(len(categoria) == 0):
            return "ERRO: Nome pff"
        else:
                query = "INSERT INTO categoria(nome) VALUES" + " ('" + categoria + "'); "
                query += "INSERT INTO categoria_simples(nome) VALUES" + " ('" + categoria + "'); "
        cursor.execute(query)
        return query
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


@app.route("/remove", methods=["POST"])
def remove_categoria():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        categoria = request.form["Categoria"]
        query =  "DELETE FROM tem_outra WHERE super_categoria = " + "'" + categoria + "';\n"
        query += "DELETE FROM tem_outra WHERE categoria = " + "'" + categoria + "';\n"
        query += "DELETE FROM tem_categoria WHERE nome = " + "'" + categoria + "';\n"
        query += "DELETE FROM categoria_simples WHERE nome = " + "'" + categoria + "';\n"
        query += "DELETE FROM super_categoria WHERE nome = " + "'" + categoria + "';\n"
        query += "DELETE FROM categoria WHERE nome = " + "'" + categoria + "';"
        cursor.execute(query)
        return query
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


@app.route("/retalhista")
def list_Retalhistas():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM produto;"
        cursor.execute(query)
        produto = cursor.fetchall()
        query = "SELECT * FROM retalhista;"
        cursor.execute(query)
        retalhista = cursor.fetchall()
        query = "SELECT * FROM responsavel_por;"
        cursor.execute(query)
        responsavel_por = cursor.fetchall()
        return render_template("ListRetalhista.html", produto=produto,retalhista = retalhista,responsavel_por= responsavel_por)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route("/add/retalhista", methods=["POST"])
def add_Retalhista():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        tin_retalhista = request.form["tin_Retalhista"]
        nome_retalhista = request.form["nome_Retalhista"]       
        produtos = request.form["Produtos"]

        if(len(nome_retalhista) == 0 or len(tin_retalhista) == 0):
            return "ERRO: Algum argumento do Retalhista em falta"
        elif(len(produtos) == 0):
            query = "INSERT INTO retalhista(tin,nome) VALUES" + " (" + tin_retalhista + ",'" + nome_retalhista + "');"
        else:
            query = "INSERT INTO retalhista(tin,nome) VALUES" + " (" + tin_retalhista + ",'" + nome_retalhista + "');"
            produtos_split = produtos.split("/")
            for produto in produtos_split:
                query += "INSERT INTO responsavel_por(nome_cat,tin,num_serie,fabricante) SELECT p.cat,"
                query +=  tin_retalhista + ",pg.num_serie,pg.fabricante FROM produto p, planograma pg WHERE p.ean = '" 
                query +=  produto + "' AND pg.ean = '" + produto + "';"     
        cursor.execute(query)
        return query
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route("/remove/retalhista", methods=["POST"])
def remove_Retalhista():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        tin_retalhista = request.form["tin_Retalhista"]
        if(len(tin_retalhista) == 0):
            return "ERRO: Algum argumento do Retalhista em falta"
        else:
            query =  "DELETE FROM evento_reposicao WHERE tin = " + tin_retalhista +";"
            query += "DELETE FROM responsavel_por WHERE tin = " + tin_retalhista +";"
            query += "DELETE FROM retalhista WHERE tin = " + tin_retalhista +";"
        cursor.execute(query)
        return query
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()



@app.route("/ivm")
def list_Ivm():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM IVM;"
        cursor.execute(query)
        return render_template("ListIvm.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route("/list_evento", methods=["POST"])
def list_evento():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        num_serie = request.form["num_serie"]
        fabricante = request.form["fabricante"]
        query = "SELECT nome,SUM(unidades) from evento_reposicao NATURAL JOIN tem_categoria WHERE fabricante = '" + fabricante +"' AND num_serie = "+ num_serie + "GROUP BY nome ;"
        cursor.execute(query)
        return render_template("ListEvento.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route("/sub_categorias")
def list_Super_Categorias():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM super_categoria;"
        cursor.execute(query)
        super_categoria = cursor.fetchall()
        query = "SELECT * FROM tem_outra;"
        cursor.execute(query)
        tem_outra = cursor.fetchall()
        return render_template("ListSuperCategorias.html", super_categoria=super_categoria, tem_outra=tem_outra)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route("/list/sub_categorias", methods=["POST"])
def list_Sub_Categorias():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        super_categoria = request.form["super_categoria"]
        query = "SELECT categoria FROM tem_outra t WHERE t.super_categoria = '" + super_categoria + "';"
        cursor.execute(query)
        list = cursor.fetchall()
        list3 = []
        flat_list = []
        flat_list2 = []
        for xs in list:
            for x in xs:
                flat_list.append(x)
                flat_list2.append(x)
        while True:
            i=0
            for x in range(len(flat_list)):
                query2 = "SELECT * FROM super_categoria s WHERE s.nome = '" + str(flat_list[x]) + "';"
                cursor.execute(query2)
                list2 = cursor.fetchall()
                if [flat_list2[x-i]] not in list3:
                    list3.append([flat_list2[x-i]])
                if len(list2) == 0:
                    flat_list2.pop(x-i)
                    i+=1
            flat_list = flat_list2.copy()
            if len(flat_list) == 0:
                break
            query += "SELECT categoria FROM tem_outra t WHERE t.super_categoria = '" + str(flat_list[0]) + "';"
            cursor.execute(query)
            list=cursor.fetchall()
            for xs in list:
                for x in xs:
                    flat_list.append(x)
            if [flat_list[0]] not in list3:
                list3.append([flat_list[0]])
            flat_list.pop(0)
            flat_list2 = flat_list.copy()

        return render_template("List_SubCategorias.html", cursor=list3)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

CGIHandler().run(app)



