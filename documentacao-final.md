# Documentação final — Dashboard Financeiro

Este documento consolida a história de desenvolvimento, a arquitetura vigente e os fluxos ponta a ponta do projeto **dashboard-financeiro**. A análise foi construída a partir de:

- inspeção do histórico Git com `git log --reverse --pretty='%h|%ad|%s' --date=short` para identificar marcos;
- leitura dirigida dos commits com `git show <hash> --stat` para mapear arquivos e funcionalidades introduzidas;
- revisão dos diretórios `backend`, `frontend`, `docker-compose.yml`, `scripts` e dos artefatos auxiliares (`PASSO-A-PASSO.md`, documentações específicas de cada microserviço).

## 1. Linha do tempo consolidada

| Data       | Commit | Marco técnico                                                                                                                            |
|------------|--------|------------------------------------------------------------------------------------------------------------------------------------------|
| 2025-09-16 | `0a58f2b` | **First commit**: monorepo inicial com esqueleto Spring Boot (Gradle) e frontend React/Vite padrão. Sem lógica de domínio ainda.        |
| 2025-09-17 | `977f526` | **Configurações iniciais**: `backend/docker-compose.yml` com SQL Server/Kafka, template `application.yml` e base do Liquibase.             |
| 2025-09-17 | `1fbac0e` | **Adição dos microserviços**: criação dos projetos `dashboard-financeiro`, `dashboard-financeiro-cadastro-autenticacao`, `dashboard-financeiro-notificacoes` e do API Gateway, todos com Gradle Wrapper próprio. |
| 2025-09-17 | `5de55a1` | **Primeira versão de cadastro/autenticação**: controllers REST (`/api/v1/auth`, `/api/v1/users`), JPA para `users`, serviço JWT e migração `0001_create_table_users.sql`. |
| 2025-10-02 | `430bcd9` | **Ajustes no login + primeira tela**: frontend recebe contexto de autenticação, formulários de login/cadastro, Tailwind, rotas protegidas; backend expõe `CorsConfig`. |
| 2025-10-02 | `1db5d99` | **Persistência financeira**: surgem os endpoints de contas bancárias e transações, entidades JPA (`BankAccount`, `Transaction`), serviços e o `ApiExceptionHandler`. |
| 2025-10-02 | `4e7ebd7` | **Documentação e Insomnia**: migrações SQL externas (`db/migrations`), coleções de testes e documentação específica por serviço.        |
| 2025-10-20 | `fc90338` | **Estrutura inicial completa**: inclusão de categorias, metas, dashboard agregado, eventos Kafka (`transactions.events`, `goals.events`, `user.events`), serviço de notificações funcional, API Gateway reativo, guia `PASSO-A-PASSO.md` e tcc inicial. |
| 2025-11-04 | `d40fdcc` | **Primeira versão funcional**: verificação de e-mail, templates HTML, listener de verificação, gráficos avançados no frontend (Analytics), páginas CRUD (contas, categorias, metas, transações, perfil) e seed SQL para testes. |
| 2025-11-10 | `b771faa` | **Adequação para deploy**: migração completa de SQL Server para MySQL (novas migrations + `FINANCE_DB_URL`), Dockerfiles por serviço, `docker-compose.yml` na raiz, scripts de runtime config do frontend, Resend client dedicado e higienização de segredos. |

## 2. Organização atual do repositório

- `backend/`: agrega quatro projetos Spring Boot independentes e documentação dedicada:
  - `dashboard-financeiro` (domínio financeiro);
  - `dashboard-financeiro-cadastro-autenticacao`;
  - `dashboard-financeiro-notificacoes`;
  - `dashboard-financeiro-api-gateway/API-Gateway-Dashboard-Financeiro`.
- `frontend/`: aplicação React + TypeScript (Vite) com build Docker/Nginx e runtime config injetado via `public/runtime-config.js`.
- `docker-compose.yml`: orquestra MySQL, Kafka, Kafka UI, três microserviços, gateway e frontend, parametrizados via `.env`.
- `scripts/`: `init-mysql.sh` automatiza criação de bancos, `mysql-init/01-create-databases.sql` garante schemas para cada serviço.
- `PASSO-A-PASSO.md`: guia operacional descrevendo pré-requisitos, ordem de subida dos serviços, roteamento no gateway e testes E2E.
- `tcc.txt` / `tcc.pdf`: materiais textuais de apoio ao TCC.

## 3. Linha do tempo detalhada (compilado dos commits)

### `0a58f2b` — 16/09/2025
- Bootstrap do monorepo: backend Spring Boot com `DashboardFinanceiroApplication.java`, `DashboardFinanceiroApplicationTests.java`, `build.gradle`, wrappers e `application.properties` contendo apenas `spring.application.name`.
- Frontend recebe o template Vite/React/TypeScript completo (`package.json`, `package-lock.json`, `tsconfig*.json`, `vite.config.ts`, `src/App.tsx`, `src/main.tsx`, assets). `App.tsx` segue exibindo o boilerplate padrão.
- Nenhum endpoint ou lógica de domínio; objetivo era garantir que `./gradlew bootRun` e `npm run dev` funcionassem como “Hello world”.

### `977f526` — 17/09/2025
- Introduz `backend/docker-compose.yml` com **SQL Server**, Kafka e Zookeeper, além do serviço Spring Boot, configurando volumes, credenciais (`Strong@Passw0rd`) e dependências.
- Substitui `application.properties` por `application.yml` com datasource JDBC SQL Server (`com.microsoft.sqlserver.jdbc.SQLServerDriver`), JPA (`SQLServerDialect`), Liquibase (`db/changelog/db.changelog-master.xml`), Kafka e placeholders de OAuth Google.
- Cria `db/changelog-master.xml`, ainda sem changesets, mas preparando o versionamento do banco. Senhas permanecem hardcoded.

### `1fbac0e` — 17/09/2025
- Organiza `backend/` em quatro microserviços: `dashboard-financeiro`, `dashboard-financeiro-cadastro-autenticacao`, `dashboard-financeiro-notificacoes`, `dashboard-financeiro-api-gateway`.
- Cada módulo ganha `build.gradle`, Gradle Wrapper, `settings.gradle`, `.gitignore`, classe `Application` e `ApplicationTests`, permitindo builds isolados.
- É um commit estrutural: nenhum endpoint novo, apenas a base para evoluções paralelas.

### `5de55a1` — 17/09/2025
- Implementa o microserviço de cadastro/autenticação:
  - Application layer com `AuthService`, `JwtService`, `UserService`, tratando login, refresh, hashing e validações.
  - Web/Security com `SecurityConfig`, controllers `AuthController`/`UserController`, DTOs (`CreateUserRequest`, `LoginRequest`, `RefreshTokenRequest`, `AuthResponse`, `UserDTO`) e fluxo JWT completo.
- Persistência: `UserJpaEntity`, `UserJpaRepository` e migration `db/migrations/0001_create_table_users.sql` (SQL Server) criam `users`.
- Ajusta `docker-compose.yml` do serviço e move `Application.java`/`ApplicationTests` para pacotes definitivos.

### `430bcd9` — 02/10/2025
- Backend adiciona `CorsConfig` e adapta `SecurityConfig` para liberar o SPA.
- Frontend dá o primeiro salto: Tailwind/PostCSS, contexto `AuthContext` persistindo tokens, `ProtectedRoute`, formulários `Login`/`Register` (variações Basic/Simple), `Dashboard` inicial, `services/api.ts` (Axios + interceptors) e `types/auth.ts`.
- `README_FRONTEND.md` documenta a stack; nasce a primeira experiência logada consumindo o serviço de auth.

### `1db5d99` — 02/10/2025
- Serviço financeiro passa a ter contas/transações:
  - `BankAccountService`/`TransactionService`, enums `AccountType`/`TransactionType`, exceções `BusinessException`/`ResourceNotFoundException`.
  - Controllers `BankAccountController`, `TransactionController`, DTOs de entrada/saída e `ApiExceptionHandler`.
- Liquibase recebe `001-create-bank-and-transactions.xml` (SQL Server) criando `bank_accounts` e `transactions`.
- `SecurityConfig` do serviço financeiro passa a exigir JWT em todas as rotas.

### `4e7ebd7` — 02/10/2025
- Reorganiza migrations: o changelog XML dá lugar a scripts SQL Server explícitos em `src/main/resources/db/migrations/0001_create_bank_and_transactions.sql`.
- Adiciona documentações (`documentacao-dashboard-financeiro*.md`) e a coleção `backend/insomnia/dashboard-financeiro-export.yaml`.
- Sem lógica nova; foco em clareza para revisões e onboarding.

### `fc90338` — 20/10/2025
- Documentação robusta: `PASSO-A-PASSO.md`, `tcc.txt`, `tcc.pdf`.
- **API Gateway** (Spring Cloud Gateway) ganha filtros JWT (`JwtAuthenticationFilter`, `JwtTokenProvider`), configs (`GatewayCorsProperties`, `SecurityConfig`) e rotas declarativas.
- **Auth**: integra Kafka (`KafkaConfig`, `JwtProperties`, `UserEventProducer`, `UserRegisteredEvent`), `ApiExceptionHandler`, `AuthenticatedUser`.
- **Notificações**: nasce `EmailNotificationService`, `NotificationLogService`, listeners para usuários/transações/metas, migrations `0001_create_notification_tables.sql`.
- **Financeiro**: inclui categorias, metas, dashboards (`CategoryService`, `FinancialGoalService`, `DashboardService`), eventos (`GoalStatusChangedEvent`, `TransactionCreatedEvent`), `DomainEventPublisher`, controllers extras e `0002_create_categories_and_goals.sql`.
- `backend/dashboard-financeiro-gateway-export.yaml` documenta o gateway; `docker-compose.yml` é atualizado.

### `d40fdcc` — 04/11/2025
- **Autenticação**: verificação de e-mail com `EmailVerificationService`, entidade `EmailVerificationTokenEntity`, endpoints `/verify-email` e `/resend`, eventos `EmailVerificationRequestedEvent`, templates `email-verification.html` e `welcome-email.html`.
- **Notificações**: `EmailTemplateService`, novos templates (`goal`, `transaction`) e `EmailVerificationEventsListener`.
- **Financeiro**: amplia dashboards com `DashboardRange`, `GoalContributionJpaEntity`, seeds (`scripts/test_account_seed.sql` em T-SQL), DTOs `AllocateGoalAmountRequest`, `UpdateBankAccountRequest`, etc.
- **Frontend**: entrega todas as telas (CRUD completos, `Profile`, `VerifyEmail`), analytics (`AnalyticsView`, gráficos diversos), `AppLayout`, `Sidebar`, `DashboardRangeContext`, `services/finance.ts`, `types/finance.ts`, utilitários `format.ts`/`number.ts`.
- Ainda tudo sobre SQL Server, com credenciais fixas nos YAML.

### `b771faa` — 10/11/2025
- **Migração SQL Server → MySQL**: todos os `application.yml` passam a usar `jdbc:mysql`, `MySQL8Dialect` e variáveis (`FINANCE_DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, `JWT_SECRET`). Credenciais hardcoded saem do repo.
- **Migrations**: scripts antigos são substituídos por versões MySQL (`0001_create_bank_accounts.sql` ... `0006_create_goal_contributions.sql`, além de novos arquivos para auth/notificações). `scripts/init-mysql.sh`, `scripts/mysql-init/01-create-databases.sql` e `test_account_seed.sql` reescrito automatizam provisionamento.
- **Deploy**: Dockerfiles por serviço + frontend, novo `docker-compose.yml`, runtime config do frontend (`docker/entrypoint.sh`, `runtime-config.template.js`, `public/runtime-config.js`, `docker/default.conf.template`) e ajustes de CORS. Compose passa a subir MySQL, Kafka, microserviços, gateway e SPA prontos para produção.
- **Notificações**: integração com Resend (`ResendProperties`, `ResendEmailClient`); documentação (`PASSO-A-PASSO.md`, `documentacao-dashboard-financeiro*.md`, `tcc.txt`) atualizada para refletir o novo stack.

## 4. Arquitetura backend

### 4.1 Serviço de Cadastro & Autenticação (`backend/dashboard-financeiro-cadastro-autenticacao`)

- **Stack:** Spring Boot 3.5.5, Spring Security, Spring Data JPA, Kafka, JWT (`jjwt`), Bean Validation.
- **Camadas:** `web` (controllers/dtos), `application` (serviços), `security` (filtro + provider), `infrastructure` (repos JPA), `messaging` (eventos Kafka).
- **Endpoints principais:**
  - `POST /api/v1/users`: cadastro com validação de CPF/e-mail únicos e hashing via `BCryptPasswordEncoder`.
  - `PUT/DELETE /api/v1/users/{id}`: atualização/remoção com checagem de propriedade do recurso ou `ROLE_ADMIN`.
  - `POST /api/v1/auth/login`: autenticação que gera `accessToken` + `refreshToken` com claims (`sub`, `email`, `name`, `role`).
  - `POST /api/v1/auth/refresh`: reemissão de access token preservando refresh.
  - `GET /api/v1/auth/me`: retorna o usuário autenticado.
  - `POST /api/v1/auth/logout`: mantém stateless; endpoint existe para simetria com o frontend.
  - `POST /api/v1/auth/verify-email` e `/verify-email/resend`: camadas adicionadas no commit `d40fdcc`, disparando `EmailVerificationRequestedEvent`.
- **Eventos Kafka:** `UserRegisteredEvent` e `EmailVerificationRequestedEvent` publicados nos tópicos `user.events` e `email.verification.events`.
- **Migrações:** `0001_create_table_users.sql`, `0002_create_email_verification_tokens.sql` (tokens com expiração, status e chaves únicas).
- **Segurança:** `JwtAuthenticationFilter` injeta `AuthenticatedUser`; `SecurityConfig` libera apenas `/api/v1/auth/**` e `/api/v1/users` (POST) sem token.

### 4.2 Serviço Financeiro (`backend/dashboard-financeiro`)

- **Domínios atendidos:** contas bancárias, categorias, transações, metas, dashboard consolidado.
- **Camadas:** `web` (controllers + handlers), `application`, `domain` (enums de negócio), `infrastructure` (JPA), `messaging`, `security`, `config`.
- **Principais recursos:**
  - **Contas bancárias** (`BankAccountController/Service`): CRUD protegido; cada conta pertence ao usuário do token. Atualização de saldo ocorre ao lançar transações.
  - **Transações** (`TransactionController/Service`): suporta `INCOME`, `EXPENSE`, `TRANSFER`. Regras: pertencimento da conta, validação de categoria ativa e publicação de `TransactionCreatedEvent`.
  - **Categorias** (`CategoryController/Service`): permite criar, listar, atualizar e reativar categorias por usuário. Enum `CategoryType` diferencia `INCOME`/`EXPENSE`.
  - **Metas financeiras** (`FinancialGoalController/Service`): metas `SAVINGS` ou `EXPENSE_LIMIT`, campos de período e valores-alvo. `GoalContributionJpaEntity` registra alocações (`allocate` endpoint) e dispara `GoalStatusChangedEvent` quando status muda para `ACHIEVED` ou `EXCEEDED`.
  - **Dashboard** (`DashboardController` + `DashboardService`): agrega dados mensais/por intervalo (`DashboardRange`) produzindo `DashboardOverviewResponse` (saldo consolidado, evolução mensal, breakdown de categorias, progresso de metas).
- **Segurança:** mesmo modelo JWT do auth-service; `JwtAuthenticationFilter` usa `JwtTokenProvider` para validar tokens emitidos pelo serviço de cadastro.
- **Persistência:** MySQL com migrações divididas em seis arquivos (`0001_create_bank_accounts.sql` ... `0006_create_goal_contributions.sql`), permitindo evoluções independentes.
- **Mensageria:** `KafkaConfig` registra tópicos `transactions.events` e `goals.events`. Publicações ocorrem somente após commit para evitar mensagens órfãs.
- **Ferramentas auxiliares:** `scripts/test_account_seed.sql` (amostra de dados para demonstração), coleção Insomnia (`backend/dashboard-financeiro/insomnia`).

### 4.3 Serviço de Notificações (`backend/dashboard-financeiro-notificacoes`)

- **Responsabilidades:** consumir eventos Kafka e enviar e-mails via Resend.
- **Eventos tratados:**
  - `user.events` → sincroniza `notification_users`.
  - `transactions.events` → envia comprovante da movimentação.
  - `goals.events` → comunica metas atingidas/excedidas.
  - `email.verification.events` → envia link/código de verificação.
- **Arquitetura:** `messaging` com listeners dedicados, `application` com `EmailNotificationService` + `EmailTemplateService`, `infrastructure` com Repositories JPA e cliente HTTP da Resend (`ResendEmailClient`, `ResendProperties`).
- **Persistência:** tabelas `notification_users`, `email_notification_log`. Cada envio é registrado com status `SENT`, `FAILED` ou `DISABLED` (quando `MAIL_ENABLED=false`).
- **Configuração:** `application.yml` expõe `notifications.email.*`, `notifications.email.resend.*` e `spring.kafka.consumer` pré-configurados.
- **Templates:** HTML em `src/main/resources/templates/email/*.html` (verificação, transação, meta, boas-vindas).

### 4.4 API Gateway (`backend/dashboard-financeiro-api-gateway`)

- **Tecnologia:** Spring Cloud Gateway (aplicação reativa).
- **Roteamento:** definido em `application.yml`, reescrevendo `/api/auth/**`, `/api/users/**`, `/api/finance/**` e `/api/notifications/**` para os respectivos serviços internos. O gateway publica apenas `SERVER_PORT` externo (por padrão 8089).
- **Segurança:** filtro JWT próprio; `gateway.security.public-paths` libera rotas públicas; demais solicitações precisam do Bearer token.
- **CORS:** configurável via `GatewayCorsProperties` permitindo múltiplas origens (frontend local e deploy).
- **Deploy:** Dockerfile usa imagem `eclipse-temurin:25-jdk`, copia o JAR `bootJar` e expõe o profile `docker`.

## 5. Frontend React (`frontend/`)

- **Stack:** React 19, TypeScript, Vite, Tailwind (config custom), Material UI e `@mui/x-charts` para gráficos.
- **Contextos:** `AuthContext` (persistência de tokens, refresh automático, guarda do usuário) e `DashboardRangeContext` (intervalos pré-definidos para filtros).
- **Serviços HTTP:** `src/services/api.ts` centraliza Axios, injeta `Authorization`, trata 401 e possui helpers `authService`. `src/services/finance.ts` encapsula chamadas financeiras (contas, categorias, metas, transações, dashboard, alocação).
- **Páginas/fluxos principais:**
  - `pages/Login.tsx` e `pages/Register.tsx`: onboarding em duas etapas (dados pessoais e endereço) com máscaras de CPF/CEP.
  - `pages/Dashboard.tsx`: alterna entre `SummaryView` e `AnalyticsView`. Summary exibe métricas, contas paginadas, categorias e metas ativas; Analytics trás gráficos (tendência mensal, fluxo diário, distribuição por conta, impacto por categoria, evolução de metas).
  - `pages/BankAccounts.tsx`, `Categories.tsx`, `Transactions.tsx`, `Goals.tsx`: CRUD completo com formulários modais, paginação e filtros.
  - `pages/Goals.tsx`: inclui tela de alocação manual (endpoint `/goals/{id}/allocate`) e visão `GoalAllocationOverview`.
  - `pages/Profile.tsx`: mantém dados pessoais, status de verificação de e-mail, botão para reenviar verificação e exclusão da conta.
- **Layouts e componentes:**
  - `components/layout/AppLayout.tsx` + `Sidebar.tsx`: shell com navegação lateral, avatar e menus contextuais.
  - `components/dashboard/analytics/*`: biblioteca própria de gráficos baseada em MUI Charts, com `ChartErrorBoundary` e `PaginationControls`.
- **Build/Deploy:** Dockerfile realiza `npm ci`, `npm run build` e copia `dist` para Nginx com `default.conf.template`. `docker/entrypoint.sh` injeta variáveis em runtime via `public/runtime-config.js`, permitindo apontar para gateways diferentes sem rebuild.

## 6. Infraestrutura e deploy

- **Orquestração local:** `docker-compose.yml` (raiz) sobe MySQL, Kafka, Kafka UI, três serviços Spring, gateway e frontend. Variáveis esperadas: `DB_USERNAME`, `DB_PASSWORD`, `JWT_SECRET`, `MAIL_FROM`, `MAIL_ENABLED`, `RESEND_API_KEY`, `VITE_API_BASE_URL`, entre outras.
- **Perfis Spring:** cada serviço possui `application.yml` padrão e, quando necessário, `application-docker.yml` (gateway) ou propriedades controladas via env.
- **Scripts auxiliares:**
  - `scripts/init-mysql.sh`: usado pelo compose para executar `mysql-init/01-create-databases.sql`.
  - `backend/dashboard-financeiro/scripts/test_account_seed.sql`: popula amostras para demonstrações.
- **Monitoramento:** Kafka UI em `http://localhost:8085`, endpoints Actuator expostos via gateway (`/actuator/health`, `/actuator/info`).
- **Documentação operacional:** `PASSO-A-PASSO.md` descreve pré-requisitos, ordem de subida, comandos cURL (cadastro → login → categorias → contas → metas → transações → dashboard) e testes isolados (`./gradlew test` por serviço).

## 7. Fluxos ponta a ponta

### 7.1 Onboarding de usuário
1. Frontend (`Register.tsx`) envia dados para `POST /api/users` via gateway.
2. Auth-service valida CPF/e-mail, persiste no banco `dashboard_financeiro_cadastro_autenticacao`.
3. `UserEventProducer` publica `UserRegisteredEvent` (`user.events`), consumido pelo serviço de notificações para criar/atualizar `notification_users`.
4. `EmailVerificationService` cria token em `email_verification_tokens`, dispara `EmailVerificationRequestedEvent`.
5. Notificações consomem o evento, renderizam `email-verification.html` e enviam via Resend (ou registram `DISABLED`/`FAILED`).

### 7.2 Operações financeiras
1. Usuário autenticado cria categorias (`POST /api/finance/categories`) e contas (`POST /api/finance/bank-accounts`); dados vão para o banco `dashboard_financeiro`.
2. Ao inserir transação (`POST /api/finance/transactions`), o serviço:
   - valida pertencimento da conta, tipo e categoria;
   - recalcula saldo e registra a transação;
   - publica `TransactionCreatedEvent`.
3. Se a transação impactar metas, `FinancialGoalService` recalcula progresso e, ao detectar mudança de status, envia `GoalStatusChangedEvent`.
4. Notificações tratam ambos eventos, gerando e-mails específicos (templates `transaction-notification.html` e `goal-notification.html`) e logs.

### 7.3 Dashboards e analytics
1. Frontend chama `GET /api/finance/dashboard/overview` passando `year/month` ou `range`.
2. `DashboardService` agrega receitas/despesas por período, consolida saldo de contas (`bank_accounts`), calcula tendência dos últimos 6 meses (`monthlyTrend`) e prepara breakdown de categorias e metas.
3. `AnalyticsView` consome também `financeService.listBankAccounts`, `listTransactions`, `listFinancialGoals` para montar gráficos combinados na camada de apresentação.

### 7.4 Gestão de metas e alocação manual
1. `Goals.tsx` lista metas e permite acionar `allocateGoalAmount` com valor e data.
2. O backend registra um `GoalContributionJpaEntity`, atualiza percentuais e avalia notificações.
3. Eventos e e-mails seguem o mesmo fluxo descrito acima.

### 7.5 Atualização de perfil e verificação
1. `Profile.tsx` consulta `/api/finance/dashboard/overview` (para cards) e `auth/me`.
2. ALTERAÇÕES cadastrais vão para `PUT /api/users/{id}`; exclusão usa `DELETE /api/users/{id}`.
3. Reenvios do e-mail de verificação chamam `POST /api/auth/verify-email/resend`, gerando novo token + evento.

## 8. Testes, seeds e observabilidade

- Cada microserviço mantém ao menos um teste de contexto (`ApplicationTests`). O PASSO-A-PASSO recomenda executar `./gradlew test` antes do deploy.
- `scripts/test_account_seed.sql` povoa categorias, contas e transações realistas para demonstrações com o frontend.
- Logs estruturados podem ser acompanhados nos terminais dos serviços; o compose define `restart: unless-stopped` para resiliente local.

## 9. Próximos passos sugeridos

1. **Cobertura de testes:** adicionar testes unitários e de integração (ex.: `@DataJpaTest`, `@SpringBootTest` com perfis `test`) para serviços de metas, notificações e analytics.
2. **Observabilidade:** incorporar traces/metrics (Micrometer + Prometheus/Grafana) e dashboards para Kafka consumers.
3. **Melhorias de segurança:** mover tokens para cookies httpOnly, implementar logout com revogação de refresh e política de senhas configurável.
4. **CI/CD:** automatizar build das imagens Docker e publicação no registry, reaproveitando os Dockerfiles já presentes.
5. **Internacionalização/frontend:** evoluir `runtime-config` para suportar múltiplos ambientes e temas (escopo já citado em `README_FRONTEND.md`).
