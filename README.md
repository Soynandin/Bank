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

## User

1. **Atributos do Usuário**
  - **`id`** (`id`): Identificador único do usuário.
  - **`first_name`** (`string`): Primeiro nome do usuário.
  - **`last_name`** (`string`): Sobrenome do usuário.
  - **`email`** (`string`): Endereço de e-mail do usuário.
  - **`password`** (`string`, virtual): Senha do usuário (não armazenada diretamente, apenas usada para gerar o `password_hash`).
  - **`password_hash`** (`string`): Hash da senha do usuário armazenado no banco de dados.
  - **`document`** (`string`): Documento do usuário (CPF ou CNPJ).
  - **`role`** (`string`): Papel do usuário no sistema. Pode ser:
  - **`inserted_at`** (`timestamp`): Data de criação do usuário.
  - **`updated_at`** (`timestamp`): Data da última atualização do usuário.

2. **Regras de Negócio e Validações**

  - O campo `email` deve ser único e seguir um formato válido.
  - O campo `document` deve ser um CPF ou CNPJ válido.
  - A senha do usuário é criptografada usando `Pbkdf2`.
  - A role do usuário deve ser uma das opções permitidas (`client`, `agency`, `admin`).
  - Apenas administradores podem modificar a role para `admin`.

---

### 📝 Como Funciona

O gerenciamento de usuários na aplicação segue o modelo de **GraphQL** para interagir com os dados. Cada operação de criação, leitura, atualização e exclusão é tratada por resolvers específicos. Aqui está um detalhamento de como cada operação funciona, incluindo validações e tratamentos de erro:

#### 1. **Listar Usuários**
Quando uma requisição de listagem de usuários é feita via **GraphQL**, o resolver `UserResolver.list_users/3` é chamado. Esse resolver invoca o módulo **`Users.List`** para buscar todos os usuários com os parâmetros de **paginações** e **ordenação**. A consulta é feita através do Ecto com os seguintes parâmetros:
- **`limit`**: Limite de usuários retornados (padrão: 10).
- **`offset`**: Deslocamento de resultados para paginação (padrão: 0).
- **`order_by`**: Coluna para ordenação (padrão: "name").
- **`direction`**: Direção da ordenação (padrão: "asc").

#### **Modelo Graphiql**
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

#### 2. **Obter Usuário**
Para buscar um usuário específico, o resolver **`UserResolver.get_user/3`** é invocado. Este resolver chama o módulo **`Users.Get`**, que tenta buscar o usuário no banco com base no **ID** fornecido. O processo de busca segue o seguinte fluxo:
- Se o ID for inválido (não numérico), retorna um erro: `"Invalid ID format"`.
- Se o usuário não for encontrado, retorna um erro 404: `"User not found"`.
- Caso contrário, retorna os dados do usuário solicitado.

#### **Modelo Graphiql**
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

#### 3. **Criar Usuário**
Para criar um usuário, o resolver **`UserResolver.create_user/3`** chama o módulo **`Users.Create`**, que aplica as validações usando o **Changeset**:
- Valida se todos os parâmetros obrigatórios estão presentes: `first_name`, `last_name`, `email`, `password`, `document` e `role`.
- O campo `email` é validado com um formato específico.
- O campo `role` é validado para aceitar apenas os valores "client", "agency" ou "admin".
- O campo `document` é validado para garantir que seja um CPF ou CNPJ válido.
- A senha é criptografada utilizando **Pbkdf2** antes de ser armazenada no banco de dados.
- Caso algum erro de validação ocorra, ele é retornado como uma mensagem clara de erro com os campos falhos.

#### **Modelo Graphiql**
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


#### 4. **Atualizar Usuário**
Para atualizar um usuário, o resolver **`UserResolver.update_user/3`** chama o módulo **`Users.Update`**. O processo de atualização segue os seguintes passos:
- Verifica se o usuário existe. Se não for encontrado, retorna erro: `"User not found"`.
- Valida se o **usuário atual** (representado por `current_user`) tem permissão para atualizar o usuário desejado:
  - Administradores (`role: "admin"`) podem alterar qualquer usuário, incluindo a si mesmos.
  - Clientes ou Agências podem alterar apenas a si mesmos, e não podem modificar seu próprio papel para "admin".
  - Se o **usuário atual** não tem permissão para a ação, um erro de "Unauthorized to update this user" é retornado.
- Se a alteração for permitida, um **Changeset** é aplicado com os campos `first_name`, `last_name`, `email`, `document` e `role`, sendo que `role` não pode ser alterado para "admin" por clientes ou agências.
- Se a atualização for bem-sucedida, os dados do usuário atualizado são retornados.
- Se houver erros de validação, uma mensagem detalhada com os erros será retornada.

#### **Modelo Graphiql**
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

#### 5. **Excluir Usuário**
Para excluir um usuário, o resolver **`UserResolver.delete_user/3`** invoca o módulo **`Users.Delete`**:
- A operação tenta excluir o usuário pelo **ID**.
- Se o usuário não for encontrado, retorna um erro: `"User not found"`.
- Se a exclusão for bem-sucedida, retorna uma mensagem de sucesso.

#### **Modelo Graphiql**
```graphql
mutation {
  deleteUser(id: 1) {
    message
  }
}
```

#### 6. **Login**
Para realizar o login, o resolver **`AuthResolver.login/3`** é utilizado:
- O **email** e **password** são passados como parâmetros para a função `authenticate/2` no módulo **`Guardian`**.
- O método **`authenticate`** verifica se o usuário existe e se a senha fornecida corresponde à senha armazenada no banco de dados (verificando com `Pbkdf2.verify_pass`).
- Se as credenciais forem válidas, dois tokens são gerados:
  - **Access Token** com validade de 15 minutos.
  - **Refresh Token** com validade de 7 dias.
- O retorno é um objeto contendo os tokens gerados, bem como informações básicas do usuário (id, email, role).
- Se as credenciais forem inválidas, um erro é retornado com a mensagem apropriada.

#### **Modelo Graphiql**
```graphql
mutation {
  login(email: "user@example.com", password: "password123") {
    access_token
    refresh_token
    user {
      id
      email
      role
    }
  }
}

```
#### 7. **Refresh Token**
O resolver **`AuthResolver.refresh_token/3`** é utilizado para gerar um novo **access token** usando o **refresh token**:
- O **refresh token** fornecido é decodificado e verificado através do método **`Guardian.decode_and_verify`**.
- Se o **refresh token** for válido e o usuário correspondente for encontrado, um novo **access token** é gerado com a validade de 15 minutos.
- O retorno é o novo **access token**.
- Caso o **refresh token** seja inválido ou a verificação falhe, um erro de "Invalid refresh token" é retornado.

#### **Modelo Graphiql**
```graphql
mutation {
  refresh_token(refresh_token: "refresh_token_aqui") {
    access_token
  }
}
```

#### 9. **Logout**
O resolver **`AuthResolver.logout/3`** permite que o usuário faça logout:
- O **token** presente no contexto (geralmente o **access token**) é passado para o método **`Guardian.revoke`**, que revoga o token.
- Se a revogação for bem-sucedida, uma mensagem de sucesso é retornada.
- Caso haja algum erro ao tentar revogar o token, uma mensagem de erro é retornada.

#### **Modelo Graphiql**
```graphql
mutation {
  logout {
    message
  }
}
```
#### **Adendo sobre a autenticação de usuários**
O padrão é enviar o access token no cabeçalho das requisições subsequentes para autenticar o usuário. A chave no cabeçalho deve ser Authorization e o valor deve ser o token, precedido pela palavra Bearer, assim:
```http
Authorization: Bearer <access_token>
```

  - **Login**:
    - Quando o usuário realiza o login com o email e password, o servidor gera dois tokens: um access token e um refresh token.
    - O access token é utilizado para autenticar o usuário em futuras requisições. Após o login bem-sucedido, o access token deve ser enviado no cabeçalho das requisições subsequentes para acessar recursos protegidos.
    - O refresh token é utilizado para gerar um novo access token quando o antigo expirar, mas ele não precisa ser enviado no cabeçalho em requisições subsequentes, apenas quando o access token expirar e você for renovar.

  - **Refresh Token**:
    -Quando o access token expira, o cliente pode enviar o refresh token no corpo da requisição para obter um novo access token.
    - Embora o refresh token seja enviado no corpo da requisição, o access token gerado deve ser incluído no cabeçalho de futuras requisições para autenticação.

  - **Logout**:
    - O logout revoga o access token atual, e para isso, o access token precisa ser enviado no cabeçalho da requisição para que o servidor possa identificar qual token revogar.


#### **Tratamento de Erros**
Em todas as operações, caso ocorra um erro, a aplicação garante que a resposta seja informativa:
- **Erro de ID inválido**: Caso um ID fornecido não seja um número válido, o sistema retornará `"Invalid ID format"`.
- **Erro de usuário não encontrado**: Se a busca ou exclusão de um usuário não encontrar o usuário no banco, retornará `"User not found"`.
- **Erros de validação**: Se os dados enviados para a criação ou atualização de um usuário não forem válidos, o sistema retornará uma mensagem com detalhes sobre o erro em cada campo específico.

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

#### Relacionamento entre Módulos

A aplicação utiliza o padrão de **Repositórios** para separar as interações com o banco de dados. O **BananaBank.Repo** é o responsável por acessar diretamente as tabelas no banco. Cada módulo do sistema (como `Users.Create`, `Users.Update`, `Users.Get`, etc.) utiliza este repositório para realizar operações como criação, leitura, atualização e exclusão de usuários, enquanto o Ecto gerencia as transações e validações.

#### Conexão com o Banco de Dados

A conexão com o banco é configurada no arquivo de ambiente, permitindo que a aplicação se conecte ao banco PostgreSQL de maneira eficiente. O **BananaBank.Repo** é configurado para usar o adaptador **PostgreSQL**, permitindo realizar todas as operações necessárias de forma segura e eficiente.