# Dashboard Financeiro — Cadastro & Autenticação

## Visão geral
- Microserviço Spring Boot 3.5.5 (Java 25) dedicado ao ciclo de vida de usuários e emissão de tokens JWT.
- Estrutura em camadas (`web`, `application`, `infrastructure`, `security`, `messaging`) isolando controladores REST, serviços, persistência, autenticação e publicação de eventos.
- Stack principal: Spring Security, Spring Data JPA, Bean Validation, Liquibase, `jjwt`, Spring Kafka.

## Linha do tempo de desenvolvimento
- 17/09/2025 — Commits "Adição dos demais micro serviços do backend" e "Primeira versao do serviço de cadastro de usuario" criaram o projeto, configuraram Gradle/Docker Compose e entregaram os endpoints de cadastro, login, refresh e consulta (`AuthController`, `UserController`) com migração `0001_create_table_users.sql`.
- 02/10/2025 — Commit "Ajustes no login e criação da primeira tela" introduziu `CorsConfig`, ajustes de segurança e melhorias no fluxo de autenticação para integrar com o frontend React.
- 02/10/2025 — Commit "Ajustes e adicao de documentacao" atualizou a documentação deste serviço e sincronizou a coleção Insomnia com os novos endpoints.

## Funcionalidades
- **Cadastro e consulta de usuários** (`UserController`/`UserService`):
  - `POST /api/v1/users` registra usuário com validação de e-mail/CPF únicos, senha cifrada (`BCryptPasswordEncoder`) e dados de endereço.
  - `GET /api/v1/users/{id}` exige autenticação JWT, só permitindo acesso ao próprio registro ou a perfis com `ROLE_ADMIN`.
  - `PUT /api/v1/users/{id}` atualiza dados cadastrais e de endereço com as mesmas regras de acesso do `GET`.
  - `DELETE /api/v1/users/{id}` remove o perfil definitivamente, restringindo a ação ao próprio usuário ou administradores; responde `204 No Content`.
- **Autenticação JWT** (`AuthController`, `AuthService`, `JwtService`):
  - `POST /api/v1/auth/login` gera par de tokens (`access` configurável, `refresh` padrão 7 dias) com claims `sub` (UUID), `email`, `name`, `role`.
  - `POST /api/v1/auth/refresh` valida refresh token, reemite access token e mantém o refresh original.
  - `GET /api/v1/auth/me` retorna o usuário autenticado por meio do token.
  - `POST /api/v1/auth/logout` permanece stateless.
- **Sincronização via Kafka**: após o cadastro, `UserEventProducer` publica `UserRegisteredEvent` no tópico `user.events`, permitindo que outros serviços (ex.: notificações) mantenham cache local de contatos.
- **Segurança**:
  - `SecurityConfig` estabelece sessão stateless, desabilita HTTP Basic/CSRF e adiciona `JwtAuthenticationFilter` antes da `UsernamePasswordAuthenticationFilter`.
  - O filtro valida token, busca usuário em cache e injeta `AuthenticatedUser` na `SecurityContext`.
  - Handler global (`ApiExceptionHandler`) padroniza falhas de validação, `IllegalArgumentException`, regras de negócio e erros inesperados.

## Persistência e migração
- Banco MySQL com tabela `users` criada via `0001_create_table_users.sql`.
- Campos de auditoria (`registered_at`, `updated_at`) gerenciados por `@PrePersist/@PreUpdate`.
- Repositório `UserJpaRepository` oferece consultas por e-mail/CPF e busca por id.

## Configuração
- `application.yml` expõe parâmetros para datasource, JWT (`security.jwt.secret`, issuer e tempos), Kafka e CORS.
- Grupo Kafka `dashboard-notifications` consome eventos publicados por este serviço.
- Profiles suportam execução local e em Docker (ajuste automático do datasource).

## Testes
- `ApplicationTests` garante carga de contexto. Recomenda-se ampliar cobertura para serviços de autenticação e publicação de eventos.
