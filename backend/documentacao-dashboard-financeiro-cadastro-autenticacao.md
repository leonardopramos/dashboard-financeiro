# Dashboard Financeiro — Cadastro & Autenticação (status em 02/10/2025)

## Visão geral do serviço
- Microserviço Spring Boot 3.5.5 (Java 25) responsável por cadastro de usuários e autenticação centralizada do ecossistema.
- Camadas organizadas em `web`, `application`, `infrastructure`, com DTOs validados e uso de Lombok para construtores/`builder`.
- Dependências chave: Spring Security, Spring Data JPA, Bean Validation, Liquibase e biblioteca `jjwt` para emissão e parsing de tokens JWT.

## Funcionalidades implementadas
- **Cadastro de usuários** (`UserController`, `UserService`): endpoint `POST /api/v1/users` persiste dados pessoais, endereço e papel do usuário; aplica validação de email único e armazena senha com `BCryptPasswordEncoder`. Disponibiliza busca `GET /api/v1/users/{id}`.
- **Autenticação JWT** (`AuthController`, `AuthService`, `JwtService`):
  - `POST /api/v1/auth/login` valida credenciais no banco e devolve par de tokens (`access` 15 min, `refresh` 7 dias).
  - `POST /api/v1/auth/refresh` reaproveita refresh token para emitir novo access token.
  - `POST /api/v1/auth/logout` implementado de forma stateless (não invalida tokens em banco).
  - `GET /api/v1/auth/me` extrai JWT do header `Authorization`, resolve usuário atual e retorna entidade persistida.
- **Configuração de CORS e segurança**: `SecurityConfig` libera rotas de cadastro/autenticação e exige autenticação para as demais; `CorsConfig` autoriza origem `http://localhost:5173`, métodos padrão REST e envia cabeçalho `Authorization` ao front-end.

## Persistência e migrações
- Entidade `UserJpaEntity` mapeando a tabela `users`, com atributos para identificação (CPF, email), endereço e flags (`emailVerified`, `active`). `@PrePersist` e `@PreUpdate` gerenciam timestamps automaticamente.
- Repositório `UserJpaRepository` com buscas por email e CPF, usado para garantir unicidade.
- Liquibase aplicado via `application.yml`, com changelog mestre que inclui `0001_create_table_users.sql` criando a estrutura inicial e índices/constraints relevantes.

## Tokens e políticas de segurança
- `JwtService` gera tokens HS256 usando chave secreta estática (codificada em Base64 em tempo de execução). Funções para emitir e extrair `subject` suportam fluxo de login e refresh.
- `PasswordEncoder` compartilhado (BCrypt) garante armazenamento seguro das senhas.
- Flags `emailVerified` e `active` já presentes na entidade para suportar evoluções futuras (verificação de email, bloqueio de contas).

## Testes e observações adicionais
- Testes automatizados restritos a `ApplicationTests` (load de contexto). Não há cobertura específica para regras de autenticação ou repositório.
- O pacote do teste usa capitalização diferente (`com.dashboard_financeiro.Cadastro.Autenticacao`), detalhe a ajustar em evoluções futuras para alinhar com o código principal.

## Integração com docker-compose.yml
- Serviço depende do SQL Server definido em `docker-compose.yml` (container `sqlserver`) para persistir usuários; as credenciais da aplicação (`Strong@Passw0rd`) estão alinhadas com as variáveis definidas no compose.
- A configuração Kafka apontada para `kafka:9092` pressupõe os containers `zookeeper`, `kafka` e `kafka-ui` do mesmo compose, preparando o terreno para eventos de autenticação (ainda não implementados).
- Ao executar no ambiente Docker, basta colocar o serviço na mesma rede `dashboard-network` para resolver os hosts declarados (`sqlserver`, `kafka`).
