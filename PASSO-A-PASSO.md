# Dashboard Financeiro – Passo a passo de execução, comunicação e testes

## 0. Mapa dos serviços e como eles conversam
- `dashboard-financeiro-cadastro-autenticacao` (porta 8081) expõe `/api/v1/auth` e `/api/v1/users`, grava usuários no banco `dashboard_financeiro_cadastro_autenticacao` e publica `UserRegisteredEvent` no tópico Kafka `user.events`.
- `dashboard-financeiro` (porta 8082) disponibiliza `/api/v1/*` para contas, categorias, metas, transações e dashboard, grava no banco `dashboard_financeiro` e publica `TransactionCreatedEvent` (`transactions.events`) e `GoalStatusChangedEvent` (`goals.events`).
- `dashboard-financeiro-notificacoes` (porta 8083) consome `user.events`, `transactions.events` e `goals.events`, mantém o cache de contatos no banco `dashboard_financeiro_notificacoes` e envia e-mails.
- `dashboard-financeiro-api-gateway` (porta 8089) é o ponto único de entrada HTTP. Ele reescreve:
  - `/api/auth/**` e `/api/users/**` → serviço de cadastro/autenticação.
  - `/api/finance/**` → serviço financeiro.
  - `/api/notifications/**` → serviço de notificações.
- Infraestrutura compartilhada: SQL Server (1433), Kafka (9094), Kafka UI (8085) e, opcionalmente, MailHog (SMTP 1025 / UI 8025).

## 1. Pré-requisitos
- Java 25 configurado no `PATH`.
- Docker + Docker Compose.
- Ferramenta HTTP (`curl`, Insomnia exportado em `backend/dashboard-financeiro/insomnia/dashboard-financeiro-export.yaml`, etc.).
- Opcional: MailHog para capturar e-mails.

## 2. Subir infraestrutura compartilhada
```bash
cd backend
docker compose up -d sqlserver zookeeper kafka kafka-ui
# Opcional: SMTP fake para testes
docker run -d --rm --name mailhog -p 1025:1025 -p 8025:8025 mailhog/mailhog
```

## 3. Variáveis de ambiente comuns
Crie um arquivo `backend/.env-backend` (ou exporte no shell) com os valores compartilhados:
```bash
export JWT_SECRET=uma-chave-segura-com-32-bytes
export MAIL_FROM=no-reply@dashboard.local
export MAIL_FALLBACK=suporte@dashboard.local
export MAIL_HOST=localhost
export MAIL_PORT=1025
```
> No Linux/macOS use `source backend/.env-backend` em cada terminal antes de iniciar os serviços. No Windows use `set`/`setx` equivalentes.

## 4. Iniciar os microserviços (um terminal por serviço)
1. **Cadastro & Autenticação – 8081**
   ```bash
   cd backend/dashboard-financeiro-cadastro-autenticacao
   ./gradlew bootRun
   ```
   Aguarde o log `Started DashboardFinanceiroCadastroAutenticacaoApplication`. Liquibase cria o schema e o tópico `user.events` recebe novos cadastros.
2. **Serviço Financeiro – 8082**
   ```bash
   cd backend/dashboard-financeiro
   SERVER_PORT=8082 ./gradlew bootRun
   ```
   O log final `Started DashboardFinanceiroApplication` sinaliza que endpoints e publicação em Kafka estão prontos.
3. **Notificações – 8083**
   ```bash
   cd backend/dashboard-financeiro-notificacoes
   ./gradlew bootRun
   ```
   Confirme nos logs que os consumers Kafka (`user.events`, `transactions.events`, `goals.events`) iniciaram.
4. **API Gateway – 8089**
   ```bash
   cd backend/dashboard-financeiro-api-gateway/API-Gateway-Dashboard-Financeiro
   ./gradlew bootRun
   ```
   O gateway valida JWT usando o mesmo `JWT_SECRET` e encaminha as rotas para os serviços acima.

## 5. Testes end-to-end via API Gateway (http://localhost:8089)
> Use `curl` ou importe o arquivo de coleção Insomnia para repetir as chamadas. Execute cada passo na ordem para observar a propagação entre serviços.

1. **Registrar usuário (Gateway → Auth → Kafka → Notificações)**
   ```bash
   curl -X POST http://localhost:8089/api/users \
     -H "Content-Type: application/json" \
     -d '{
           "cpf": "12345678901",
           "name": "Usuário Demo",
           "email": "demo@dashboard.local",
           "password": "SenhaSegura123",
           "street": "Rua Principal",
           "number": 100,
           "city": "Porto Alegre",
           "state": "RS",
           "zipCode": "90000-000"
         }'
   ```
   Resultado esperado:
   - HTTP 201 com o usuário criado pelo serviço de cadastro/autenticação.
   - No terminal do serviço de notificações aparece um log indicando consumo de `UserRegisteredEvent` e inserção em `notification_users`.

2. **Autenticar e capturar tokens (Gateway → Auth)**
   ```bash
   curl -X POST http://localhost:8089/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email": "demo@dashboard.local","password": "SenhaSegura123"}'
   ```
   Copie `accessToken` e `refreshToken`. Defina:
   ```bash
   export TOKEN="Bearer <accessToken>"
   ```

3. **Criar categoria (Gateway → Financeiro)**
   ```bash
   curl -X POST http://localhost:8089/api/finance/categories \
     -H "Authorization: $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"name":"Alimentação","type":"EXPENSE","color":"#FF8800"}'
   ```
   Resultado: HTTP 201 e JSON com `id`. Sem tráfego Kafka nesta etapa.

4. **Criar conta bancária (Gateway → Financeiro)**
   ```bash
   curl -X POST http://localhost:8089/api/finance/bank-accounts \
     -H "Authorization: $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
           "institutionName": "Banco Demo",
           "branchNumber": "0001",
           "accountNumber": "123456",
           "accountDigit": "0",
           "accountType": "CHECKING",
           "nickname": "Conta Principal",
           "initialBalance": 1000.00
         }'
   ```
   Resultado: HTTP 201; banco `dashboard_financeiro` recebe o registro.

5. **Criar meta financeira (Gateway → Financeiro)**
   ```bash
   curl -X POST http://localhost:8089/api/finance/goals \
     -H "Authorization: $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
           "name": "Reserva de Emergência",
           "type": "SAVINGS",
           "targetAmount": 2000.00,
           "startDate": "2025-01-01",
           "endDate": "2025-12-31",
           "notifyOnAchieve": true,
           "notifyOnExceed": true
         }'
   ```
   Resultado: HTTP 201 com `id` da meta.

6. **Registrar transação (Gateway → Financeiro → Kafka → Notificações)**
   ```bash
   curl -X POST http://localhost:8089/api/finance/transactions \
     -H "Authorization: $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
           "bankAccountId": "<bankAccountId>",
           "type": "INCOME",
           "amount": 1200.00,
           "transactionDate": "2025-02-01",
           "description": "Salário de fevereiro",
           "categoryId": "<categoryId>",
           "notes": "Crédito mensal"
         }'
   ```
   Resultado esperado:
   - HTTP 201 com a transação criada.
   - Serviço financeiro recalcula saldo e publica `TransactionCreatedEvent` (tópico `transactions.events`) e, se a meta mudou de status, `GoalStatusChangedEvent`.
   - Serviço de notificações consome o(s) evento(s) e gera log `EmailNotificationService` indicando e-mail enfileirado/enviado. Com MailHog ativo, visualizar em `http://localhost:8025`.

7. **Consultar dashboard consolidado (Gateway → Financeiro)**
   ```bash
   curl -X GET "http://localhost:8089/api/finance/dashboard/overview?year=2025&month=2" \
     -H "Authorization: $TOKEN"
   ```
   Resultado: JSON com totais do mês, evolução e metas.

8. **Listar transações do usuário**
   ```bash
   curl -X GET http://localhost:8089/api/finance/transactions \
     -H "Authorization: $TOKEN"
   ```

9. **Renovar token quando expirar**
   ```bash
   curl -X POST http://localhost:8089/api/auth/refresh \
     -H "Content-Type: application/json" \
     -d '{"refreshToken": "<refreshToken>"}'
   ```

## 6. Monitoramento em paralelo
- Kafka UI (`http://localhost:8085`) para conferir mensagens nos tópicos `user.events`, `transactions.events` e `goals.events`.
- MailHog (`http://localhost:8025`) para confirmar o conteúdo dos e-mails.
- Logs dos serviços:
  - Auth: confirma criação do usuário.
  - Financeiro: mostra publicação dos eventos e cálculo de metas.
  - Notificações: mostra consumo + status de envio (`SENT`, `FAILED`, `DISABLED`).

## 7. Testes rápidos por serviço (opcional)
```bash
cd backend/dashboard-financeiro-cadastro-autenticacao && ./gradlew test
cd backend/dashboard-financeiro && ./gradlew test
cd backend/dashboard-financeiro-notificacoes && ./gradlew test
cd backend/dashboard-financeiro-api-gateway/API-Gateway-Dashboard-Financeiro && ./gradlew test
```
Os comandos validam a compilação e o carregamento de contexto.

## 8. Encerramento
```bash
# Interrompa cada serviço com CTRL+C
docker compose down
docker stop mailhog 2>/dev/null
```
> Se MailHog foi iniciado com `--rm`, ele é removido automaticamente.
