import os
import time
import psycopg2
import random
from datetime import datetime

# Configuração do banco de dados via variáveis de ambiente
DB_HOST = os.getenv("POSTGRES_HOST", "db")
DB_USER = os.getenv("POSTGRES_USER", "user")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD", "password")
DB_NAME = os.getenv("POSTGRES_DB", "workshopdb")

# Dados para geração aleatória
PRODUTOS = {
    'Eletrônicos': ['Laptop X1', 'Smartphone Z', 'Fone TWS', 'Smartwatch V5'],
    'Livros': ['A Arte da Guerra', 'Guia do Mochileiro', 'Sapiens', 'Duna'],
    'Casa': ['Lâmpada Smart', 'Cadeira Gamer', 'Mesa Digitalizadora', 'Cafeteira'],
}
CATEGORIAS = list(PRODUTOS.keys())

def get_db_connection():
    while True:
        try:
            conn = psycopg2.connect(
                host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASSWORD
            )
            return conn
        except psycopg2.OperationalError as e:
            print(f"Conexão falhou: {e}. Tentando novamente em 5s...", flush=True)
            time.sleep(5)

conn = get_db_connection()
print("Conexão com o banco estabelecida. Iniciando injeção de dados.", flush=True)

while True:
    try:
        with conn.cursor() as cur:
            categoria = random.choice(CATEGORIAS)
            produto = random.choice(PRODUTOS[categoria])
            preco = random.randint(5000, 250000)  # Gera preço em centavos (50.00 a 2500.00)
            qtd = random.randint(1, 5)
            data_venda = datetime.now()

            cur.execute(
                "INSERT INTO vendas (produto, categoria, preco_unitario, quantidade, data_venda) VALUES (%s, %s, %s, %s, %s);",
                (produto, categoria, preco, qtd, data_venda)
            )
            conn.commit()
            print(f"INSERT: {data_venda} | {produto}", flush=True)
            
    except (Exception, psycopg2.Error) as error:
        print(f"Erro na inserção: {error}. Reconectando...", flush=True)
        if conn:
            conn.close()
        conn = get_db_connection()
        
    time.sleep(0.5)