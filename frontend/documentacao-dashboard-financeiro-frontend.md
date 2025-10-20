# Dashboard Financeiro — Front-end (status em 02/10/2025)

## Visão geral do projeto
- Aplicação single-page construída com React 19 + TypeScript, empacotada pelo Vite 7.
- Estrutura organizada em camadas simples: `contexts` para estado compartilhado, `services` para chamadas HTTP, `components`/`pages` para UI.
- Uso de Tailwind CSS com paleta laranja personalizada (`primary.500 = #FF6B35`) para garantir consistência visual com o restante do ecossistema.

## Linha do tempo de desenvolvimento
- 16/09/2025 — Commit "first commit" subiu o scaffolding do Vite com React + TypeScript, configuração do ESLint e scripts básicos (`npm run dev`, `build`, `lint`).
- 02/10/2025 — Commit "Ajustes no login e criação da primeira tela" implementou contexto de autenticação, componentes de login/cadastro, `ProtectedRoute`, integração com Axios e Tailwind.
- 02/10/2025 — Commit "Ajustes e adicao de documentacao" refatorou README, alinhou o design system e registrou esta documentação de status do frontend.

## Fluxos implementados
- **Autenticação baseada em JWT**: contexto `AuthContext` centraliza estado do usuário, loading e operações `login`, `register`, `logout`; tokens são persistidos em `localStorage` e reaproveitados na inicialização da aplicação.
- **Interceptação de chamadas HTTP** (`src/services/api.ts`): Axios configurado com base `http://localhost:8080/api/v1`, injeta `Authorization` automaticamente e redireciona para `/login` ao receber 401.
- **Rotas protegidas** (`ProtectedRoute`): bloqueia acesso às páginas internas enquanto `isLoading` não termina ou quando não há sessão válida, exibindo indicador de carregamento amigável.
- **Tela de Login** (`components/auth/Login.tsx`): formulário com validações básicas e feedback de erro, estilizado com cartões e gradientes alinhados à identidade do TCC.
- **Tela de Cadastro** (`components/auth/Register.tsx`): coleta nome, e-mail, CPF e senha (com confirmação local); reaproveita o fluxo de registro do backend de cadastro/autenticação.
- **Dashboard autenticado** (`pages/Dashboard.tsx`): mostra dados básicos do usuário logado, status de conexão com backend e ação de logout.

## Integração com serviços backend
- A camada de serviços consome endpoints disponibilizados pelos microserviços Java: `/auth/login`, `/auth/refresh`, `/auth/logout`, `/auth/me` e `/users`.
- O token salvo localmente segue o contrato esperado por `AuthController` do serviço de cadastro/autenticação.
- O ambiente de desenvolvimento assume a stack do `docker-compose.yml` da pasta backend: o front consome a API em `http://localhost:8080`, que por sua vez conecta ao SQL Server e Kafka definidos no compose.

## Ferramentas de desenvolvimento
- Scripts disponíveis: `npm run dev` (servidor Vite), `build`, `lint`, `preview`.
- Tailwind configurado em `tailwind.config.js` com extensão de cores e scaneamento dos arquivos `src/**/*.{js,ts,jsx,tsx}`.
- ESLint 9 + TypeScript ESLint garantem padronização; `tsconfig` separado para aplicação e build incremental.

## Pontos em aberto / trabalhos futuros
- Não há testes automatizados (unitários ou de interface) configurados no momento.
- Fluxo visual ainda minimalista: futuras iterações devem incluir gráficos e seções financeiras consumindo dados reais das APIs de contas e transações.
- Gestão de refresh token ainda não implementada no front (a API oferece, mas o cliente depende do token salvo no login).
