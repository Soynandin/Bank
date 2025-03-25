#!/bin/sh
set -e

echo "Configurando ambiente..."
export PGHOST=db
export PGUSER=postgres
export PGPASSWORD=postgres
export PGDATABASE=banana_bank

# Certificar-se de que todas as dependências estão instaladas e bloqueadas
echo "Instalando dependências..."
mix deps.get
mix deps.compile

# Aguardar o banco de dados estar pronto
echo "Aguardando o banco de dados em $PGHOST:5432..."
while ! pg_isready -h $PGHOST -p 5432 -U $PGUSER; do
  sleep 1
done
echo "Banco de dados está pronto!"

# Criar e migrar o banco de dados se necessário
echo "Configurando banco de dados..."
mix ecto.create
mix ecto.migrate

echo "Iniciando Phoenix em 0.0.0.0:$PORT..."
# Inicie a aplicação Phoenix
exec mix phx.server 