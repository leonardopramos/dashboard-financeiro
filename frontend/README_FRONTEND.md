# Dashboard Financeiro - Frontend

Sistema de autenticação e dashboard financeiro com design moderno e paleta de cores laranja.

## 🚀 Funcionalidades Implementadas

### ✅ Autenticação Completa
- **Login de usuário** com validação
- **Cadastro de usuário** em duas etapas:
  - Etapa 1: Dados básicos (nome, email, CPF, senha)
  - Etapa 2: Endereço (opcional)
- **Logout** com limpeza de tokens
- **Refresh token** automático
- **Proteção de rotas** privadas

### 🎨 Design Moderno
- **Paleta de cores**: Laranja chamativo (#ff6b35) como identidade visual
- **Background**: Predominantemente branco com detalhes em laranja
- **UI/UX**: Interface limpa e intuitiva
- **Responsivo**: Adaptado para desktop e mobile
- **Animações**: Transições suaves e feedback visual

### 🔧 Tecnologias Utilizadas
- **React 18** com TypeScript
- **React Router DOM** para roteamento
- **Axios** para requisições HTTP
- **Lucide React** para ícones
- **CSS personalizado** com variáveis CSS

## 📡 Integração com Backend

### Endpoints Utilizados
- `POST /api/v1/auth/login` - Login do usuário
- `POST /api/v1/users` - Cadastro de usuário
- `POST /api/v1/auth/refresh` - Renovação de token
- `POST /api/v1/auth/logout` - Logout
- `GET /api/v1/auth/me` - Dados do usuário atual

### Configuração da API
- **Base URL**: `http://localhost:8080` (API Gateway)
- **Autenticação**: Bearer Token
- **Refresh automático**: Implementado via interceptors

## 🏃‍♂️ Como Executar

### Pré-requisitos
- Node.js 18+
- npm ou yarn
- Backend rodando na porta 8080

### Instalação
```bash
# Instalar dependências
npm install

# Executar em modo desenvolvimento
npm run dev

# Build para produção
npm run build
```

### Acesso
- **URL Local**: http://localhost:5174
- **Login**: Acesse `/login` para fazer login
- **Cadastro**: Acesse `/register` para criar conta
- **Dashboard**: Rota protegida em `/dashboard`

## 📱 Páginas Implementadas

### 🔐 Login (`/login`)
- Formulário com email e senha
- Validação de campos obrigatórios
- Mostrar/ocultar senha
- Mensagens de erro
- Link para cadastro

### 📝 Cadastro (`/register`)
- **Etapa 1**: Dados pessoais
  - Nome completo
  - Email
  - CPF (com máscara)
  - Senha (mínimo 6 caracteres)
- **Etapa 2**: Endereço (opcional)
  - CEP (com máscara)
  - Rua, número, complemento
  - Bairro, cidade, estado
- Indicador de progresso
- Validações em tempo real

### 🏠 Dashboard (`/dashboard`)
- Header com informações do usuário
- Cards de estatísticas (receitas, despesas, saldo)
- Informações da conta
- Botões de ação rápida
- Logout funcional

## 🔒 Segurança

### Autenticação
- **JWT Tokens**: Access token + Refresh token
- **Armazenamento**: localStorage (pode ser migrado para httpOnly cookies)
- **Interceptors**: Renovação automática de tokens
- **Proteção de rotas**: Redirecionamento automático para login

### Validações
- **Frontend**: Validação de formulários em tempo real
- **Backend**: Validação com Bean Validation (Jakarta)
- **Tipos TypeScript**: Tipagem forte para maior segurança

## 🎨 Paleta de Cores

```css
/* Cores principais */
--primary-orange: #ff6b35        /* Laranja principal */
--primary-orange-dark: #e55a2b   /* Laranja escuro (hover) */
--primary-orange-light: #ff8c5a  /* Laranja claro */
--primary-orange-lighter: #fff4f0 /* Laranja muito claro (backgrounds) */

/* Cores neutras */
--white: #ffffff                 /* Fundo principal */
--gray-50: #f9fafb              /* Fundo secundário */
--gray-100 a --gray-900         /* Escala de cinzas */
```

## 📂 Estrutura do Projeto

```
src/
├── components/
│   ├── auth/
│   │   ├── Login.tsx           # Componente de login
│   │   └── Register.tsx        # Componente de cadastro
│   └── ProtectedRoute.tsx      # Proteção de rotas
├── contexts/
│   └── AuthContext.tsx         # Contexto de autenticação
├── pages/
│   └── Dashboard.tsx           # Página principal
├── services/
│   └── api.ts                  # Configuração da API
├── types/
│   └── auth.ts                 # Tipos TypeScript
├── App.tsx                     # Roteamento principal
├── index.css                   # Estilos globais
└── main.tsx                    # Ponto de entrada
```

## 🔄 Fluxo de Autenticação

1. **Usuário acessa rota protegida** → Redirecionado para `/login`
2. **Login bem-sucedido** → Tokens salvos → Redirecionado para `/dashboard`
3. **Token expira** → Refresh automático → Continua navegação
4. **Refresh falha** → Logout automático → Redirecionado para `/login`
5. **Logout manual** → Tokens removidos → Redirecionado para `/login`

## 🚧 Próximos Passos

- [ ] Implementar funcionalidades financeiras (receitas, despesas)
- [ ] Adicionar gráficos e relatórios
- [ ] Implementar notificações
- [ ] Adicionar temas (modo escuro)
- [ ] Melhorar acessibilidade
- [ ] Testes unitários e E2E

## 🐛 Troubleshooting

### Problemas Comuns

1. **Erro de CORS**: Verificar se o backend está configurado para aceitar requisições do frontend
2. **Token inválido**: Limpar localStorage e fazer login novamente
3. **Porta ocupada**: O Vite automaticamente usa outra porta disponível

### Logs Úteis
- Abrir DevTools → Console para ver erros de JavaScript
- Network tab para verificar requisições HTTP
- Application tab → Local Storage para ver tokens salvos

---

**Desenvolvido com ❤️ usando React + TypeScript**