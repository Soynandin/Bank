# Use a imagem oficial do Elixir como base
FROM elixir:1.14-alpine

# Instale as dependências do sistema
RUN apk add --no-cache build-base git python3 curl postgresql-client

# Crie o diretório da aplicação
WORKDIR /app

# Copie apenas o arquivo mix.exs e mix.lock primeiro
COPY mix.exs mix.lock ./

# Instale as ferramentas Elixir
RUN mix local.hex --force && \
  mix local.rebar --force

# Copie o resto dos arquivos do projeto
COPY . .

# Tornando o script de entrada executável
RUN chmod +x /app/docker-entrypoint.sh

# Instale o Phoenix
RUN mix archive.install hex phx_new --force

# Exponha a porta 4000
EXPOSE 4000

# Use o script de entrada para inicializar o container
ENTRYPOINT ["/app/docker-entrypoint.sh"] 