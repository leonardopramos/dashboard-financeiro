# Dashboard Financeiro — Serviço de Notificações

## Visão geral
- Spring Boot 3.5.5 (Java 25) responsável por consumir eventos Kafka e disparar e-mails transacionais.
- Estrutura organizada em `application` (serviços), `messaging` (listeners/eventos), `infrastructure` (JPA) e `config` (mail/Kafka/propriedades).
- Reutiliza o SQL Server para persistir contatos (`notification_users`) e o histórico de envios (`email_notification_log`).

## Linha do tempo de desenvolvimento
- 17/09/2025 — Commit "Adição dos demais micro serviços do backend" adicionou o projeto `dashboard-financeiro-notificacoes` ao monorepo com build Gradle, configuração básica e suporte no `docker-compose.yml`.
- Até 02/10/2025 — Não há novos commits registrados para este serviço; as funcionalidades descritas nesta documentação ainda aguardam versionamento oficial.

## Eventos consumidos
- **`user.events`** (`UserEventsListener`): mantém a tabela `notification_users` sincronizada com base no microserviço de cadastro.
- **`transactions.events`** (`TransactionEventsListener`): a cada transação criada envia e-mail ao usuário ou para o fallback configurado.
- **`goals.events`** (`GoalEventsListener`): envia e-mails quando metas são atingidas (`ACHIEVED`) ou excedidas (`EXCEEDED`).
  - Eventos com outros status são ignorados para evitar ruído.

## Envio de e-mails
- `EmailNotificationService` encapsula toda a lógica de formatação e envio.
- Configurações em `notifications.email` (remetente, fallback, flag `enabled`). Quando `enabled=false`, os envios são apenas registrados como `DISABLED`.
- O corpo das mensagens é texto simples, com formatação amigável (datas e valores em pt-BR).
- Falhas no `JavaMailSender` são registradas como `FAILED` no log de notificações.

## Persistência
- `0001_create_notification_tables.sql` cria:
  - `notification_users`: cache de usuários com timestamps de auditoria.
  - `email_notification_log`: histórico de envios com status (`SENT`, `FAILED`, `DISABLED`) e payload das mensagens.
- Repositórios `NotificationUserRepository` e `EmailNotificationLogRepository` oferecem acesso JPA.

## Configuração
- `application.yml` expõe datasource, Kafka (`spring.kafka.consumer` com `JsonDeserializer`) e propriedades de mail (`spring.mail`).
- Topics configuráveis via `messaging.topics.*` — valores padrão alinham com os demais serviços.
- Porta padrão `8083`; perfil único (`default`).

## Testes
- `NotificationApplicationTests` garante subida do contexto. Casos de teste adicionais podem validar listeners usando `@EmbeddedKafka` ou `spring-kafka-test`.
