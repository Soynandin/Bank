# BananaBank

**BananaBank** é uma aplicação simples para gerenciamento de usuários. Permite criar, atualizar, mostrar e excluir usuários.

---

## Rotas da API
Para o consumo com **GraphQL** todos os dados são manipulados através de queries (consultas) e mutations (mutações) no formato GraphQL.

Endpoint: `POST /graphql`

Para testar as rotas, você pode usar a interface interativa GraphiQL para as consultas GraphQL:
GraphiQL: Acesse `http://localhost:4000/graphiql` para testar suas queries e mutations de forma interativa.

Para o consumo **Rest** as rotas são:

- `GET /api`: Retorna uma mensagem de boas-vindas.
- `GET /api/users/:id`: Exibe os dados de um usuário específico pelo `id`.
- `POST /api/users`: Cria um novo usuário.
- `PATCH /api/users/:id`: Atualiza parcialmente os dados de um usuário.
- `PUT /api/users/:id`: Atualiza completamente os dados de um usuário.
- `DELETE /api/users/:id`: Exclui um usuário.

---

## Testando as rotas

Para visualizar todas as rotas da API, basta rodar o seguinte comando:

```sh
mix phx.routes
```

---

## 🗂 Estrutura de Pastas

A estrutura do projeto é organizada e segue boas práticas do Phoenix, além de ser adaptada para suportar **GraphQL**. Aqui está uma visão geral das principais pastas e seus conteúdos:

### 📂 `lib/banana_bank_web/`

Contém a camada de interface, incluindo controllers, resolvers, middlewares, plugs e o router.

- **`controllers/`**: Responsável por lidar com as requisições HTTP REST, como as rotas CRUD para o gerenciamento de usuários. 
  - **`UsersController`** gerencia as operações como criar, atualizar, mostrar e excluir usuários.
  - **`auth_error_handler.ex`**: Manipula erros de autenticação.
  - **`error_json.ex`**: Define a estrutura de resposta para erros.
  - **`fallback_controller.ex`**: Define respostas padrão para erros.
  
- **`resolvers/`**: Esta pasta contém os módulos de resolução para o **GraphQL**. Cada resolver é responsável por implementar a lógica de negócios associada a uma consulta ou mutação.

  - **`auth_resolver.ex`**: Lida com autenticação e geração de tokens, incluindo:
    - **`login/3`**: Realiza a autenticação do usuário e retorna tokens.
    - **`refresh_token/3`**: Atualiza o token de acesso usando um token de refresh.
    - **`logout/3`**: Revoga o token de autenticação e finaliza a sessão do usuário.

  - **`user_resolver.ex`**: Contém a lógica para resolver as consultas e mutações relacionadas aos usuários, como:
    - **`list_users/3`**: Resolve a consulta para listar os usuários com parâmetros de paginação e ordenação.
    - **`get_user/3`**: Resolve a consulta para buscar um usuário específico pelo `id`.
    - **`create_user/3`**: Resolve a mutação para criar um novo usuário.
    - **`update_user/3`**: Resolve a mutação para atualizar os dados de um usuário.
    - **`delete_user/3`**: Resolve a mutação para deletar um usuário.

- **`middleware/`**: Contém middlewares para controle de autenticação e extração de tokens.
  - **`authenticate.ex`**: Middleware de autenticação para proteger rotas.
  - **`extract_refresh_token.ex`**: Middleware para extração de tokens de refresh.

- **`plugs/`**: Contém os plugs usados na autenticação.
  - **`auth_pipeline.ex`**: Define o pipeline de autenticação usando Guardian.

- **`schema.ex`**: Define o esquema do GraphQL, incluindo as consultas e mutações. Este arquivo conecta as consultas/mutações aos respectivos resolvers.

- **`router.ex`**: Contém a definição das rotas da aplicação. Para o **REST**, está configurada para o gerenciamento de usuários. Também define as rotas para o **GraphQL** (`/graphql` e `/graphiql`).

### 📂 `lib/banana_bank/`

Contém a lógica de negócios e interações com o banco de dados.

- **`auth/`**: Gerencia autenticação e autorização.
  - **`auth.ex`**: Lógica central de autenticação.
  - **`guardian.ex`**: Implementação do Guardian para autenticação JWT.

- **`users/`**: Contém os módulos para as operações de negócios relacionadas ao gerenciamento de usuários.
  - **`create.ex`**: Responsável pela criação de um novo usuário, incluindo validações.
  - **`update.ex`**: Responsável pela atualização de dados de usuários.
  - **`delete.ex`**: Responsável pela exclusão de usuários.
  - **`get.ex`**: Responsável pela busca de usuários, seja para exibição ou manipulação.
  - **`get_by_email.ex`**: Busca de usuários por e-mail.
  - **`list.ex`**: Listagem de usuários.
  - **`user.ex`**: Define o schema do usuário.
  
- **`application.ex`**: Configuração principal da aplicação.
- **`repo.ex`**: Gerencia a interação com o banco de dados (geralmente usando o **Ecto**). Ele é responsável pela configuração da conexão e pelas migrações.
- **`users.ex`**: Contexto que agrupa as operações do módulo users/.

### 📂 `priv/repo/migrations/`

Contém as migrações do banco de dados. Essas migrações são usadas para criar e modificar as tabelas no banco de dados.

- **`20250313151851_create_users_table.exs`**: Define a tabela de usuários no banco de dados com campos como `first_name`, `last_name`, `email`, `password_hash`, `document` e `role`.

---

### 📝 Como Funciona

O gerenciamento de usuários na aplicação segue o modelo de **GraphQL** para interagir com os dados. Cada operação de criação, leitura, atualização e exclusão é tratada por resolvers específicos. Aqui está um detalhamento de como cada operação funciona, incluindo validações e tratamentos de erro:

#### 1. **Listar Usuários**
Quando uma requisição de listagem de usuários é feita via **GraphQL**, o resolver `UserResolver.list_users/3` é chamado. Esse resolver invoca o módulo **`Users.List`** para buscar todos os usuários com os parâmetros de **paginações** e **ordenação**. A consulta é feita através do Ecto com os seguintes parâmetros:
- **`limit`**: Limite de usuários retornados (padrão: 10).
- **`offset`**: Deslocamento de resultados para paginação (padrão: 0).
- **`order_by`**: Coluna para ordenação (padrão: "name").
- **`direction`**: Direção da ordenação (padrão: "asc").

#### 2. **Obter Usuário**
Para buscar um usuário específico, o resolver **`UserResolver.get_user/3`** é invocado. Este resolver chama o módulo **`Users.Get`**, que tenta buscar o usuário no banco com base no **ID** fornecido. O processo de busca segue o seguinte fluxo:
- Se o ID for inválido (não numérico), retorna um erro: `"Invalid ID format"`.
- Se o usuário não for encontrado, retorna um erro 404: `"User not found"`.
- Caso contrário, retorna os dados do usuário solicitado.

#### 3. **Criar Usuário**
Para criar um usuário, o resolver **`UserResolver.create_user/3`** chama o módulo **`Users.Create`**, que aplica as validações usando o **Changeset**:
- Valida se todos os parâmetros obrigatórios estão presentes: `first_name`, `last_name`, `email`, `password`, `document` e `role`.
- O campo `email` é validado com um formato específico.
- O campo `role` é validado para aceitar apenas os valores "client", "agency" ou "admin".
- A senha é criptografada utilizando **Pbkdf2** antes de ser armazenada no banco de dados.
- O campo `document` é validado para garantir que seja um CPF ou CNPJ válido, utilizando a biblioteca **Brcpfcnpj**. Caso o documento não seja válido, é retornado um erro."
- Caso algum erro de validação ocorra, ele é retornado como uma mensagem clara de erro com os campos falhos.

#### 4. **Atualizar Usuário**
Para atualizar um usuário, o resolver **`UserResolver.update_user/3`** chama o módulo **`Users.Update`**. O processo de atualização segue os seguintes passos:
- Valida se o usuário existe, se não, retorna erro: `"User not found"`.
- Aplica as alterações usando o **Changeset**, onde apenas os campos `first_name`, `last_name`, `email`, `document` e `role` são obrigatórios para a atualização parcial.
- Se a atualização for bem-sucedida, os dados do usuário são retornados.
- Se houver erros de validação, uma mensagem com detalhes do erro será retornada.
**Importante**: A aplicação de alterações no campo role é restrita. Somente administradores podem alterar o campo role para admin. Usuários com a role client ou agency não podem se promover a admin.

#### 5. **Excluir Usuário**
Para excluir um usuário, o resolver **`UserResolver.delete_user/3`** invoca o módulo **`Users.Delete`**:
- A operação tenta excluir o usuário pelo **ID**.
- Se o usuário não for encontrado, retorna um erro: `"User not found"`.
- Se a exclusão for bem-sucedida, retorna uma mensagem de sucesso.

#### 6. **Tratamento de Erros**
Em todas as operações, caso ocorra um erro, a aplicação garante que a resposta seja informativa:
- **Erro de ID inválido**: Caso um ID fornecido não seja um número válido, o sistema retornará `"Invalid ID format"`.
- **Erro de usuário não encontrado**: Se a busca ou exclusão de um usuário não encontrar o usuário no banco, retornará `"User not found"`.
- **Erros de validação**: Se os dados enviados para a criação ou atualização de um usuário não forem válidos, o sistema retornará uma mensagem com detalhes sobre o erro em cada campo específico.

#### 7. **Validações Específicas**
A validação de dados do usuário segue as seguintes regras:
- **`first_name`** e **`last_name`**: Campos obrigatórios para a criação e atualização do usuário.
- **`email`**: Validado com uma expressão regular que garante um formato correto de e-mail. Caso o e-mail já exista no banco de dados, será retornado um erro de unicidade.
- **`document`**: Campo obrigatório e validado para garantir que seja um CPF ou CNPJ válido. Caso o documento fornecido não seja válido, será retornado um erro: "Documento inválido. Insira um CPF ou CNPJ válido.".
- **`role`**: O campo de role só pode ter os valores "client", "agency" ou "admin". Além disso, para atualização, um usuário com o papel de "client" ou "agency" não pode ser promovido a "admin", ou seja, a mudança para o papel "admin" é restrita a administradores.
- **`password`**: A senha é tratada de forma segura, sendo convertida para um hash com Pbkdf2 antes de ser salva no banco de dados. A senha só será validada e processada quando fornecida no processo de criação ou atualização de usuário.

### **Adendo para o password**
### Dinâmica de Senha

A aplicação utiliza o algoritmo **Pbkdf2** para armazenar as senhas de forma segura. A senha do usuário não é armazenada diretamente no banco de dados; em vez disso, é gerado um **hash** da senha.

- O campo `password` é virtual e usado para receber a senha.
- O campo `password_hash` armazena o **hash** da senha no banco de dados.

Durante a criação ou atualização do usuário, a senha fornecida é processada e convertida em um **hash** seguro utilizando **Pbkdf2**. O hash gerado é armazenado no banco de dados, nunca a senha em texto claro.

O uso do **Pbkdf2** impede que a senha em texto claro seja exposta, tornando o sistema mais seguro contra ataques.

---

### Banco de Dados

A aplicação utiliza o **Ecto** para interagir com o banco de dados, usando o **PostgreSQL** como sistema de gerenciamento de banco de dados. O Ecto é responsável por fornecer uma camada de abstração sobre o banco, facilitando operações como inserção, consulta, atualização e exclusão de dados. Além disso, o Ecto lida com migrações para criar e modificar tabelas, mantendo a estrutura do banco consistente ao longo do tempo.

#### Estrutura do Banco de Dados

- **BananaBank.Repo**: É o módulo principal que interage diretamente com o banco de dados. Ele utiliza o adaptador do **Ecto.Adapters.Postgres** para conectar-se ao banco de dados PostgreSQL. O módulo é responsável por configurar as conexões e executar as consultas Ecto.

#### Aplicação e Repositório

O módulo **BananaBank.Application** é o ponto de entrada da aplicação, onde o **BananaBank.Repo** é iniciado e supervisionado. Ele também inicia outros processos, como o Telemetry para monitoramento de desempenho e o **Phoenix.Endpoint** para servir as requisições web.

#### Phoenix Endpoint

O **BananaBankWeb.Endpoint** é responsável por servir as requisições HTTP, incluindo o gerenciamento de sessões e recursos estáticos. Ele também configura as ferramentas necessárias para o **Phoenix LiveView**, **Absinthe (para GraphQL)** e outras dependências de middleware, como o **Phoenix.CodeReloader** e **Plug**.

#### Como as Migrações Funciona?

As migrações são gerenciadas pelo **Ecto.Migration**. Elas permitem criar e modificar tabelas no banco de dados. Em sua aplicação, você pode definir migrações para criar tabelas, como a tabela `users`, que contém os seguintes campos:
- **`id`**: Identificador único do usuário (chave primária).
- **`first_name`**: Primeiro nome do usuário.
- **`last_name`**: Sobrenome do usuário.
- **`email`**: E-mail do usuário.
- **`password_hash`**: Armazena o hash da senha.
- **`document`**: Documento de identificação do usuário (ex: CPF ou CNPJ).
- **`role`**: Função do usuário na aplicação (ex: "client" ou "agency").
- **`timestamps`**: Campos para armazenar data de criação e atualização.

#### Relacionamento entre Módulos

A aplicação utiliza o padrão de **Repositórios** para separar as interações com o banco de dados. O **BananaBank.Repo** é o responsável por acessar diretamente as tabelas no banco. Cada módulo do sistema (como `Users.Create`, `Users.Update`, `Users.Get`, etc.) utiliza este repositório para realizar operações como criação, leitura, atualização e exclusão de usuários, enquanto o Ecto gerencia as transações e validações.

#### Conexão com o Banco de Dados

A conexão com o banco é configurada no arquivo de ambiente, permitindo que a aplicação se conecte ao banco PostgreSQL de maneira eficiente. O **BananaBank.Repo** é configurado para usar o adaptador **PostgreSQL**, permitindo realizar todas as operações necessárias de forma segura e eficiente.

---

## Autenticação de Usuários
A autenticação na sua API é baseada no uso de tokens JWT (JSON Web Tokens), combinados com um refresh token para manter a sessão ativa de maneira segura, sem a necessidade de o usuário fazer login repetidamente. O processo de autenticação envolve a verificação das credenciais do usuário, a criação de tokens para acesso e a possibilidade de renovar esses tokens quando expiram, tudo isso implementado usando o módulo Guardian para gerenciamento de tokens.

1. Verificação de Credenciais de Login
Quando um usuário tenta se autenticar, ele fornece seu e-mail e senha. O processo de autenticação segue estes passos:

  - Busca pelo Usuário: A API primeiro verifica se o usuário existe no banco de dados, buscando o e-mail fornecido.
  - Verificação de Senha: Após localizar o usuário, a senha fornecida é comparada com a senha armazenada. A senha não é armazenada em texto claro, mas sim como um hash seguro, usando o algoritmo Pbkdf2. Isso garante que mesmo se alguém acessar a base de dados, as senhas não possam ser facilmente obtidas.

Se a senha não for válida, a autenticação falha e um erro é retornado.

2. Geração de Tokens (Access Token e Refresh Token)
Uma vez que as credenciais do usuário sejam validadas, a API gera dois tipos de tokens:

Access Token (Token de Acesso): Este é o principal token utilizado para autenticar as requisições do usuário. Ele tem um tempo de vida curto (geralmente 15 minutos) e é usado para garantir que as requisições subsequentes do usuário sejam feitas de maneira segura. O token é assinado com informações do usuário, de forma que, quando incluído no cabeçalho de uma requisição (geralmente no formato "Bearer token"), ele pode ser verificado para garantir que a requisição é legítima.

Refresh Token (Token de Renovação): O refresh token é usado para renovar o access token quando ele expira, sem que o usuário precise fazer login novamente. O refresh token tem um tempo de vida mais longo (geralmente 7 dias). Ele é armazenado de forma segura e pode ser usado para obter um novo access token, garantindo uma experiência contínua para o usuário.

Esses dois tokens são retornados para o cliente logo após a autenticação ser bem-sucedida.

3. Uso de Tokens nas Requisições
Quando o usuário faz requisições autenticadas, ele deve enviar o access token no cabeçalho de autorização (normalmente como "Authorization: Bearer {token}"). A API, ao receber esse token, realiza os seguintes passos para verificar a autenticidade da requisição:

  - Decodificação e Verificação do Token: A API usa o módulo Guardian para decodificar e verificar se o access token é válido. Isso envolve a validação da assinatura do token e a verificação de que ele não expirou.
  - Carregamento de Dados do Usuário: Após verificar que o token é válido, a API pode acessar os dados do usuário, como seu ID, papel (role) e outros dados associados, para garantir que ele tem permissão para realizar a ação solicitada.

Se o token for inválido ou expirado, a requisição é rejeitada com um erro de "não autorizado".

4. Renovação do Access Token
Quando o access token expira, o cliente pode utilizar o refresh token para obter um novo access token sem precisar que o usuário faça login novamente.

Verificação do Refresh Token: A API valida o refresh token usando o Guardian, verificando sua integridade e se ele está dentro do seu período de validade. Se o refresh token for válido, a API gera um novo access token e o retorna ao usuário, junto com o refresh token original (caso ele ainda seja válido). Caso contrário, o processo de renovação falha e um erro é retornado.

5. Revogação de Tokens
Se o usuário fizer logout ou o refresh token precisar ser revogado por algum motivo (por exemplo, em caso de violação de segurança ou mudança de senha), a API pode revogar todos os refresh tokens associados à sessão do usuário. Isso faz com que os tokens anteriores se tornem inválidos, e o usuário precise fazer login novamente para obter novos tokens.

6. Middleware e Controle de Acesso
Para garantir que apenas usuários autenticados possam acessar determinadas rotas, a API utiliza middleware para verificar se o usuário está autenticado antes de permitir o acesso. Esse middleware verifica se o contexto da requisição contém informações sobre o usuário autenticado (geralmente extraídas do token) e, se não, retorna um erro de "não autorizado".

Além disso, a API usa o contexto para garantir que o usuário autenticado tenha acesso às informações e funcionalidades apropriadas. Por exemplo, no GraphQL, o middleware de autenticação é usado para garantir que o usuário tenha um contexto válido antes de acessar qualquer dado.

7. Logout e Encerramento de Sessão
O processo de logout envolve a revogação do refresh token. Quando um usuário decide sair, o refresh token que estava sendo usado para autenticar a sessão é revogado, tornando todos os tokens anteriores inválidos. Isso efetivamente encerra a sessão do usuário e impede o uso de tokens antigos.

---

## Testando o CRUD no GraphQL

### 🟢 1. Criar um Usuário (`create_user`)
```graphql
mutation {
  createUser(
    firstName: "João"
    lastName: "Silva"
    email: "joao.silva@example.com"
    password: "senha123"
    document: "12345678900"
    role: "client"
  ) {
    id
    firstName
    lastName
    email
    document
    role
  }
}
```

### 🔵 2. Listar Usuários (`users`)
```graphql
query {
  users(limit: 5, offset: 0, orderBy: "first_name", direction: "asc") {
    id
    firstName
    lastName
    email
    document
    role
  }
}
```

### 🟠 3. Buscar um Usuário pelo ID (`user`)
```graphql
query {
  user(id: 1) {
    id
    firstName
    lastName
    email
    document
    role
  }
}
```

### 🟡 4. Atualizar um Usuário (`update_user`)
```graphql
mutation {
  updateUser(
    id: 1
    firstName: "Carlos"
    lastName: "Souza"
    email: "carlos.souza@example.com"
    document: "12345678900"
    role: "client"
  ) {
    id
    firstName
    lastName
    email
    document
    role
  }
}
```

### 🔴 5. Deletar um Usuário (`delete_user`)
```graphql
mutation {
  deleteUser(id: 1) {
    message
  }
}
```