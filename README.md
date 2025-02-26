# BananaBank

**BananaBank** é uma aplicação simples para gerenciamento de usuários. Permite criar, atualizar, mostrar e excluir usuários.

## Rotas da API

Aqui estão as rotas disponíveis:

- `GET /api`: Retorna uma mensagem de boas-vindas.
- `GET /api/users/:id`: Exibe os dados de um usuário específico pelo `id`.
- `POST /api/users`: Cria um novo usuário.
- `PATCH /api/users/:id`: Atualiza parcialmente os dados de um usuário.
- `PUT /api/users/:id`: Atualiza completamente os dados de um usuário.
- `DELETE /api/users/:id`: Exclui um usuário.

## Testando as rotas

Para visualizar todas as rotas da API, basta rodar o seguinte comando:

```sh
mix phx.routes
```

## Estrutura de Pastas

A estrutura do projeto é bem organizada e segue o padrão do Phoenix. Aqui estão as principais pastas e o que cada uma contém:

- **`lib/banana_bank_web/`**: Contém a camada da interface (controller, views e router).
  - **`controllers/`**: Responsável por lidar com as requisições HTTP. Aqui você vai encontrar o `UsersController` que gerencia as rotas relacionadas aos usuários.
  - **`views/`**: Define como os dados são retornados nas respostas (formatação JSON, por exemplo). O módulo `UsersJSON` faz isso para os usuários.
  - **`router.ex`**: Aqui estão definidas as rotas da aplicação. A API usa o formato RESTful para o gerenciamento dos usuários.
  
- **`lib/banana_bank/`**: Contém a lógica de negócios, como os módulos que interagem com o banco de dados.
  - **`users/`**: Aqui ficam as operações relacionadas ao gerenciamento dos usuários (criação, atualização, exclusão, etc.). O módulo `Create`, `Update`, `Delete`, `Get` são responsáveis pelas ações correspondentes.
  - **`repo.ex`**: Gerencia a conexão com o banco de dados (geralmente o PostgreSQL ou outro banco relacional).

### Como Funciona

1. **Criação de Usuário**: Quando uma requisição POST é feita para `/api/users`, o controller chama o módulo `Users.Create`, que usa o **Changeset** do `User` para validar e persistir o novo usuário no banco de dados.

2. **Leitura de Usuário**: Quando uma requisição GET é feita para `/api/users/:id`, o `Users.Get` é chamado. Ele tenta encontrar o usuário pelo ID e retorna as informações se o usuário existir.

3. **Atualização de Usuário**: Para atualizar um usuário, o sistema utiliza os módulos `Users.Update`. Ele busca o usuário pelo ID e aplica os novos dados fornecidos na requisição, validando e persistindo as mudanças.

4. **Exclusão de Usuário**: Quando o usuário envia uma requisição DELETE para `/api/users/:id`, o `Users.Delete` é chamado para excluir o usuário do banco.

5. **Falhas e Erros**: Se ocorrer um erro, o sistema retorna mensagens apropriadas. Caso o usuário não seja encontrado (como no caso de um GET ou DELETE com ID inválido), a resposta será um erro 404 com a mensagem "Usuário não encontrado". Se os dados passados para criação ou atualização não forem válidos, a resposta será um erro de validação com as mensagens de erro.

### Banco de Dados

A aplicação usa o **Ecto** para interagir com o banco de dados. As migrações do Ecto são usadas para criar e modificar tabelas de banco de dados. A tabela de usuários armazena os seguintes campos:

- `id`: Identificador único do usuário (chave primária).
- `name`: Nome do usuário.
- `email`: E-mail do usuário.
- `cep`: CEP do usuário.